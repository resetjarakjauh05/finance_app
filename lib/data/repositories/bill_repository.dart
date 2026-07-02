import '../../domain/models/bill_model.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/payment_method_model.dart';
import '../services/bill_service.dart';
import '../services/transaction_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class BillRepository {
  final BillService _service;
  final TransactionService _transactionService;
  final Connectivity _connectivity;

  BillRepository({
    required BillService service,
    TransactionService? transactionService,
    Connectivity? connectivity,
  })  : _service = service,
        _transactionService = transactionService ?? TransactionService(),
        _connectivity = connectivity ?? Connectivity();

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<BillModel> createBill({
    required String userId,
    required String name,
    required int nominal,
    required DateTime dueDate,
    BillType type = BillType.hutang,
    String? category,
    String? categoryId,
    String? categoryName,
    PaymentMethodModel? paymentMethod, // opsional untuk hutang & piutang
    int transferFee = 0,
    int? billingDay,
    int? maxInstallments,
    int? installmentAmount,
    String? notes,
  }) async {
    if (name.trim().isEmpty) throw Exception('Nama tidak boleh kosong');
    if (nominal <= 0) throw Exception('Nominal harus lebih dari 0');
    if ((type == BillType.hutang || type == BillType.tagihan) && categoryId == null) {
      throw Exception('Kategori wajib dipilih');
    }

    final isOnline = await _isOnline();

    // Hitung installmentAmount jika tidak diset tapi maxInstallments ada
    final int? resolvedInstallmentAmount = installmentAmount ??
        (maxInstallments != null && maxInstallments > 0
            ? (nominal / maxInstallments).ceil()
            : null);

    final bill = BillModel(
      id: 0,
      userId: userId,
      name: name.trim(),
      nominal: nominal,
      paidAmount: 0,
      dueDate: dueDate,
      status: BillStatus.unpaid,
      type: type,
      category: category?.trim(),
      categoryId: categoryId,
      categoryName: categoryName,
      paymentMethodId: (type == BillType.hutang || type == BillType.piutang)
          ? paymentMethod?.id
          : null,
      paymentMethodName: (type == BillType.hutang || type == BillType.piutang)
          ? paymentMethod?.name
          : null,
      transferFee: (type == BillType.hutang || type == BillType.piutang)
          ? transferFee
          : 0,
      billingDay: type == BillType.tagihan ? billingDay : null,
      maxInstallments: type == BillType.tagihan ? maxInstallments : null,
      installmentAmount:
          type == BillType.tagihan ? resolvedInstallmentAmount : null,
      installmentsPaid: 0,
      notes: notes?.trim(),
      localCreatedAt: DateTime.now(),
    );

    final localId = await _service.createBill(bill, isOnline);
    final savedBill = bill.copyWith(id: localId);

    // Hutang → opsional income (uang masuk ke rekening kita)
    if (type == BillType.hutang && paymentMethod != null) {
      final incomeAmount = nominal + transferFee;
      final tx = TransactionModel(
        id: 0,
        userId: userId,
        description: 'Hutang: ${name.trim()}',
        category: TransactionCategory.income,
        paymentMethodId: paymentMethod.id,
        paymentMethodName: paymentMethod.name,
        nominal: incomeAmount,
        date: DateTime.now(),
        notes: transferFee > 0
            ? 'Pinjaman masuk: ${name.trim()} (termasuk biaya transfer)'
            : 'Pinjaman masuk: ${name.trim()}',
        categoryId: categoryId ?? 'preset_hutang',
        categoryName: categoryName ?? 'Bayar Hutang',
        localCreatedAt: DateTime.now(),
      );
      await _transactionService.createTransaction(tx, isOnline);
    }

    // Piutang → opsional expense (uang keluar dari rekening kita)
    if (type == BillType.piutang && paymentMethod != null) {
      final debitAmount = nominal + transferFee;
      final tx = TransactionModel(
        id: 0,
        userId: userId,
        description: 'Piutang: ${name.trim()}',
        category: TransactionCategory.expense,
        paymentMethodId: paymentMethod.id,
        paymentMethodName: paymentMethod.name,
        nominal: debitAmount,
        date: DateTime.now(),
        notes: transferFee > 0
            ? 'Memberi pinjaman: ${name.trim()} (termasuk biaya transfer)'
            : 'Memberi pinjaman: ${name.trim()}',
        categoryId: 'preset_piutang',
        categoryName: 'Terima Piutang',
        localCreatedAt: DateTime.now(),
      );
      await _transactionService.createTransaction(tx, isOnline);
    }

    return savedBill;
  }

  Future<void> updateBill(BillModel bill) async {
    if (bill.name.trim().isEmpty) throw Exception('Nama tidak boleh kosong');
    if (bill.nominal <= 0) throw Exception('Nominal harus lebih dari 0');
    final isOnline = await _isOnline();
    await _service.updateBill(bill, isOnline);
  }

  /// Pay bill → update bill + auto-create transaction
  Future<void> payBill(
    BillModel bill,
    int payAmount,
    PaymentMethodModel paymentMethod, {
    int transferFee = 0,
  }) async {
    if (payAmount <= 0) throw Exception('Nominal bayar harus lebih dari 0');

    final isOnline = await _isOnline();
    BillModel updated;

    if (bill.type == BillType.tagihan) {
      // Tagihan: increment installmentsPaid, status lunas jika maxInstallments tercapai
      final newInstallmentsPaid = bill.installmentsPaid + 1;
      final hasLimit = bill.maxInstallments != null;
      final isFullyPaid =
          hasLimit && newInstallmentsPaid >= bill.maxInstallments!;
      final newPaidAmount = bill.paidAmount + payAmount;

      updated = bill.copyWith(
        paidAmount: newPaidAmount,
        installmentsPaid: newInstallmentsPaid,
        status: isFullyPaid ? BillStatus.paid : BillStatus.partial,
        updatedAt: DateTime.now(),
      );
    } else {
      // Hutang / Piutang: progress berdasarkan paidAmount vs nominal
      final newPaid = (bill.paidAmount + payAmount).clamp(0, bill.nominal);
      updated = bill.copyWith(
        paidAmount: newPaid,
        status:
            newPaid >= bill.nominal ? BillStatus.paid : BillStatus.partial,
        updatedAt: DateTime.now(),
      );
    }

    await _service.updateBill(updated, isOnline);

    // Kategori transaksi per tipe:
    // Hutang  → expense (kita bayar ke orang) → pakai kategori bill atau fallback 'hutang'
    // Piutang → income  (kita terima dari orang) → kategori khusus 'piutang'
    // Tagihan → expense (kita bayar tagihan) → pakai kategori bill
    final txCategory = bill.type == BillType.piutang
        ? TransactionCategory.income
        : TransactionCategory.expense;

    final txCategoryId = bill.type == BillType.piutang
        ? 'preset_piutang'
        : bill.type == BillType.tagihan
            ? (bill.categoryId ?? 'preset_tagihan')
            : (bill.categoryId ?? 'preset_hutang');
    final txCategoryName = bill.type == BillType.piutang
        ? 'Terima Piutang'
        : bill.type == BillType.tagihan
            ? (bill.categoryName ?? 'Tagihan & Utilitas')
            : (bill.categoryName ?? 'Bayar Hutang');

    final String txDesc;
    if (bill.type == BillType.hutang) {
      txDesc = 'Bayar hutang: ${bill.name}';
    } else if (bill.type == BillType.piutang) {
      txDesc = 'Terima piutang: ${bill.name}';
    } else {
      final inst = bill.installmentsPaid + 1;
      final total = bill.maxInstallments;
      txDesc = total != null
          ? 'Tagihan ${bill.name} (cicilan $inst/$total)'
          : 'Tagihan ${bill.name} (bulan ke-$inst)';
    }

    final tx = TransactionModel(
      id: 0,
      userId: bill.userId,
      description: txDesc,
      category: txCategory,
      paymentMethodId: paymentMethod.id,
      paymentMethodName: paymentMethod.name,
      nominal: payAmount,
      date: DateTime.now(),
      notes: transferFee > 0
          ? '$txDesc + biaya transfer Rp $transferFee'
          : txDesc,
      categoryId: txCategoryId,
      categoryName: txCategoryName,
      localCreatedAt: DateTime.now(),
    );
    await _transactionService.createTransaction(tx, isOnline);

    // Biaya transfer → expense terpisah
    if (transferFee > 0) {
      final feeTx = TransactionModel(
        id: 0,
        userId: bill.userId,
        description: 'Biaya transfer: ${bill.name}',
        category: TransactionCategory.expense,
        paymentMethodId: paymentMethod.id,
        paymentMethodName: paymentMethod.name,
        nominal: transferFee,
        date: DateTime.now(),
        notes: 'Biaya transfer pembayaran: ${bill.name}',
        categoryId: 'preset_lainnya',
        categoryName: 'Lainnya',
        localCreatedAt: DateTime.now(),
      );
      await _transactionService.createTransaction(feeTx, isOnline);
    }
  }

  Future<void> deleteBill(BillModel bill) async {
    final isOnline = await _isOnline();
    await _service.deleteBill(
        bill.id, bill.userId, bill.firebaseDocId, isOnline);
  }

  Future<List<BillModel>> getBills(String userId, {BillStatus? status}) async {
    return await _service.getBills(userId, status: status?.name);
  }

  Stream<List<BillModel>> watchBills(String userId) {
    return _service.watchBills(userId);
  }

  /// Get bills filtered by type
  Future<List<BillModel>> getBillsByType(String userId, BillType type) async {
    final all = await _service.getBills(userId);
    return all
        .where((b) => b.type == type && !b.isDeleted)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  Future<List<BillModel>> getUnpaidBills(String userId) async {
    final unpaid =
        await _service.getBills(userId, status: BillStatus.unpaid.name);
    final partial =
        await _service.getBills(userId, status: BillStatus.partial.name);
    return [...unpaid, ...partial]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}
