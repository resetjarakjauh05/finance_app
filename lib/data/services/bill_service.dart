import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/bill_model.dart';
import '../local/bill_dao.dart';
import '../local/pending_operations_dao.dart';
import 'connectivity_service.dart';

class BillService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BillDao _billDao = BillDao();
  final ConnectivityService _connectivity = ConnectivityService();
  final PendingOperationsDao _pendingOpsDao = PendingOperationsDao();

  CollectionReference<Map<String, dynamic>> _col(String userId) => _firestore
      .collection('bills')
      .doc(userId)
      .collection('items')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data()!,
        toFirestore: (data, _) => data,
      );

  // ===== SQLite CRUD =====

  Future<int> createBill(BillModel bill, bool isOnline) async {
    try {
      final localId = await _billDao.insert(bill.toSqlite());
      debugPrint('BillService.createBill SQLite OK localId=$localId');
      if (isOnline) {
        try {
          final docRef = await _col(bill.userId).add(_toFirestoreCreate(bill));
          await _billDao.markAsSynced(localId, docRef.id);
          debugPrint('BillService.createBill Firestore OK docId=${docRef.id}');
          return localId;
        } catch (e) {
          debugPrint('BillService.createBill Firestore ERROR: $e');
        }
      }
      // Queue hanya jika offline atau Firestore gagal
      await _pendingOpsDao.addPendingOperation(
        operation: 'CREATE',
        tableName: 'bills',
        recordId: localId,
        data: _toQueueData(bill),
      );
      return localId;
    } catch (e) {
      debugPrint('BillService.createBill SQLite ERROR: $e');
      rethrow;
    }
  }

  Future<void> updateBill(BillModel bill, bool isOnline) async {
    await _billDao.update(bill.id, bill.copyWith(updatedAt: DateTime.now()).toSqlite());
    if (isOnline && bill.firebaseDocId != null) {
      try {
        await _col(bill.userId).doc(bill.firebaseDocId).update({
          ..._toFirestore(bill),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _billDao.markAsSynced(bill.id, bill.firebaseDocId!);
        return; // BUG-2 FIX: sukses → skip queue
      } catch (e) {
        debugPrint('BillService.updateBill Firestore error: $e');
        // Firestore gagal → fall through ke queue
      }
    }
    // Offline atau Firestore gagal → queue untuk sync nanti
    await _pendingOpsDao.addPendingOperation(
      operation: 'UPDATE',
      tableName: 'bills',
      recordId: bill.id,
      firebaseDocId: bill.firebaseDocId,
      data: _toQueueData(bill),
    );
  }

  Future<void> deleteBill(int id, String userId, String? firebaseDocId, bool isOnline) async {
    await _billDao.delete(id);
    if (isOnline && firebaseDocId != null) {
      try {
        await _col(userId).doc(firebaseDocId).delete();
        return;
      } catch (_) {}
    }
    if (firebaseDocId != null) {
      await _pendingOpsDao.addPendingOperation(
        operation: 'DELETE',
        tableName: 'bills',
        recordId: id,
        firebaseDocId: firebaseDocId,
        data: {'userId': userId},
      );
    }
  }

  Future<List<BillModel>> getBills(String userId, {String? status}) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        // FIX: jangan filter isDeleted di Firestore — doc lama mungkin tidak punya
        // field tsb → Firestore skip → reinstall = kosong. Filter client-side.
        // Status filter tetap server-side (indexed).
        var query = _col(userId) as Query<Map<String, dynamic>>;
        if (status != null) {
          query = query.where('status', isEqualTo: status);
        }
        final snapshot = await query.orderBy('dueDate').get();
        final bills = <BillModel>[];
        for (final doc in snapshot.docs) {
          try {
            final bill = _fromFirestore(doc.id, doc.data());
            // Filter client-side: skip soft-deleted
            if (!bill.isDeleted) bills.add(bill);
          } catch (e) {
            debugPrint('getBills skip ${doc.id}: $e');
          }
        }
        // Cache to SQLite (await, tidak fire-and-forget)
        await _cacheBillsToSqlite(bills);

        // Merge data offline yang belum sync ke Firestore
        final allLocal = await _billDao.getAllByUserId(userId);
        final unsyncedLocal = allLocal
            .where((r) => (r['isSynced'] as int? ?? 0) == 0 && r['firebaseDocId'] == null)
            .map((r) => BillModelExtension.fromSqlite(r))
            .toList();
        if (unsyncedLocal.isNotEmpty) {
          final merged = [...bills, ...unsyncedLocal];
          merged.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return merged;
        }
        return bills;
      } catch (e) {
        debugPrint('getBills Firestore error, fallback SQLite: $e');
      }
    }
    // Offline fallback
    final rows = await _billDao.getAllByUserId(userId, status: status);
    return rows.map((r) => BillModelExtension.fromSqlite(r)).toList();
  }

  /// Realtime stream Firestore → auto-update semua device
  Stream<List<BillModel>> watchBills(String userId) async* {
    final isOnline = await _connectivity.isOnline();
    if (!isOnline) {
      // Offline → emit SQLite once
      final rows = await _billDao.getAllByUserId(userId);
      yield rows.map((r) => BillModelExtension.fromSqlite(r)).toList();
      return;
    }

    // Online → stream Firestore snapshots
    yield* _col(userId)
        .orderBy('dueDate')
        .snapshots()
        .asyncMap((snapshot) async {
      final bills = <BillModel>[];
      for (final doc in snapshot.docs) {
        try {
          final bill = _fromFirestore(doc.id, doc.data());
          if (!bill.isDeleted) bills.add(bill);
        } catch (e) {
          debugPrint('watchBills skip ${doc.id}: $e');
        }
      }
      // Cache ke SQLite
      await _cacheBillsToSqlite(bills);

      // Merge unsynced local
      final allLocal = await _billDao.getAllByUserId(userId);
      final unsyncedLocal = allLocal
          .where((r) => (r['isSynced'] as int? ?? 0) == 0 && r['firebaseDocId'] == null)
          .map((r) => BillModelExtension.fromSqlite(r))
          .toList();
      if (unsyncedLocal.isNotEmpty) {
        final merged = [...bills, ...unsyncedLocal];
        merged.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        return merged;
      }
      return bills;
    });
  }

  /// Parse Firestore doc → BillModel
  BillModel _fromFirestore(String docId, Map<String, dynamic> data) {
    return BillModel(
      id: 0,
      firebaseDocId: docId,
      userId: data['userId'] as String,
      name: data['name'] as String,
      nominal: (data['nominal'] as num).toInt(),
      paidAmount: (data['paidAmount'] as num?)?.toInt() ?? 0,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: BillStatusExtension.fromString(data['status'] as String? ?? 'UNPAID'),
      type: BillTypeExtension.fromString(data['type'] as String? ?? 'HUTANG'),
      category: data['category'] as String?,
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      notes: data['notes'] as String?,
      paymentMethodId: data['paymentMethodId'] as String?,
      paymentMethodName: data['paymentMethodName'] as String?,
      transferFee: (data['transferFee'] as num?)?.toInt() ?? 0,
      billingDay: (data['billingDay'] as num?)?.toInt(),
      maxInstallments: (data['maxInstallments'] as num?)?.toInt(),
      installmentAmount: (data['installmentAmount'] as num?)?.toInt(),
      installmentsPaid: (data['installmentsPaid'] as num?)?.toInt() ?? 0,
      // FIX: doc lama mungkin tidak punya field isDeleted → default false
      isDeleted: (data['isDeleted'] as bool?) ?? false,
      isSynced: true,
      syncedAt: DateTime.now(),
      localCreatedAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Cache Firestore bills to SQLite
  Future<void> _cacheBillsToSqlite(List<BillModel> bills) async {
    try {
      for (final b in bills) {
        if (b.firebaseDocId == null) continue;
        final existing = await _billDao.getByFirebaseDocId(b.firebaseDocId!);
        if (existing == null) {
          // BUG-06 FIX: insert baru
          final localId = await _billDao.insert(b.toSqlite());
          await _billDao.markAsSynced(localId, b.firebaseDocId!);
        } else {
          final localId = existing['id'] as int;
          final isLocalUnsynced = (existing['isSynced'] as int? ?? 0) == 0;
          if (isLocalUnsynced) {
            // Record lokal belum sync ke Firestore (bayar offline, dll)
            // → skip overwrite agar paidAmount/status lokal tidak hilang.
            // SyncEngine akan push data lokal ke Firestore saat online.
            debugPrint('_cacheBillsToSqlite: skip overwrite localId=$localId (unsynced local)');
            continue;
          }
          // Record sudah synced → overwrite dengan data Firestore
          // KECUALI progress lokal lebih baru (bayar online baru saja)
          final localPaidAmount = (existing['paidAmount'] as int?) ?? 0;
          final localInstallmentsPaid = (existing['installmentsPaid'] as int?) ?? 0;
          final firestorePaidAmount = b.paidAmount;
          final firestoreInstallmentsPaid = b.installmentsPaid;

          if (localPaidAmount > firestorePaidAmount ||
              localInstallmentsPaid > firestoreInstallmentsPaid) {
            // Data lokal lebih maju → skip overwrite, SyncEngine akan push ke Firestore
            debugPrint('_cacheBillsToSqlite: skip overwrite localId=$localId (local progress ahead: paid=$localPaidAmount vs $firestorePaidAmount)');
            continue;
          }
          await _billDao.update(localId, b.copyWith(id: localId).toSqlite());
          await _billDao.markAsSynced(localId, b.firebaseDocId!);
        }
      }
    } catch (e) {
      debugPrint('_cacheBillsToSqlite error: $e');
    }
  }

  Map<String, dynamic> _toFirestore(BillModel b) => {
    'userId': b.userId,
    'name': b.name,
    'nominal': b.nominal,
    'paidAmount': b.paidAmount,
    'dueDate': Timestamp.fromDate(b.dueDate),
    'status': b.status.name,
    'type': b.type.name,
    'category': b.category,
    'categoryId': b.categoryId,
    'categoryName': b.categoryName,
    'notes': b.notes,
    'paymentMethodId': b.paymentMethodId,
    'paymentMethodName': b.paymentMethodName,
    'transferFee': b.transferFee,
    'billingDay': b.billingDay,
    'maxInstallments': b.maxInstallments,
    'installmentAmount': b.installmentAmount,
    'installmentsPaid': b.installmentsPaid,
    'isDeleted': b.isDeleted,
    'updatedAt': b.updatedAt != null
        ? Timestamp.fromDate(b.updatedAt!)
        : FieldValue.serverTimestamp(),
  };

  /// Khusus untuk create — include createdAt via serverTimestamp
  Map<String, dynamic> _toFirestoreCreate(BillModel b) => {
    ..._toFirestore(b),
    'createdAt': FieldValue.serverTimestamp(),
  };

  /// Untuk pending_operations queue — tanpa Timestamp/FieldValue (JSON-safe)
  Map<String, dynamic> _toQueueData(BillModel b) => {
    'userId': b.userId,
    'name': b.name,
    'nominal': b.nominal,
    'paidAmount': b.paidAmount,
    'dueDate': b.dueDate.toIso8601String(),
    'status': b.status.name,
    'type': b.type.name,
    'category': b.category,
    'categoryId': b.categoryId,
    'categoryName': b.categoryName,
    'notes': b.notes,
    'paymentMethodId': b.paymentMethodId,
    'paymentMethodName': b.paymentMethodName,
    'transferFee': b.transferFee,
    'billingDay': b.billingDay,
    'maxInstallments': b.maxInstallments,
    'installmentAmount': b.installmentAmount,
    'installmentsPaid': b.installmentsPaid,
    'updatedAt': b.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    'createdAt': DateTime.now().toIso8601String(),
  };
}
