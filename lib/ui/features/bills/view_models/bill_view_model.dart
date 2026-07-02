import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../domain/models/bill_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../../data/repositories/bill_repository.dart';

class BillViewModel extends ChangeNotifier {
  final BillRepository _repository;
  final String userId;

  BillViewModel({required BillRepository repository, required this.userId})
      : _repository = repository;

  List<BillModel> _bills = [];
  List<BillModel> get bills => _bills;

  StreamSubscription<List<BillModel>>? _billsSubscription;

  List<BillModel> get unpaidBills => _bills
      .where((b) => b.status != BillStatus.paid && !b.isDeleted)
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<BillModel> get paidBills =>
      _bills.where((b) => b.status == BillStatus.paid && !b.isDeleted).toList();

  // Total summary per tipe
  int getTotalNominal(BillType type) {
    return _bills
        .where((b) => b.type == type && !b.isDeleted)
        .fold(0, (sum, b) => sum + b.nominal);
  }

  int getTotalRemaining(BillType type) {
    return _bills
        .where((b) => b.type == type && !b.isDeleted && b.status != BillStatus.paid)
        .fold(0, (sum, b) => sum + b.remainingAmount);
  }

  int getCountUnpaid(BillType type) {
    return _bills
        .where((b) => b.type == type && !b.isDeleted && b.status != BillStatus.paid)
        .length;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadBills({BillStatus? status}) async {
    _setLoading(true);
    _clearError();
    try {
      _bills = await _repository.getBills(userId, status: status);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> init() async {
    _setLoading(true);
    _clearError();
    try {
      // Subscribe to realtime stream
      _billsSubscription = _repository.watchBills(userId).listen(
        (bills) {
          _bills = bills;
          _setLoading(false);
          notifyListeners();
        },
        onError: (e) {
          _setError(e.toString());
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<BillModel?> createBill({
    required String name,
    required int nominal,
    required DateTime dueDate,
    BillType type = BillType.hutang,
    String? category,
    String? categoryId,
    String? categoryName,
    PaymentMethodModel? paymentMethod,
    int transferFee = 0,
    int? billingDay,
    int? maxInstallments,
    int? installmentAmount,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final bill = await _repository.createBill(
        userId: userId,
        name: name,
        nominal: nominal,
        dueDate: dueDate,
        type: type,
        category: category,
        categoryId: categoryId,
        categoryName: categoryName,
        paymentMethod: paymentMethod,
        transferFee: transferFee,
        billingDay: billingDay,
        maxInstallments: maxInstallments,
        installmentAmount: installmentAmount,
        notes: notes,
      );
      _setLoading(false);
      await loadBills();
      return bill;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateBill(BillModel bill) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.updateBill(bill);
      _setLoading(false);
      await loadBills();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> payBill(BillModel bill, int payAmount, PaymentMethodModel paymentMethod, {int transferFee = 0}) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.payBill(bill, payAmount, paymentMethod, transferFee: transferFee);
      _setLoading(false);
      await loadBills();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteBill(BillModel bill) async {
    _clearError();
    try {
      await _repository.deleteBill(bill);
      await loadBills();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _billsSubscription?.cancel();
    super.dispose();
  }
}
