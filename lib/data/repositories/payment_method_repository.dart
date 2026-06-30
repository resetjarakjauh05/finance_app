import '../../domain/models/payment_method_model.dart';
import '../services/payment_method_service.dart';
import '../local/transaction_dao.dart';

/// Repository untuk payment method logic
class PaymentMethodRepository {
  final PaymentMethodService _service;
  final TransactionDao _transactionDao;

  PaymentMethodRepository({
    required PaymentMethodService service,
    TransactionDao? transactionDao,
  })  : _service = service,
        _transactionDao = transactionDao ?? TransactionDao();

  /// Stream semua payment methods termasuk nonaktif (untuk management screen)
  Stream<List<PaymentMethodModel>> getPaymentMethodsStream(String userId) {
    return _service.getPaymentMethodsStream(userId);
  }

  /// Stream hanya payment methods aktif (untuk pilihan transaksi)
  Stream<List<PaymentMethodModel>> getActivePaymentMethodsStream(String userId) {
    return _service.getActivePaymentMethodsStream(userId);
  }

  /// Get all payment methods
  Future<List<PaymentMethodModel>> getAllPaymentMethods(String userId) async {
    return await _service.getAllPaymentMethods(userId);
  }

  /// Get langsung dari SQLite — bypass Firestore cek koneksi
  Future<List<PaymentMethodModel>> getLocalPaymentMethods(String userId) async {
    return await _service.getLocalPaymentMethods(userId);
  }

  /// Get payment method by ID
  Future<PaymentMethodModel?> getPaymentMethodById(
    String userId,
    String methodId,
  ) async {
    return await _service.getPaymentMethodById(userId, methodId);
  }

  /// Create payment method
  Future<String> createPaymentMethod(
    String userId,
    PaymentMethodModel method,
  ) async {
    if (method.name.trim().isEmpty) {
      throw Exception('Nama metode pembayaran tidak boleh kosong');
    }

    if (method.type == PaymentMethodType.bank &&
        (method.bankName == null || method.bankName!.trim().isEmpty)) {
      throw Exception('Nama bank harus diisi untuk tipe Bank');
    }

    return await _service.createPaymentMethod(userId, method);
  }

  /// Update payment method
  Future<void> updatePaymentMethod(
    String userId,
    String methodId,
    PaymentMethodModel updatedMethod,
  ) async {
    if (updatedMethod.name.trim().isEmpty) {
      throw Exception('Nama metode pembayaran tidak boleh kosong');
    }

    if (updatedMethod.type == PaymentMethodType.bank &&
        (updatedMethod.bankName == null ||
            updatedMethod.bankName!.trim().isEmpty)) {
      throw Exception('Nama bank harus diisi untuk tipe Bank');
    }

    final updates = {
      'name': updatedMethod.name,
      'type': updatedMethod.type.name,
      'bankName': updatedMethod.bankName,
      'accountNumber': updatedMethod.accountNumber,
      'isActive': updatedMethod.isActive,
      'order': updatedMethod.order,
    };

    await _service.updatePaymentMethod(userId, methodId, updates);
  }

  /// Cek apakah payment method digunakan di transaksi
  Future<bool> isUsedInTransactions(String userId, String methodId) async {
    final transactions = await _transactionDao.filterByPaymentMethod(
      userId,
      methodId,
    );
    return transactions.isNotEmpty;
  }

  /// Soft delete payment method (nonaktifkan)
  Future<void> deletePaymentMethod(String userId, String methodId) async {
    await _service.deletePaymentMethod(userId, methodId);
  }

  /// Permanent delete payment method (hapus total dari Firestore)
  Future<void> permanentDeletePaymentMethod(
    String userId,
    String methodId,
  ) async {
    await _service.permanentDeletePaymentMethod(userId, methodId);
  }

  /// Reorder payment methods
  Future<void> reorderPaymentMethods(
    String userId,
    List<String> orderedIds,
  ) async {
    await _service.reorderPaymentMethods(userId, orderedIds);
  }

  /// Initialize default payment methods
  Future<void> initializeDefaultPaymentMethods(String userId) async {
    final existing = await _service.getAllPaymentMethods(userId);
    if (existing.isNotEmpty) return;
    await _service.initializeDefaultPaymentMethods(userId);
  }
}
