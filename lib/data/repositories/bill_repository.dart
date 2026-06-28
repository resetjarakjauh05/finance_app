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
    String? notes,
  }) async {
    if (name.trim().isEmpty) throw Exception('Nama tagihan tidak boleh kosong');
    if (nominal <= 0) throw Exception('Nominal harus lebih dari 0');

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
      notes: notes?.trim(),
      localCreatedAt: DateTime.now(),
    );
    final localId = await _service.createBill(bill, isOnline);
    return bill.copyWith(id: localId);
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
    PaymentMethodModel paymentMethod,
  ) async {
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

    final transaction = TransactionModel(
      id: 0,
      userId: bill.userId,
      description: '${bill.type == BillType.hutang ? 'Bayar' : 'Terima'} ${bill.name}',
      category: category,
      paymentMethodId: paymentMethod.id,
      paymentMethodName: paymentMethod.name,
      nominal: payAmount,
      date: DateTime.now(),
      notes: 'Pembayaran tagihan: ${bill.name}',
      localCreatedAt: DateTime.now(),
    );

    await _transactionService.createTransaction(transaction, isOnline);
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
