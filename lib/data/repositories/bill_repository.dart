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
    PaymentMethodModel? paymentMethod,
    int transferFee = 0,
    String? notes,
  }) async {
    if (name.trim().isEmpty) throw Exception('Nama tagihan tidak boleh kosong');
    if (nominal <= 0) throw Exception('Nominal harus lebih dari 0');
    if (type == BillType.hutang && categoryId == null) {
      throw Exception('Kategori wajib dipilih untuk hutang');
    }
    if (type == BillType.piutang && paymentMethod == null) {
      throw Exception('Pilih rekening untuk piutang');
    }

    final isOnline = await _isOnline();
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
      paymentMethodId: type == BillType.piutang ? paymentMethod?.id : null,
      paymentMethodName: type == BillType.piutang ? paymentMethod?.name : null,
      transferFee: type == BillType.piutang ? transferFee : 0,
      notes: notes?.trim(),
      localCreatedAt: DateTime.now(),
    );
    final localId = await _service.createBill(bill, isOnline);
    final savedBill = bill.copyWith(id: localId);

    // Piutang → auto-debit saldo rekening (kita memberi pinjaman ke orang)
    if (type == BillType.piutang && paymentMethod != null) {
      final debitAmount = nominal + transferFee;
      final transaction = TransactionModel(
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
        categoryId: null,
        categoryName: 'Piutang',
        localCreatedAt: DateTime.now(),
      );
      await _transactionService.createTransaction(transaction, isOnline);
    }

    return savedBill;
  }

  Future<void> updateBill(BillModel bill) async {
    if (bill.name.trim().isEmpty) throw Exception('Nama tagihan tidak boleh kosong');
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

    final newPaid = (bill.paidAmount + payAmount).clamp(0, bill.nominal);
    final updated = bill.copyWith(
      paidAmount: newPaid,
      status: newPaid >= bill.nominal ? BillStatus.paid : BillStatus.partial,
      updatedAt: DateTime.now(),
    );

    final isOnline = await _isOnline();

    // Update bill
    await _service.updateBill(updated, isOnline);

    // Auto-create transaction
    // Hutang → expense (uang keluar), Piutang → income (uang masuk)
    final category = bill.type == BillType.hutang
        ? TransactionCategory.expense
        : TransactionCategory.income;

    final txCategoryId = category == TransactionCategory.expense
        ? (bill.categoryId ?? 'uncategorized')
        : null;
    final txCategoryName = category == TransactionCategory.expense
        ? (bill.categoryName ?? 'Lainnya')
        : null;

    final transaction = TransactionModel(
      id: 0,
      userId: bill.userId,
      description: '${bill.type == BillType.hutang ? 'Bayar' : 'Terima'} ${bill.name}',
      category: category,
      paymentMethodId: paymentMethod.id,
      paymentMethodName: paymentMethod.name,
      nominal: payAmount,
      date: DateTime.now(),
      notes: transferFee > 0
          ? 'Pembayaran tagihan: ${bill.name} (biaya transfer: Rp $transferFee)'
          : 'Pembayaran tagihan: ${bill.name}',
      categoryId: txCategoryId,
      categoryName: txCategoryName,
      localCreatedAt: DateTime.now(),
    );
    await _transactionService.createTransaction(transaction, isOnline);

    // Biaya transfer → expense terpisah
    if (transferFee > 0) {
      final feeTransaction = TransactionModel(
        id: 0,
        userId: bill.userId,
        description: 'Biaya transfer: ${bill.name}',
        category: TransactionCategory.expense,
        paymentMethodId: paymentMethod.id,
        paymentMethodName: paymentMethod.name,
        nominal: transferFee,
        date: DateTime.now(),
        notes: 'Biaya transfer pembayaran tagihan: ${bill.name}',
        categoryId: 'uncategorized',
        categoryName: 'Biaya Transfer',
        localCreatedAt: DateTime.now(),
      );
      await _transactionService.createTransaction(feeTransaction, isOnline);
    }
  }

  Future<void> deleteBill(BillModel bill) async {
    final isOnline = await _isOnline();
    await _service.deleteBill(bill.id, bill.userId, bill.firebaseDocId, isOnline);
  }

  Future<List<BillModel>> getBills(String userId, {BillStatus? status}) async {
    return await _service.getBills(userId, status: status?.name);
  }

  Future<List<BillModel>> getUnpaidBills(String userId) async {
    final unpaid = await _service.getBills(userId, status: BillStatus.unpaid.name);
    final partial = await _service.getBills(userId, status: BillStatus.partial.name);
    return [...unpaid, ...partial]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}
