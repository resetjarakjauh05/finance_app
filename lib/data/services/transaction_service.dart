import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/transaction_model.dart';
import '../local/transaction_dao.dart';
import '../local/pending_operations_dao.dart';
import '../local/sync_log_dao.dart';
import 'connectivity_service.dart';

/// Service untuk transaction operations (Firebase-first, SQLite fallback)
class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionDao _transactionDao = TransactionDao();
  final PendingOperationsDao _pendingOpsDao = PendingOperationsDao();
  final SyncLogDao _syncLogDao = SyncLogDao();
  final ConnectivityService _connectivity = ConnectivityService();

  /// Create transaction (offline-first)
  Future<int> createTransaction(
    TransactionModel transaction,
    bool isOnline,
  ) async {
    // 1. Save to SQLite immediately
    final localId = await _transactionDao.insert(transaction.toSqlite());

    // 2. If online, also save to Firestore
    if (isOnline) {
      try {
        final docRef = await _saveToFirestore(transaction);
        
        // Mark as synced
        await _transactionDao.markAsSynced(localId, docRef.id);
        
        // Log success
        await _syncLogDao.addLog(
          operation: 'CREATE',
          entityType: 'TRANSACTION',
          entityId: localId,
          firebaseDocId: docRef.id,
          status: 'SUCCESS',
        );
      } catch (e) {
        // If Firestore fails, queue for later sync
        await _queueForSync(localId, transaction, 'CREATE');
        
        // Log failure
        await _syncLogDao.addLog(
          operation: 'CREATE',
          entityType: 'TRANSACTION',
          entityId: localId,
          status: 'FAILED',
          error: e.toString(),
        );
      }
    } else {
      // Offline: queue for sync
      await _queueForSync(localId, transaction, 'CREATE');
    }

    return localId;
  }

  /// Update transaction
  Future<void> updateTransaction(
    TransactionModel transaction,
    bool isOnline,
  ) async {
    // 1. Update SQLite
    await _transactionDao.update(
      transaction.id,
      transaction.copyWith(updatedAt: DateTime.now()).toSqlite(),
    );

    // 2. If online and has firebaseDocId, update Firestore
    if (isOnline && transaction.firebaseDocId != null) {
      try {
        await _updateFirestore(transaction);
        
        // Mark as synced
        await _transactionDao.markAsSynced(
          transaction.id,
          transaction.firebaseDocId!,
        );
        
        // Log success
        await _syncLogDao.addLog(
          operation: 'UPDATE',
          entityType: 'TRANSACTION',
          entityId: transaction.id,
          firebaseDocId: transaction.firebaseDocId,
          status: 'SUCCESS',
        );
      } catch (e) {
        // Queue for sync
        await _queueForSync(transaction.id, transaction, 'UPDATE');
        
        // Log failure
        await _syncLogDao.addLog(
          operation: 'UPDATE',
          entityType: 'TRANSACTION',
          entityId: transaction.id,
          firebaseDocId: transaction.firebaseDocId,
          status: 'FAILED',
          error: e.toString(),
        );
      }
    } else {
      // Queue for sync
      await _queueForSync(transaction.id, transaction, 'UPDATE');
    }
  }

  /// Delete transaction (soft delete)
  Future<void> deleteTransaction(
    int id,
    String userId,
    String? firebaseDocId,
    bool isOnline,
  ) async {
    // 1. Soft delete in SQLite
    await _transactionDao.delete(id);

    // 2. If online and has firebaseDocId, delete from Firestore
    if (isOnline && firebaseDocId != null) {
      try {
        await _deleteFromFirestore(userId, firebaseDocId);
        
        // Log success
        await _syncLogDao.addLog(
          operation: 'DELETE',
          entityType: 'TRANSACTION',
          entityId: id,
          firebaseDocId: firebaseDocId,
          status: 'SUCCESS',
        );
      } catch (e) {
        // Queue for sync
        await _pendingOpsDao.addPendingOperation(
          operation: 'DELETE',
          tableName: 'transactions',
          recordId: id,
          firebaseDocId: firebaseDocId,
          data: {'id': id},
        );
        
        // Log failure
        await _syncLogDao.addLog(
          operation: 'DELETE',
          entityType: 'TRANSACTION',
          entityId: id,
          firebaseDocId: firebaseDocId,
          status: 'FAILED',
          error: e.toString(),
        );
      }
    } else {
      // Queue for sync if has firebaseDocId
      if (firebaseDocId != null) {
        await _pendingOpsDao.addPendingOperation(
          operation: 'DELETE',
          tableName: 'transactions',
          recordId: id,
          firebaseDocId: firebaseDocId,
          data: {'id': id},
        );
      }
    }
  }

  /// Get transactions (Firestore-first, SQLite fallback)
  Future<List<TransactionModel>> getTransactions(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        Query<Map<String, dynamic>> query = _firestore
            .collection('transactions')
            .doc(userId)
            .collection('items')
            .orderBy('date', descending: true);
        if (limit != null) query = query.limit(limit);
        final snapshot = await query.get();
        final transactions = <TransactionModel>[];
        for (final doc in snapshot.docs) {
          final t = _fromFirestore(doc.id, doc.data(), fallbackUserId: userId);
          if (t != null) transactions.add(t);
        }
        // Cache to SQLite
        await _cacheTransactionsToSqlite(userId, transactions);

        // Merge data offline yang belum sync ke Firestore
        final allLocal = await _transactionDao.getAllByUserId(userId);
        final unsyncedLocal = allLocal
            .where((r) => (r['isSynced'] as int? ?? 0) == 0 && r['firebaseDocId'] == null)
            .map((m) => TransactionModelExtension.fromSqlite(m))
            .toList();
        if (unsyncedLocal.isNotEmpty) {
          final merged = [...transactions, ...unsyncedLocal];
          merged.sort((a, b) => b.date.compareTo(a.date));
          if (limit != null && merged.length > limit) {
            return merged.take(limit).toList();
          }
          return merged;
        }
        return transactions;
      } catch (e) {
        debugPrint('getTransactions Firestore error, fallback SQLite: $e');
      }
    }
    // Offline fallback: SQLite
    final results = await _transactionDao.getAllByUserId(userId, limit: limit, offset: offset);
    return results.map((m) => TransactionModelExtension.fromSqlite(m)).toList();
  }

  /// Cache Firestore transactions to SQLite
  Future<void> _cacheTransactionsToSqlite(String userId, List<TransactionModel> transactions) async {
    try {
      for (final t in transactions) {
        final existing = await _transactionDao.getByFirebaseDocId(t.firebaseDocId ?? '');
        if (existing == null) {
          // Insert baru
          final localId = await _transactionDao.insert(t.toSqlite());
          if (t.firebaseDocId != null) {
            await _transactionDao.markAsSynced(localId, t.firebaseDocId!);
          }
        } else {
          // Update existing agar data terkini
          final localId = existing['id'] as int;
          await _transactionDao.update(localId, {
            ...t.toSqlite(),
            'id': localId,
            'isSynced': 1,
          });
        }
      }
    } catch (e) {
      debugPrint('_cacheTransactionsToSqlite error: $e');
    }
  }

  /// Parse Firestore doc → TransactionModel
  TransactionModel? _fromFirestore(String docId, Map<String, dynamic> data, {String? fallbackUserId}) {
    try {
      final userId = (data['userId'] as String?) ?? fallbackUserId;
      final description = data['description'] as String?;
      final paymentMethodId = data['paymentMethodId'] as String?;
      final paymentMethodName = data['paymentMethodName'] as String?;
      final nominal = data['nominal'];
      final date = data['date'];
      final categoryStr = data['category'] as String?;

      if (userId == null || description == null || paymentMethodId == null ||
          paymentMethodName == null || nominal == null || date == null ||
          categoryStr == null) {
        debugPrint('_fromFirestore skip $docId: missing required field');
        return null;
      }

      return TransactionModel(
        id: 0,
        firebaseDocId: docId,
        userId: userId,
        description: description,
        category: TransactionCategory.values.firstWhere(
          (e) => e.name == categoryStr,
          orElse: () => TransactionCategory.expense,
        ),
        paymentMethodId: paymentMethodId,
        paymentMethodName: paymentMethodName,
        nominal: (nominal as num).toInt(),
        date: (date as Timestamp).toDate(),
        notes: data['notes'] as String?,
        categoryId: data['categoryId'] as String?,
        categoryName: data['categoryName'] as String?,
        isSynced: true,
        syncedAt: DateTime.now(),
        localCreatedAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint('_fromFirestore error $docId: $e');
      return null;
    }
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    final result = await _transactionDao.getById(id);
    if (result == null) return null;
    return TransactionModelExtension.fromSqlite(result);
  }

  /// Search transactions (Firestore-first via local cache, SQLite search)
  Future<List<TransactionModel>> searchTransactions(
    String userId,
    String query,
  ) async {
    // Ensure cache up to date
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snapshot = await _firestore
            .collection('transactions')
            .doc(userId)
            .collection('items')
            .get();
        final transactions = snapshot.docs
            .map((d) => _fromFirestore(d.id, d.data(), fallbackUserId: userId))
            .whereType<TransactionModel>()
            .toList();
        _cacheTransactionsToSqlite(userId, transactions);
      } catch (_) {}
    }
    // Search in SQLite
    final results = await _transactionDao.search(userId, query);
    return results.map((m) => TransactionModelExtension.fromSqlite(m)).toList();
  }

  /// Filter transactions (Firestore-first via local cache, SQLite filter)
  Future<List<TransactionModel>> filterTransactions(
    String userId, {
    String? category,
    String? paymentMethodId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Ensure cache up to date
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snapshot = await _firestore
            .collection('transactions')
            .doc(userId)
            .collection('items')
            .get();
        final transactions = snapshot.docs
            .map((d) => _fromFirestore(d.id, d.data(), fallbackUserId: userId))
            .whereType<TransactionModel>()
            .toList();
        _cacheTransactionsToSqlite(userId, transactions);
      } catch (_) {}
    }
    // Filter in SQLite
    final results = await _transactionDao.filter(
      userId,
      category: category,
      paymentMethodId: paymentMethodId,
      startDate: startDate?.millisecondsSinceEpoch,
      endDate: endDate?.millisecondsSinceEpoch,
    );
    return results.map((m) => TransactionModelExtension.fromSqlite(m)).toList();
  }

  /// Initial sync: Firestore → SQLite (saat login pertama / fresh install)
  Future<void> initialSyncFromFirestore(String userId) async {
    try {
      // Cek apakah SQLite sudah ada data
      final localCount = await _transactionDao.getAllByUserId(userId);
      if (localCount.isNotEmpty) return; // Sudah ada data lokal, skip

      // Fetch dari Firestore
      final snapshot = await _firestore
          .collection('transactions')
          .doc(userId)
          .collection('items')
          .orderBy('date', descending: true)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        try {
          final transaction = TransactionModel(
            id: 0,
            firebaseDocId: doc.id,
            userId: userId,
            description: data['description'] as String,
            category: TransactionCategory.values.firstWhere(
              (e) => e.name == data['category'],
            ),
            paymentMethodId: data['paymentMethodId'] as String,
            paymentMethodName: data['paymentMethodName'] as String,
            nominal: (data['nominal'] as num).toInt(),
            date: (data['date'] as Timestamp).toDate(),
            notes: data['notes'] as String?,
            isSynced: true,
            syncedAt: DateTime.now(),
            localCreatedAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
          );
          final localId = await _transactionDao.insert(transaction.toSqlite());
          await _transactionDao.markAsSynced(localId, doc.id);
        } catch (e) {
          debugPrint('initialSync skip doc ${doc.id}: $e');
        }
      }
      debugPrint('initialSync done: ${snapshot.docs.length} transactions');
    } catch (e) {
      debugPrint('initialSyncFromFirestore error: $e');
    }
  }

  /// Get saldo per payment method
  Future<Map<String, int>> getBalancePerPaymentMethod(String userId) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snap = await _firestore
            .collection('transactions')
            .doc(userId)
            .collection('items')
            .get();
        final Map<String, int> balances = {};
        for (final doc in snap.docs) {
          final data = doc.data();
          // Skip deleted
          if (data['isDeleted'] == true) continue;
          final id = data['paymentMethodId'] as String? ?? '';
          if (id.isEmpty) continue;
          final nominal = (data['nominal'] as num?)?.toInt() ?? 0;
          final cat = data['category'] as String? ?? '';
          balances[id] = (balances[id] ?? 0) +
              (cat == 'income' ? nominal : -nominal);
        }
        return balances;
      } catch (e) {
        debugPrint('getBalancePerPaymentMethod Firestore error, fallback: $e');
      }
    }
    return await _transactionDao.getBalancePerPaymentMethod(userId);
  }

  /// Get total by category — Firestore-first, fallback SQLite
  Future<int> getTotalByCategory(String userId, String category) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snap = await _firestore
            .collection('transactions')
            .doc(userId)
            .collection('items')
            .where('category', isEqualTo: category)
            .get();
        int total = 0;
        for (final doc in snap.docs) {
          if (doc.data()['isDeleted'] == true) continue;
          total += (doc.data()['nominal'] as num?)?.toInt() ?? 0;
        }
        return total;
      } catch (e) {
        debugPrint('getTotalByCategory Firestore error, fallback SQLite: $e');
      }
    }
    return await _transactionDao.getTotalByCategory(userId, category);
  }

  /// Get unsynced transactions count
  Future<int> getUnsyncedCount(String userId) async {
    final unsynced = await _transactionDao.getUnsyncedByUserId(userId);
    return unsynced.length;
  }

  // ===== Private Helper Methods =====

  /// Save to Firestore
  Future<DocumentReference> _saveToFirestore(
    TransactionModel transaction,
  ) async {
    return await _firestore
        .collection('transactions')
        .doc(transaction.userId)
        .collection('items')
        .add({
      'userId': transaction.userId,
      'description': transaction.description,
      'category': transaction.category.name,
      'paymentMethodId': transaction.paymentMethodId,
      'paymentMethodName': transaction.paymentMethodName,
      'nominal': transaction.nominal,
      'date': Timestamp.fromDate(transaction.date),
      'notes': transaction.notes,
      'categoryId': transaction.categoryId,
      'categoryName': transaction.categoryName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update Firestore
  Future<void> _updateFirestore(TransactionModel transaction) async {
    await _firestore
        .collection('transactions')
        .doc(transaction.userId)
        .collection('items')
        .doc(transaction.firebaseDocId)
        .update({
      'userId': transaction.userId,
      'description': transaction.description,
      'category': transaction.category.name,
      'paymentMethodId': transaction.paymentMethodId,
      'paymentMethodName': transaction.paymentMethodName,
      'nominal': transaction.nominal,
      'date': Timestamp.fromDate(transaction.date),
      'notes': transaction.notes,
      'categoryId': transaction.categoryId,
      'categoryName': transaction.categoryName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete from Firestore
  Future<void> _deleteFromFirestore(
    String userId,
    String firebaseDocId,
  ) async {
    await _firestore
        .collection('transactions')
        .doc(userId)
        .collection('items')
        .doc(firebaseDocId)
        .delete();
  }

  /// Queue operation for later sync
  Future<void> _queueForSync(
    int localId,
    TransactionModel transaction,
    String operation,
  ) async {
    await _pendingOpsDao.addPendingOperation(
      operation: operation,
      tableName: 'transactions',
      recordId: localId,
      firebaseDocId: transaction.firebaseDocId,
      data: {
        'id': transaction.id,
        'userId': transaction.userId,
        'description': transaction.description,
        'category': transaction.category.name,
        'paymentMethodId': transaction.paymentMethodId,
        'paymentMethodName': transaction.paymentMethodName,
        'nominal': transaction.nominal,
        'date': transaction.date.millisecondsSinceEpoch,
        'notes': transaction.notes,
        'firebaseDocId': transaction.firebaseDocId,
        'isSynced': transaction.isSynced,
        'localCreatedAt': transaction.localCreatedAt.millisecondsSinceEpoch,
        'updatedAt': transaction.updatedAt?.millisecondsSinceEpoch,
        'isDeleted': transaction.isDeleted,
      },
    );
  }
}
