import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/payment_method_model.dart';

/// Service untuk operasi payment method di Firestore
class PaymentMethodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get payment methods collection reference untuk user
  CollectionReference _getUserPaymentMethodsCollection(String userId) {
    return _firestore.collection('paymentMethods').doc(userId).collection('methods');
  }

  /// Convert Firestore doc data → safe map untuk fromJson
  Map<String, dynamic> _toJson(String docId, Map<String, dynamic> data) {
    return {
      'id': docId,
      ...data,
      // Convert Firestore Timestamp → ISO string agar Freezed fromJson happy
      if (data['createdAt'] is Timestamp)
        'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      if (data['updatedAt'] is Timestamp)
        'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    };
  }

  /// Stream semua payment methods untuk user (realtime) — termasuk nonaktif, untuk management screen
  Stream<List<PaymentMethodModel>> getPaymentMethodsStream(String userId) {
    return _getUserPaymentMethodsCollection(userId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentMethodModel.fromJson(
                _toJson(doc.id, doc.data() as Map<String, dynamic>),
              ))
          .toList();
    });
  }

  /// Stream hanya payment methods aktif — untuk pilihan transaksi
  Stream<List<PaymentMethodModel>> getActivePaymentMethodsStream(String userId) {
    return _getUserPaymentMethodsCollection(userId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentMethodModel.fromJson(
                _toJson(doc.id, doc.data() as Map<String, dynamic>),
              ))
          .where((m) => m.isActive)
          .toList();
    });
  }

  /// Get all payment methods (untuk editing/management)
  Future<List<PaymentMethodModel>> getAllPaymentMethods(String userId) async {
    final snapshot = await _getUserPaymentMethodsCollection(userId)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => PaymentMethodModel.fromJson(
              _toJson(doc.id, doc.data() as Map<String, dynamic>),
            ))
        .toList();
  }

  /// Get single payment method by ID
  Future<PaymentMethodModel?> getPaymentMethodById(
    String userId,
    String methodId,
  ) async {
    final doc = await _getUserPaymentMethodsCollection(userId)
        .doc(methodId)
        .get();

    if (!doc.exists) return null;
    return PaymentMethodModel.fromJson(
      _toJson(doc.id, doc.data() as Map<String, dynamic>),
    );
  }

  /// Create payment method
  Future<String> createPaymentMethod(
    String userId,
    PaymentMethodModel method,
  ) async {
    final docRef = await _getUserPaymentMethodsCollection(userId).add({
      'userId': userId,
      'name': method.name,
      'type': method.type.name,
      'bankName': method.bankName,
      'accountNumber': method.accountNumber,
      'isActive': method.isActive,
      'order': method.order,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Update payment method
  Future<void> updatePaymentMethod(
    String userId,
    String methodId,
    Map<String, dynamic> updates,
  ) async {
    await _getUserPaymentMethodsCollection(userId).doc(methodId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete payment method (soft delete)
  Future<void> deletePaymentMethod(String userId, String methodId) async {
    await _getUserPaymentMethodsCollection(userId).doc(methodId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Permanent delete (jika diperlukan)
  Future<void> permanentDeletePaymentMethod(
    String userId,
    String methodId,
  ) async {
    await _getUserPaymentMethodsCollection(userId).doc(methodId).delete();
  }

  /// Reorder payment methods
  Future<void> reorderPaymentMethods(
    String userId,
    List<String> orderedIds,
  ) async {
    final batch = _firestore.batch();

    for (int i = 0; i < orderedIds.length; i++) {
      final docRef =
          _getUserPaymentMethodsCollection(userId).doc(orderedIds[i]);
      batch.update(docRef, {
        'order': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Initialize default payment methods untuk user baru
  Future<void> initializeDefaultPaymentMethods(String userId) async {
    final defaults = [
      {
        'name': 'Tunai',
        'type': PaymentMethodType.cash.name,
        'order': 0,
      },
      {
        'name': 'Bank Mandiri',
        'type': PaymentMethodType.bank.name,
        'bankName': 'Bank Mandiri',
        'order': 1,
      },
      {
        'name': 'Bank Jatim',
        'type': PaymentMethodType.bank.name,
        'bankName': 'Bank Jatim',
        'order': 2,
      },
      {
        'name': 'Bank Jago',
        'type': PaymentMethodType.bank.name,
        'bankName': 'Bank Jago',
        'order': 3,
      },
      {
        'name': 'Dana',
        'type': PaymentMethodType.wallet.name,
        'order': 4,
      },
      {
        'name': 'SEA BANK',
        'type': PaymentMethodType.bank.name,
        'bankName': 'SEA BANK',
        'order': 5,
      },
    ];

    final batch = _firestore.batch();

    for (final method in defaults) {
      final docRef = _getUserPaymentMethodsCollection(userId).doc();
      batch.set(docRef, {
        'userId': userId,
        'name': method['name'],
        'type': method['type'],
        'bankName': method['bankName'],
        'isActive': true,
        'order': method['order'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
