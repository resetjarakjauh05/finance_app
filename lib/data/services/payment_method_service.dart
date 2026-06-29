import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/payment_method_model.dart';
import '../local/payment_method_dao.dart';
import '../local/pending_operations_dao.dart';
import 'connectivity_service.dart';

/// Service untuk operasi payment method — Firestore-first, SQLite fallback
class PaymentMethodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PaymentMethodDao _dao = PaymentMethodDao();
  final PendingOperationsDao _pendingOpsDao = PendingOperationsDao();
  final ConnectivityService _connectivity = ConnectivityService();

  CollectionReference _getUserPaymentMethodsCollection(String userId) {
    return _firestore.collection('paymentMethods').doc(userId).collection('methods');
  }

  Map<String, dynamic> _toJson(String docId, Map<String, dynamic> data) {
    return {
      'id': docId,
      ...data,
      if (data['createdAt'] is Timestamp)
        'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      if (data['updatedAt'] is Timestamp)
        'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    };
  }

  PaymentMethodModel _fromFirestoreDoc(String docId, Map<String, dynamic> data, String userId) {
    return PaymentMethodModel.fromJson(_toJson(docId, {...data, 'userId': userId}));
  }

  /// Stream realtime dari Firestore, cache ke SQLite saat dapat data
  Stream<List<PaymentMethodModel>> getPaymentMethodsStream(String userId) {
    return _getUserPaymentMethodsCollection(userId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      final methods = snapshot.docs
          .map((doc) => _fromFirestoreDoc(doc.id, doc.data() as Map<String, dynamic>, userId))
          .toList();
      // Cache ke SQLite di background
      _cacheToSqlite(userId, methods);
      return methods;
    });
  }

  /// Stream aktif dari Firestore, cache ke SQLite
  Stream<List<PaymentMethodModel>> getActivePaymentMethodsStream(String userId) {
    return _getUserPaymentMethodsCollection(userId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      final methods = snapshot.docs
          .map((doc) => _fromFirestoreDoc(doc.id, doc.data() as Map<String, dynamic>, userId))
          .where((m) => m.isActive)
          .toList();
      _cacheToSqlite(userId, methods);
      return methods;
    });
  }

  /// Get all — Firestore-first, fallback SQLite
  Future<List<PaymentMethodModel>> getAllPaymentMethods(String userId) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snapshot = await _getUserPaymentMethodsCollection(userId).orderBy('order').get();
        final methods = snapshot.docs
            .map((doc) => _fromFirestoreDoc(doc.id, doc.data() as Map<String, dynamic>, userId))
            .toList();
        await _cacheToSqlite(userId, methods);
        return methods;
      } catch (e) {
        debugPrint('PaymentMethodService.getAllPaymentMethods Firestore error: $e');
      }
    }
    return _dao.getAll(userId);
  }

  /// Get aktif saja — Firestore-first, fallback SQLite
  Future<List<PaymentMethodModel>> getActivePaymentMethods(String userId) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snapshot = await _getUserPaymentMethodsCollection(userId).orderBy('order').get();
        final methods = snapshot.docs
            .map((doc) => _fromFirestoreDoc(doc.id, doc.data() as Map<String, dynamic>, userId))
            .where((m) => m.isActive)
            .toList();
        await _cacheToSqlite(userId, methods);
        return methods;
      } catch (e) {
        debugPrint('PaymentMethodService.getActivePaymentMethods Firestore error: $e');
      }
    }
    return _dao.getActive(userId);
  }

  /// Get single by ID — Firestore-first, fallback SQLite
  Future<PaymentMethodModel?> getPaymentMethodById(String userId, String methodId) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final doc = await _getUserPaymentMethodsCollection(userId).doc(methodId).get();
        if (!doc.exists) return null;
        final m = _fromFirestoreDoc(doc.id, doc.data() as Map<String, dynamic>, userId);
        await _dao.insertOrReplace(m);
        return m;
      } catch (e) {
        debugPrint('PaymentMethodService.getPaymentMethodById Firestore error: $e');
      }
    }
    final all = await _dao.getAll(userId);
    return all.where((m) => m.id == methodId).firstOrNull;
  }

  /// Create — Firestore-first, offline queue fallback
  Future<String> createPaymentMethod(String userId, PaymentMethodModel method) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
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
        final saved = method.copyWith(id: docRef.id, createdAt: DateTime.now(), updatedAt: DateTime.now());
        await _dao.insertOrReplace(saved);
        return docRef.id;
      } catch (e) {
        debugPrint('PaymentMethodService.createPaymentMethod Firestore error: $e');
      }
    }
    // Offline — simpan ke SQLite + queue
    await _dao.insertOrReplace(method);
    await _pendingOpsDao.addPendingOperation(
      operation: 'CREATE',
      tableName: 'payment_methods',
      recordId: method.id.hashCode,
      data: _toQueueData(method, userId),
    );
    return method.id;
  }

  /// Update — Firestore-first, offline queue fallback
  Future<void> updatePaymentMethod(String userId, String methodId, Map<String, dynamic> updates) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        await _getUserPaymentMethodsCollection(userId).doc(methodId).update({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        // Refresh cache
        final all = await _dao.getAll(userId);
        final existing = all.where((m) => m.id == methodId).firstOrNull;
        if (existing != null) {
          await _dao.update(existing.copyWith(
            isActive: updates['isActive'] as bool? ?? existing.isActive,
            name: updates['name'] as String? ?? existing.name,
            updatedAt: DateTime.now(),
          ));
        }
        return;
      } catch (e) {
        debugPrint('PaymentMethodService.updatePaymentMethod Firestore error: $e');
      }
    }
    // Offline — update SQLite + queue
    final all = await _dao.getAll(userId);
    final existing = all.where((m) => m.id == methodId).firstOrNull;
    if (existing != null) {
      final updated = existing.copyWith(
        isActive: updates['isActive'] as bool? ?? existing.isActive,
        name: updates['name'] as String? ?? existing.name,
        updatedAt: DateTime.now(),
      );
      await _dao.update(updated);
      await _pendingOpsDao.addPendingOperation(
        operation: 'UPDATE',
        tableName: 'payment_methods',
        recordId: methodId.hashCode,
        firebaseDocId: methodId,
        data: {..._toQueueData(updated, userId), ...updates},
      );
    }
  }

  /// Delete (soft) — Firestore-first, offline queue fallback
  Future<void> deletePaymentMethod(String userId, String methodId) async {
    await _dao.softDelete(methodId);
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        await _getUserPaymentMethodsCollection(userId).doc(methodId).update({
          'isActive': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      } catch (e) {
        debugPrint('PaymentMethodService.deletePaymentMethod Firestore error: $e');
      }
    }
    await _pendingOpsDao.addPendingOperation(
      operation: 'DELETE',
      tableName: 'payment_methods',
      recordId: methodId.hashCode,
      firebaseDocId: methodId,
      data: {'userId': userId, 'id': methodId},
    );
  }

  /// Permanent delete
  Future<void> permanentDeletePaymentMethod(String userId, String methodId) async {
    await _dao.softDelete(methodId);
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        await _getUserPaymentMethodsCollection(userId).doc(methodId).delete();
      } catch (e) {
        debugPrint('PaymentMethodService.permanentDelete Firestore error: $e');
      }
    }
  }

  /// Reorder — Firestore-first, offline queue fallback
  Future<void> reorderPaymentMethods(String userId, List<String> orderedIds) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final batch = _firestore.batch();
        for (int i = 0; i < orderedIds.length; i++) {
          final docRef = _getUserPaymentMethodsCollection(userId).doc(orderedIds[i]);
          batch.update(docRef, {'order': i, 'updatedAt': FieldValue.serverTimestamp()});
        }
        await batch.commit();
      } catch (e) {
        debugPrint('PaymentMethodService.reorderPaymentMethods Firestore error: $e');
      }
    }
    // Update SQLite order
    final all = await _dao.getAll(userId);
    for (int i = 0; i < orderedIds.length; i++) {
      final m = all.where((m) => m.id == orderedIds[i]).firstOrNull;
      if (m != null) {
        await _dao.update(m.copyWith(order: i));
        if (!isOnline) {
          await _pendingOpsDao.addPendingOperation(
            operation: 'UPDATE',
            tableName: 'payment_methods',
            recordId: m.id.hashCode,
            firebaseDocId: m.id,
            data: {..._toQueueData(m, userId), 'order': i},
          );
        }
      }
    }
  }

  /// Initialize default payment methods untuk user baru
  Future<void> initializeDefaultPaymentMethods(String userId) async {
    final defaults = [
      {'name': 'Tunai', 'type': PaymentMethodType.cash.name, 'order': 0},
      {'name': 'Bank Mandiri', 'type': PaymentMethodType.bank.name, 'bankName': 'Bank Mandiri', 'order': 1},
      {'name': 'Bank Jatim', 'type': PaymentMethodType.bank.name, 'bankName': 'Bank Jatim', 'order': 2},
      {'name': 'Bank Jago', 'type': PaymentMethodType.bank.name, 'bankName': 'Bank Jago', 'order': 3},
      {'name': 'Dana', 'type': PaymentMethodType.wallet.name, 'order': 4},
      {'name': 'SEA BANK', 'type': PaymentMethodType.bank.name, 'bankName': 'SEA BANK', 'order': 5},
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

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _cacheToSqlite(String userId, List<PaymentMethodModel> methods) async {
    try {
      await _dao.deleteAll(userId);
      for (final m in methods) {
        await _dao.insertOrReplace(m.copyWith(userId: userId));
      }
    } catch (e) {
      debugPrint('PaymentMethodService._cacheToSqlite error: $e');
    }
  }

  Map<String, dynamic> _toQueueData(PaymentMethodModel m, String userId) => {
    'id': m.id,
    'userId': userId,
    'name': m.name,
    'type': m.type.name,
    'bankName': m.bankName,
    'accountNumber': m.accountNumber,
    'isActive': m.isActive,
    'order': m.order,
    'createdAt': (m.createdAt ?? DateTime.now()).toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };
}
