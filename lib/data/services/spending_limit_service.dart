import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/spending_limit_model.dart';
import '../local/spending_limit_dao.dart';
import '../local/transaction_dao.dart';
import '../local/database_helper.dart';
import '../../domain/models/transaction_model.dart';
import 'connectivity_service.dart';

class SpendingLimitService {
  final FirebaseFirestore _firestore;
  final SpendingLimitDao _dao;
  final TransactionDao _txDao;
  final ConnectivityService _connectivity;
  final _uuid = const Uuid();

  SpendingLimitService({
    FirebaseFirestore? firestore,
    SpendingLimitDao? dao,
    TransactionDao? txDao,
    ConnectivityService? connectivity,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _dao = dao ?? SpendingLimitDao(),
        _txDao = txDao ?? TransactionDao(dbHelper: DatabaseHelper()),
        _connectivity = connectivity ?? ConnectivityService();

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('users').doc(userId).collection('spending_limits');

  /// Get limits — Firestore-first, fallback SQLite
  Future<List<SpendingLimitModel>> getLimits(String userId) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snap = await _col(userId)
            .where('isDeleted', isEqualTo: false)
            .where('isActive', isEqualTo: true)
            .get();
        final limits = snap.docs
            .map((d) => _fromFirestore(d.id, d.data(), userId))
            .toList();
        _cacheToSqlite(limits);
        return limits;
      } catch (e) {
        debugPrint('SpendingLimitService.getLimits Firestore error, fallback: $e');
      }
    }
    return _dao.getLimits(userId);
  }

  /// Create — Firestore-first
  Future<SpendingLimitModel> createLimit({
    required String userId,
    required int dailyLimit,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    double warningThreshold = 0.8,
  }) async {
    final id = 'limit_${_uuid.v4()}';
    final limit = SpendingLimitModel(
      id: id,
      userId: userId,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      dailyLimit: dailyLimit,
      warningThreshold: warningThreshold,
      localCreatedAt: DateTime.now(),
    );

    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final docRef = await _col(userId).add(_toFirestore(limit));
        final synced = limit.copyWith(
            firebaseDocId: docRef.id, isSynced: true, syncedAt: DateTime.now());
        await _dao.insertOrReplace(synced);
        return synced;
      } catch (e) {
        debugPrint('SpendingLimitService.createLimit Firestore error: $e');
      }
    }
    await _dao.insertOrReplace(limit);
    return limit;
  }

  /// Update — Firestore-first
  Future<void> updateLimit(SpendingLimitModel limit) async {
    final updated = limit.copyWith(updatedAt: DateTime.now());
    final isOnline = await _connectivity.isOnline();
    if (isOnline && limit.firebaseDocId != null) {
      try {
        await _col(limit.userId)
            .doc(limit.firebaseDocId)
            .update({..._toFirestore(updated), 'updatedAt': FieldValue.serverTimestamp()});
        await _dao.update(updated.copyWith(isSynced: true, syncedAt: DateTime.now()));
        return;
      } catch (e) {
        debugPrint('SpendingLimitService.updateLimit Firestore error: $e');
      }
    }
    await _dao.update(updated.copyWith(isSynced: false));
  }

  /// Delete — Firestore-first
  Future<void> deleteLimit(SpendingLimitModel limit) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline && limit.firebaseDocId != null) {
      try {
        await _col(limit.userId).doc(limit.firebaseDocId).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('SpendingLimitService.deleteLimit Firestore error: $e');
      }
    }
    await _dao.softDelete(limit.id);
  }

  /// Hitung total pengeluaran hari ini
  Future<int> getTodaySpending(String userId, {String? categoryId}) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final transactions = await _txDao.filterTransactions(
      userId,
      category: TransactionCategory.expense.name,
      categoryId: categoryId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
    return transactions.fold<int>(0, (total, t) => total + t.nominal);
  }

  /// Cek semua limit
  Future<List<LimitCheckResult>> checkLimits(String userId) async {
    final limits = await getLimits(userId);
    final results = <LimitCheckResult>[];
    for (final limit in limits) {
      final spent = await getTodaySpending(userId, categoryId: limit.categoryId);
      final status = limit.statusForSpent(spent);
      if (status != SpendingLimitStatus.safe) {
        results.add(LimitCheckResult(limit: limit, spent: spent, status: status));
      }
    }
    return results;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  SpendingLimitModel _fromFirestore(
      String docId, Map<String, dynamic> data, String userId) {
    return SpendingLimitModel(
      id: data['id'] as String? ?? docId,
      userId: userId,
      firebaseDocId: docId,
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      categoryIcon: data['categoryIcon'] as String?,
      dailyLimit: (data['dailyLimit'] as num).toInt(),
      warningThreshold: (data['warningThreshold'] as num?)?.toDouble() ?? 0.8,
      isActive: data['isActive'] as bool? ?? true,
      isDeleted: data['isDeleted'] as bool? ?? false,
      isSynced: true,
      syncedAt: DateTime.now(),
      localCreatedAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _toFirestore(SpendingLimitModel l) => {
        'id': l.id,
        'categoryId': l.categoryId,
        'categoryName': l.categoryName,
        'categoryIcon': l.categoryIcon,
        'dailyLimit': l.dailyLimit,
        'warningThreshold': l.warningThreshold,
        'isActive': l.isActive,
        'isDeleted': l.isDeleted,
        'createdAt': FieldValue.serverTimestamp(),
      };

  void _cacheToSqlite(List<SpendingLimitModel> limits) async {
    try {
      for (final l in limits) {
        await _dao.insertOrReplace(l);
      }
    } catch (e) {
      debugPrint('SpendingLimitService._cacheToSqlite error: $e');
    }
  }
}

class LimitCheckResult {
  final SpendingLimitModel limit;
  final int spent;
  final SpendingLimitStatus status;
  const LimitCheckResult({required this.limit, required this.spent, required this.status});
}
