import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/custody_model.dart';
import '../../domain/models/custody_movement_model.dart';
import '../local/custody_dao.dart';
import '../local/custody_movement_dao.dart';
import 'connectivity_service.dart';

class CustodyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CustodyDao _custodyDao = CustodyDao();
  final CustodyMovementDao _movementDao = CustodyMovementDao();
  final ConnectivityService _connectivity = ConnectivityService();

  CollectionReference _col(String userId) =>
      _firestore.collection('custody').doc(userId).collection('items');

  CollectionReference _movCol(String userId, String custodyFirebaseDocId) =>
      _col(userId).doc(custodyFirebaseDocId).collection('movements');

  // ===== CUSTODY CRUD =====

  Future<int> createCustody(CustodyModel custody, bool isOnline) async {
    final localId = await _custodyDao.insert(custody.toSqlite());
    if (isOnline) {
      try {
        final docRef = await _col(custody.userId).add(_toFirestore(custody));
        await _custodyDao.markAsSynced(localId, docRef.id);
      } catch (e) {
        debugPrint('CustodyService.createCustody Firestore: $e');
      }
    }
    return localId;
  }

  Future<void> updateCustody(CustodyModel custody, bool isOnline) async {
    await _custodyDao.update(
        custody.id, custody.copyWith(updatedAt: DateTime.now()).toSqlite());
    if (isOnline && custody.firebaseDocId != null) {
      try {
        await _col(custody.userId).doc(custody.firebaseDocId).update({
          ..._toFirestore(custody),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _custodyDao.markAsSynced(custody.id, custody.firebaseDocId!);
      } catch (e) {
        debugPrint('CustodyService.updateCustody Firestore: $e');
      }
    }
  }

  Future<void> deleteCustody(
      int id, String userId, String? firebaseDocId, bool isOnline) async {
    await _custodyDao.delete(id);
    if (isOnline && firebaseDocId != null) {
      try {
        await _col(userId).doc(firebaseDocId).delete();
      } catch (e) {
        debugPrint('CustodyService.deleteCustody Firestore: $e');
      }
    }
  }

  Future<List<CustodyModel>> getCustodies(String userId) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snapshot = await _col(userId).get();
        final custodies = <CustodyModel>[];
        for (final doc in snapshot.docs) {
          try {
            custodies.add(_custodyFromFirestore(doc.id, doc.data() as Map<String, dynamic>));
          } catch (e) {
            debugPrint('getCustodies skip ${doc.id}: $e');
          }
        }
        // Sort client-side
        custodies.sort((a, b) => b.localCreatedAt.compareTo(a.localCreatedAt));
        _cacheCustodiesToSqlite(custodies);
        return custodies;
      } catch (e) {
        debugPrint('getCustodies Firestore error, fallback SQLite: $e');
      }
    }
    final rows = await _custodyDao.getAllByUserId(userId);
    return rows.map((r) => CustodyModel.fromSqlite(r)).toList();
  }

  Future<void> _cacheCustodiesToSqlite(List<CustodyModel> custodies) async {
    try {
      for (final c in custodies) {
        if (c.firebaseDocId == null) continue;
        final existing = await _custodyDao.getByFirebaseDocId(c.firebaseDocId!);
        if (existing == null) {
          final localId = await _custodyDao.insert(c.toSqlite());
          await _custodyDao.markAsSynced(localId, c.firebaseDocId!);
        }
      }
    } catch (e) {
      debugPrint('_cacheCustodiesToSqlite: $e');
    }
  }

  // ===== MOVEMENT CRUD =====

  Future<int> addMovement(
      CustodyMovementModel movement, String userId, String? custodyFirebaseDocId, bool isOnline) async {
    final localId = await _movementDao.insert(movement.toSqlite());
    if (isOnline && custodyFirebaseDocId != null) {
      try {
        final docRef = await _movCol(userId, custodyFirebaseDocId).add(_toMovFirestore(movement));
        await _movementDao.markAsSynced(localId, docRef.id);
      } catch (e) {
        debugPrint('CustodyService.addMovement Firestore: $e');
      }
    }
    return localId;
  }

  Future<List<CustodyMovementModel>> getMovements(
      int custodyId, String userId, String? custodyFirebaseDocId) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline && custodyFirebaseDocId != null) {
      try {
        final snapshot = await _movCol(userId, custodyFirebaseDocId)
            .orderBy('date', descending: true)
            .get();
        final movements = <CustodyMovementModel>[];
        for (final doc in snapshot.docs) {
          try {
            movements.add(_movFromFirestore(doc.id, custodyId, custodyFirebaseDocId, doc.data() as Map<String, dynamic>));
          } catch (e) {
            debugPrint('getMovements skip ${doc.id}: $e');
          }
        }
        return movements;
      } catch (e) {
        debugPrint('getMovements Firestore error, fallback: $e');
      }
    }
    final rows = await _movementDao.getByCustodyId(custodyId);
    return rows.map((r) => CustodyMovementModel.fromSqlite(r)).toList();
  }

  Future<int> calculateBalance(int custodyId) async {
    return await _movementDao.calculateBalance(custodyId);
  }

  // ===== FIRESTORE CONVERTERS =====

  Map<String, dynamic> _toFirestore(CustodyModel c) => {
    'userId': c.userId,
    'depositorName': c.depositorName,
    'description': c.description,
    'totalNominal': c.totalNominal,
    'type': c.type.name,
    'currentBalance': c.currentBalance,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> _toMovFirestore(CustodyMovementModel m) => {
    'movementType': m.movementType.name,
    'nominal': m.nominal,
    'date': Timestamp.fromDate(m.date),
    'description': m.description,
    'createdAt': FieldValue.serverTimestamp(),
  };

  CustodyModel _custodyFromFirestore(String docId, Map<String, dynamic> data) {
    return CustodyModel(
      id: 0,
      firebaseDocId: docId,
      userId: data['userId'] as String,
      depositorName: data['depositorName'] as String,
      description: data['description'] as String?,
      totalNominal: (data['totalNominal'] as num).toInt(),
      type: CustodyTypeExtension.fromString(data['type'] as String? ?? 'DITERIMA'),
      currentBalance: (data['currentBalance'] as num?)?.toInt() ?? 0,
      isSynced: true,
      syncedAt: DateTime.now(),
      localCreatedAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  CustodyMovementModel _movFromFirestore(
      String docId, int custodyId, String custodyFirebaseDocId, Map<String, dynamic> data) {
    return CustodyMovementModel(
      id: 0,
      firebaseDocId: docId,
      custodyId: custodyId,
      custodyFirebaseDocId: custodyFirebaseDocId,
      movementType: MovementTypeExtension.fromString(data['movementType'] as String? ?? 'MASUK'),
      nominal: (data['nominal'] as num).toInt(),
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] as String?,
      isSynced: true,
      syncedAt: DateTime.now(),
      localCreatedAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
