import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/custody_model.dart';
import '../../domain/models/custody_movement_model.dart';
import '../local/custody_dao.dart';
import '../local/custody_movement_dao.dart';
import '../local/pending_operations_dao.dart';
import 'connectivity_service.dart';

class CustodyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CustodyDao _custodyDao = CustodyDao();
  final CustodyMovementDao _movementDao = CustodyMovementDao();
  final ConnectivityService _connectivity = ConnectivityService();
  final PendingOperationsDao _pendingOpsDao = PendingOperationsDao();

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
        // Online berhasil → tidak perlu queue pending operation
        return localId;
      } catch (e) {
        debugPrint('CustodyService.createCustody Firestore: $e');
        // Firestore gagal → fallthrough ke pending queue
      }
    }
    // Hanya queue jika offline ATAU Firestore gagal (bukan keduanya)
    await _pendingOpsDao.addPendingOperation(
      operation: 'CREATE',
      tableName: 'custody',
      recordId: localId,
      data: _toQueueData(custody),
    );
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
        return;
      } catch (e) {
        debugPrint('CustodyService.updateCustody Firestore: $e');
      }
    }
    await _pendingOpsDao.addPendingOperation(
      operation: 'UPDATE',
      tableName: 'custody',
      recordId: custody.id,
      firebaseDocId: custody.firebaseDocId,
      data: _toQueueData(custody),
    );
  }

  Future<void> deleteCustody(
      int id, String userId, String? firebaseDocId, bool isOnline) async {
    await _custodyDao.delete(id);
    if (isOnline && firebaseDocId != null) {
      try {
        await _col(userId).doc(firebaseDocId).delete();
        return;
      } catch (e) {
        debugPrint('CustodyService.deleteCustody Firestore: $e');
      }
    }
    if (firebaseDocId != null) {
      await _pendingOpsDao.addPendingOperation(
        operation: 'DELETE',
        tableName: 'custody',
        recordId: id,
        firebaseDocId: firebaseDocId,
        data: {'userId': userId},
      );
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
            final c = _custodyFromFirestore(doc.id, doc.data() as Map<String, dynamic>);
            // Filter client-side: skip soft-deleted
            if (!c.isDeleted) custodies.add(c);
          } catch (e) {
            debugPrint('getCustodies skip ${doc.id}: $e');
          }
        }
        // Sort client-side
        custodies.sort((a, b) => b.localCreatedAt.compareTo(a.localCreatedAt));
        await _cacheCustodiesToSqlite(custodies);

        // FIX BUG-1: Ambil SEMUA local records (termasuk yang baru dibuat online
        // tapi belum muncul di Firestore snapshot karena eventual consistency).
        // Filter: isSynced=0 (belum sync) ATAU baru sync tapi belum ada di snapshot Firestore.
        final allLocal = await _custodyDao.getAllByUserId(userId);
        final firestoreDocIds = custodies.map((c) => c.firebaseDocId).toSet();
        final missingFromSnapshot = allLocal
            .where((r) {
              final docId = r['firebaseDocId'] as String?;
              final isSynced = (r['isSynced'] as int? ?? 0) == 1;
              // Belum sync (offline baru) ATAU sudah sync tapi snapshot belum include
              if ((r['isSynced'] as int? ?? 0) == 0 && docId == null) return true;
              // Sudah punya firebaseDocId tapi tidak ada di snapshot (stale snapshot)
              if (isSynced && docId != null && !firestoreDocIds.contains(docId)) return true;
              return false;
            })
            .map((r) => CustodyModel.fromSqlite(r))
            .toList();

        if (missingFromSnapshot.isNotEmpty) {
          final merged = [...custodies, ...missingFromSnapshot];
          merged.sort((a, b) => b.localCreatedAt.compareTo(a.localCreatedAt));
          return merged;
        }

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
        } else {
          final localId = existing['id'] as int;
          final localBalance = existing['currentBalance'] as int? ?? 0;
          final firestoreBalance = c.currentBalance;

          // Cek pending unsynced movements di tabel custody_movements
          // (bukan isSynced di custody row — itu flag sync untuk custody record sendiri)
          final hasPendingMovements = await _movementDao.hasUnsyncedMovements(localId);

          // Jika ada unsynced movements → SQLite lebih fresh → pakai localBalance
          // Jika tidak → recalculate dari SQLite movements untuk hindari Firestore eventual consistency
          int balance;
          if (hasPendingMovements) {
            balance = localBalance;
          } else {
            // Recalculate dari SQLite movements — source of truth yang paling fresh
            final recalculated = await _movementDao.calculateBalance(localId);
            // Jika recalculated > 0 pakai recalculated, fallback ke max(local, firestore)
            balance = recalculated > 0
                ? recalculated
                : (localBalance > firestoreBalance ? localBalance : firestoreBalance);
          }

          await _custodyDao.update(localId, {
            ...c.toSqlite(),
            'id': localId,
            'isSynced': 1,
            'currentBalance': balance,
          });
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
        return localId;
      } catch (e) {
        debugPrint('CustodyService.addMovement Firestore: $e');
      }
    }
    // FIX Bug #4: selalu queue movement, meski custodyFirebaseDocId null
    // (custody bisa dibuat offline → belum punya firebaseDocId).
    // Simpan custodyLocalId agar SyncEngine bisa resolve firebaseDocId nanti.
    await _pendingOpsDao.addPendingOperation(
      operation: 'CREATE',
      tableName: 'custody_movements',
      recordId: localId,
      data: {
        'userId': userId,
        'custodyLocalId': movement.custodyId,
        'custodyFirebaseDocId': custodyFirebaseDocId, // null ok — resolved saat sync
        'movementType': movement.movementType.name,
        'nominal': movement.nominal,
        'date': movement.date.toIso8601String(),
        'description': movement.description,
        'createdAt': movement.localCreatedAt.toIso8601String(),
      },
    );
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
        // Cache ke SQLite agar tersedia offline
        await _cacheMovementsToSqlite(movements);

        // Merge movements offline yang belum sync
        final allLocal = await _movementDao.getByCustodyId(custodyId);
        final unsyncedLocal = allLocal
            .where((r) => (r['isSynced'] as int? ?? 0) == 0 && r['firebaseDocId'] == null)
            .map((r) => CustodyMovementModel.fromSqlite(r))
            .toList();
        if (unsyncedLocal.isNotEmpty) {
          final merged = [...movements, ...unsyncedLocal];
          merged.sort((a, b) => b.date.compareTo(a.date));
          return merged;
        }
        return movements;
      } catch (e) {
        debugPrint('getMovements Firestore error, fallback: $e');
      }
    }
    final rows = await _movementDao.getByCustodyId(custodyId);
    return rows.map((r) => CustodyMovementModel.fromSqlite(r)).toList();
  }

  Future<void> _cacheMovementsToSqlite(List<CustodyMovementModel> movements) async {
    try {
      for (final m in movements) {
        if (m.firebaseDocId == null) continue;
        final existing = await _movementDao.getByFirebaseDocId(m.firebaseDocId!);
        if (existing == null) {
          final localId = await _movementDao.insert(m.toSqlite());
          await _movementDao.markAsSynced(localId, m.firebaseDocId!);
        } else {
          final localId = existing['id'] as int;
          await _movementDao.update(localId, {
            ...m.toSqlite(),
            'id': localId,
            'isSynced': 1,
          });
        }
      }
    } catch (e) {
      debugPrint('_cacheMovementsToSqlite: $e');
    }
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
    'createdAt': c.localCreatedAt.toIso8601String(),
  };

  /// JSON-safe untuk pending_operations queue
  Map<String, dynamic> _toQueueData(CustodyModel c) => {
    'userId': c.userId,
    'depositorName': c.depositorName,
    'description': c.description,
    'totalNominal': c.totalNominal,
    'type': c.type.name,
    'currentBalance': c.currentBalance,
    'createdAt': c.localCreatedAt.toIso8601String(),
  };

  Map<String, dynamic> _toMovFirestore(CustodyMovementModel m) => {
    'movementType': m.movementType.name,
    'nominal': m.nominal,
    'transferFee': m.transferFee,
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
      isDeleted: (data['isDeleted'] as bool?) ?? false,
      isSynced: true,
      syncedAt: DateTime.now(),
      localCreatedAt: _parseDateTime(data['createdAt']),
    );
  }

  /// Parse DateTime — handle Timestamp (Firestore) atau String ISO (doc lama)
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
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
      transferFee: (data['transferFee'] as num?)?.toInt() ?? 0,
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
