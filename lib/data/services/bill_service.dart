import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/bill_model.dart';
import '../local/bill_dao.dart';
import 'connectivity_service.dart';

class BillService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BillDao _billDao = BillDao();
  final ConnectivityService _connectivity = ConnectivityService();

  CollectionReference _col(String userId) => _firestore
      .collection('bills')
      .doc(userId)
      .collection('items');

  // ===== SQLite CRUD =====

  Future<int> createBill(BillModel bill, bool isOnline) async {
    try {
      final localId = await _billDao.insert(bill.toSqlite());
      debugPrint('BillService.createBill SQLite OK localId=$localId');
      if (isOnline) {
        try {
          final docRef = await _col(bill.userId).add(_toFirestore(bill));
          await _billDao.markAsSynced(localId, docRef.id);
          debugPrint('BillService.createBill Firestore OK docId=${docRef.id}');
        } catch (e) {
          debugPrint('BillService.createBill Firestore ERROR: $e');
        }
      }
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
      } catch (e) {
        debugPrint('BillService.updateBill Firestore error: $e');
      }
    }
  }

  Future<void> deleteBill(int id, String userId, String? firebaseDocId, bool isOnline) async {
    await _billDao.delete(id);
    if (isOnline && firebaseDocId != null) {
      try {
        await _col(userId).doc(firebaseDocId).delete();
      } catch (_) {}
    }
  }

  Future<List<BillModel>> getBills(String userId, {String? status}) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        var query = _col(userId) as Query<Map<String, dynamic>>;
        if (status != null) {
          query = query.where('status', isEqualTo: status);
        }
        final snapshot = await query.orderBy('dueDate').get();
        final bills = <BillModel>[];
        for (final doc in snapshot.docs) {
          try {
            bills.add(_fromFirestore(doc.id, doc.data()));
          } catch (e) {
            debugPrint('getBills skip ${doc.id}: $e');
          }
        }
        // Cache to SQLite
        _cacheBillsToSqlite(bills);
        return bills;
      } catch (e) {
        debugPrint('getBills Firestore error, fallback SQLite: $e');
      }
    }
    // Offline fallback
    final rows = await _billDao.getAllByUserId(userId, status: status);
    return rows.map((r) => BillModelExtension.fromSqlite(r)).toList();
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
      notes: data['notes'] as String?,
      isSynced: true,
      syncedAt: DateTime.now(),
      localCreatedAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Cache Firestore bills to SQLite
  Future<void> _cacheBillsToSqlite(List<BillModel> bills) async {
    try {
      for (final b in bills) {
        if (b.firebaseDocId == null) continue;
        final existing = await _billDao.getByFirebaseDocId(b.firebaseDocId!);
        if (existing == null) {
          final localId = await _billDao.insert(b.toSqlite());
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
    'notes': b.notes,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
