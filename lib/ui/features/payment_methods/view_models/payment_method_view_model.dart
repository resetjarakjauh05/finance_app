import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// ViewModel untuk payment method management
class PaymentMethodViewModel extends ChangeNotifier {
  final PaymentMethodRepository _repository;
  final String userId;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  bool _isOnline = false;

  PaymentMethodViewModel({
    required PaymentMethodRepository repository,
    required this.userId,
  }) : _repository = repository {
    _init();
  }

  List<PaymentMethodModel> _paymentMethods = [];
  List<PaymentMethodModel> get paymentMethods => _paymentMethods;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> _init() async {
    _setLoading(true);

    // Cek koneksi awal
    final result = await Connectivity().checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);

    // Monitor perubahan koneksi — saat online, reload merged data
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) async {
      final wasOffline = !_isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);
      if (wasOffline && _isOnline) {
        // Baru online → reload dari Firestore+SQLite merge
        await loadPaymentMethods();
      }
    });

    // Load awal: selalu dari SQLite dulu (offline-safe)
    // Jika online, getAllPaymentMethods merge Firestore+unsynced local
    await loadPaymentMethods();
  }

  /// Load payment methods — SQLite dulu (offline-safe), merge Firestore jika berhasil
  Future<void> loadPaymentMethods() async {
    _setLoading(true);
    _clearError();
    try {
      // 1. Selalu load SQLite dulu — tidak pernah gagal
      final local = await _repository.getLocalPaymentMethods(userId);
      _paymentMethods = local;
      _isLoading = false;
      notifyListeners();

      // 2. Re-check koneksi aktual saat load (bukan cached _isOnline)
      // Connectivity cached bisa stale → false negative
      final result = await Connectivity().checkConnectivity();
      final isOnlineNow = !result.contains(ConnectivityResult.none);
      _isOnline = isOnlineNow; // update cached state

      if (isOnlineNow) {
        try {
          final merged = await _repository.getAllPaymentMethods(userId)
              .timeout(const Duration(seconds: 5));
          _paymentMethods = merged;
          notifyListeners();
        } catch (_) {
          // Firestore gagal → tetap pakai SQLite yang sudah ditampilkan
        }
      }
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
      // Offline: stream Firestore tidak emit → reload manual dari SQLite
      await loadPaymentMethods();
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
      // Langsung reload SQLite — tidak tunggu Firestore timeout saat offline
      _paymentMethods = await _repository.getLocalPaymentMethods(userId);
      notifyListeners();
      // Background: coba reload dari Firestore jika online
      if (_isOnline) {
        _repository.getAllPaymentMethods(userId).then((merged) {
          _paymentMethods = merged;
          notifyListeners();
        }).catchError((_) {});
      }
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
      // Optimistic: hapus dari list lokal dulu
      _paymentMethods = _paymentMethods
          .where((m) => m.id != methodId)
          .toList();
      notifyListeners();
      await _repository.permanentDeletePaymentMethod(userId, methodId);
      // Reload konfirmasi
      await loadPaymentMethods();
    } catch (e) {
      _setError(e.toString());
      await loadPaymentMethods();
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
      await loadPaymentMethods();
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
    _connectivitySub?.cancel();
    super.dispose();
  }
}
