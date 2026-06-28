import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../../data/repositories/payment_method_repository.dart';

/// ViewModel untuk payment method management
class PaymentMethodViewModel extends ChangeNotifier {
  final PaymentMethodRepository _repository;
  final String userId;
  StreamSubscription<List<PaymentMethodModel>>? _subscription;

  PaymentMethodViewModel({
    required PaymentMethodRepository repository,
    required this.userId,
  }) : _repository = repository {
    _listenToStream();
  }

  List<PaymentMethodModel> _paymentMethods = [];
  List<PaymentMethodModel> get paymentMethods => _paymentMethods;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Subscribe ke Firestore realtime stream
  void _listenToStream() {
    _setLoading(true);
    _subscription = _repository
        .getPaymentMethodsStream(userId)
        .listen(
          (methods) {
            _paymentMethods = methods;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _setError(e.toString());
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Load payment methods (manual refresh fallback)
  Future<void> loadPaymentMethods() async {
    _setLoading(true);
    _clearError();

    try {
      _paymentMethods = await _repository.getAllPaymentMethods(userId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Create payment method
  Future<void> createPaymentMethod(PaymentMethodModel method) async {
    _clearError();
    try {
      await _repository.createPaymentMethod(userId, method);
      // Stream auto-update list
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// Update payment method
  Future<void> updatePaymentMethod(
    String methodId,
    PaymentMethodModel updatedMethod,
  ) async {
    _clearError();
    try {
      await _repository.updatePaymentMethod(userId, methodId, updatedMethod);
      // Stream auto-update list
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// Delete payment method (soft delete - nonaktifkan)
  Future<void> deletePaymentMethod(String methodId) async {
    _clearError();
    try {
      // 1. Optimistic update: tandai isActive = false di local list
      _paymentMethods = _paymentMethods.map((m) {
        if (m.id == methodId) return m.copyWith(isActive: false);
        return m;
      }).toList();
      notifyListeners();
      // 2. Update Firestore
      await _repository.deletePaymentMethod(userId, methodId);
    } catch (e) {
      // Rollback: reload dari Firestore jika gagal
      _setError(e.toString());
      await loadPaymentMethods();
      rethrow;
    }
  }

  /// Permanent delete payment method (hapus total)
  Future<void> permanentDeletePaymentMethod(String methodId) async {
    _clearError();
    try {
      await _repository.permanentDeletePaymentMethod(userId, methodId);
      // Stream auto-update (doc deleted)
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// Cek apakah payment method dipakai di transaksi
  Future<bool> isUsedInTransactions(String methodId) async {
    return await _repository.isUsedInTransactions(userId, methodId);
  }

  /// Initialize default payment methods
  Future<void> initializeDefaults() async {
    _clearError();
    try {
      await _repository.initializeDefaultPaymentMethods(userId);
      // Stream auto-update
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// Get active payment methods only
  List<PaymentMethodModel> get activePaymentMethods {
    return _paymentMethods.where((m) => m.isActive).toList();
  }

  /// Get payment method by ID
  PaymentMethodModel? getPaymentMethodById(String id) {
    try {
      return _paymentMethods.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _clearError();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
