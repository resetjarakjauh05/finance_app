import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/monthly_budget_model.dart';
import '../local/monthly_budget_dao.dart';
import '../local/transaction_dao.dart';
import '../local/database_helper.dart';
import '../local/pending_operations_dao.dart';
import '../../domain/models/transaction_model.dart';
import 'connectivity_service.dart';

class MonthlyBudgetService {
  final FirebaseFirestore _firestore;
  final MonthlyBudgetDao _dao;
  final TransactionDao _txDao;
  final ConnectivityService _connectivity;
  final PendingOperationsDao _pendingOpsDao;
  final _uuid = const Uuid();

  MonthlyBudgetService({
    FirebaseFirestore? firestore,
    MonthlyBudgetDao? dao,
    TransactionDao? txDao,
    ConnectivityService? connectivity,
    PendingOperationsDao? pendingOpsDao,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _dao = dao ?? MonthlyBudgetDao(),
        _txDao = txDao ?? TransactionDao(dbHelper: DatabaseHelper()),
        _connectivity = connectivity ?? ConnectivityService(),
        _pendingOpsDao = pendingOpsDao ?? PendingOperationsDao();

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('users').doc(userId).collection('monthly_budgets');

  static String formatYearMonth(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// Get budgets by month — Firestore-first, fallback SQLite
  Future<List<MonthlyBudgetModel>> getBudgetsByMonth(
      String userId, String yearMonth) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snap = await _col(userId)
            .where('yearMonth', isEqualTo: yearMonth)
            .where('isDeleted', isEqualTo: false)
            .get();
        final budgets = snap.docs
            .map((d) => _fromFirestore(d.id, d.data(), userId))
            .toList();
        // Cache ke SQLite (await, tidak fire-and-forget)
        await _cacheToSqlite(budgets);

        // Merge data offline yang belum sync ke Firestore
        final allLocal = await _dao.getBudgetsByMonth(userId, yearMonth);
        final unsyncedLocal = allLocal
            .where((b) => !b.isSynced && b.firebaseDocId == null)
            .toList();
        if (unsyncedLocal.isNotEmpty) {
          final merged = [...budgets, ...unsyncedLocal];
          merged.sort((a, b) => a.localCreatedAt.compareTo(b.localCreatedAt));
          return merged;
        }
        return budgets;
      } catch (e) {
        debugPrint('MonthlyBudgetService.getBudgetsByMonth Firestore error: $e');
      }
    }
    return _dao.getBudgetsByMonth(userId, yearMonth);
  }

  /// Get distinct months — merge Firestore + SQLite
  Future<List<String>> getDistinctMonths(String userId) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snap = await _col(userId)
            .where('isDeleted', isEqualTo: false)
            .get();
        final months = snap.docs
            .map((d) => d.data()['yearMonth'] as String)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
        return months;
      } catch (e) {
        debugPrint('MonthlyBudgetService.getDistinctMonths Firestore error: $e');
      }
    }
    return _dao.getDistinctMonths(userId);
  }

  /// Create — Firestore-first, offline queue fallback
  Future<MonthlyBudgetModel> createBudget({
    required String userId,
    required String yearMonth,
    required String categoryId,
    required String categoryName,
    required String categoryIcon,
    required int budgetAmount,
    String? notes,
  }) async {
    final id = 'budget_${_uuid.v4()}';
    final budget = MonthlyBudgetModel(
      id: id,
      userId: userId,
      yearMonth: yearMonth,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      budgetAmount: budgetAmount,
      notes: notes,
      localCreatedAt: DateTime.now(),
    );

    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final docRef = await _col(userId).add(_toFirestore(budget));
        final synced = budget.copyWith(
            firebaseDocId: docRef.id, isSynced: true, syncedAt: DateTime.now());
        await _dao.insertOrReplace(synced);
        return synced;
      } catch (e) {
        debugPrint('MonthlyBudgetService.createBudget Firestore error: $e');
      }
    }
    await _dao.insertOrReplace(budget);
    // Queue untuk sync saat online
    await _pendingOpsDao.addPendingOperation(
      operation: 'CREATE',
      tableName: 'monthly_budgets',
      recordId: id.hashCode,
      data: {..._toFirestore(budget), 'userId': userId},
    );
    return budget;
  }

  /// Update — Firestore-first, offline queue fallback
  Future<void> updateBudget(MonthlyBudgetModel budget) async {
    final updated = budget.copyWith(updatedAt: DateTime.now());
    final isOnline = await _connectivity.isOnline();
    if (isOnline && budget.firebaseDocId != null) {
      try {
        await _col(budget.userId).doc(budget.firebaseDocId).update(
            {..._toFirestore(updated), 'updatedAt': FieldValue.serverTimestamp()});
        await _dao.update(updated.copyWith(isSynced: true, syncedAt: DateTime.now()));
        return;
      } catch (e) {
        debugPrint('MonthlyBudgetService.updateBudget Firestore error: $e');
      }
    }
    await _dao.update(updated.copyWith(isSynced: false));
    // Queue untuk sync saat online
    await _pendingOpsDao.addPendingOperation(
      operation: 'UPDATE',
      tableName: 'monthly_budgets',
      recordId: budget.id.hashCode,
      firebaseDocId: budget.firebaseDocId,
      data: {..._toFirestore(updated), 'userId': budget.userId},
    );
  }

  /// Delete — Firestore-first, offline queue fallback
  Future<void> deleteBudget(MonthlyBudgetModel budget) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline && budget.firebaseDocId != null) {
      try {
        await _col(budget.userId).doc(budget.firebaseDocId).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
        await _dao.softDelete(budget.id);
        return;
      } catch (e) {
        debugPrint('MonthlyBudgetService.deleteBudget Firestore error: $e');
      }
    }
    await _dao.softDelete(budget.id);
    // Queue untuk sync saat online
    await _pendingOpsDao.addPendingOperation(
      operation: 'DELETE',
      tableName: 'monthly_budgets',
      recordId: budget.id.hashCode,
      firebaseDocId: budget.firebaseDocId,
      data: {'id': budget.id, 'userId': budget.userId},
    );
  }

  /// Hitung actual spending bulan ini per kategori
  Future<int> getActualSpending(
      String userId, String yearMonth, String categoryId) async {
    final parts = yearMonth.split('-');
    if (parts.length != 2) return 0;
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);
    final transactions = await _txDao.filterTransactions(
      userId,
      category: TransactionCategory.expense.name,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
    );
    return transactions.fold<int>(0, (total, t) => total + t.nominal);
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  MonthlyBudgetModel _fromFirestore(
      String docId, Map<String, dynamic> data, String userId) {
    return MonthlyBudgetModel(
      id: data['id'] as String? ?? docId,
      userId: userId,
      firebaseDocId: docId,
      yearMonth: data['yearMonth'] as String,
      categoryId: data['categoryId'] as String,
      categoryName: data['categoryName'] as String,
      categoryIcon: data['categoryIcon'] as String? ?? '📦',
      budgetAmount: (data['budgetAmount'] as num).toInt(),
      notes: data['notes'] as String?,
      isSynced: true,
      syncedAt: DateTime.now(),
      localCreatedAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _toFirestore(MonthlyBudgetModel b) => {
        'id': b.id,
        'yearMonth': b.yearMonth,
        'categoryId': b.categoryId,
        'categoryName': b.categoryName,
        'categoryIcon': b.categoryIcon,
        'budgetAmount': b.budgetAmount,
        'notes': b.notes,
        'isDeleted': b.isDeleted,
        'createdAt': b.localCreatedAt.toIso8601String(),
      };

  Future<void> _cacheToSqlite(List<MonthlyBudgetModel> budgets) async {
    try {
      for (final b in budgets) {
        await _dao.insertOrReplace(b);
      }
    } catch (e) {
      debugPrint('MonthlyBudgetService._cacheToSqlite error: $e');
    }
  }
}
