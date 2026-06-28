import 'package:sqflite/sqflite.dart';
import '../../domain/models/monthly_budget_model.dart';
import '../local/database_helper.dart';

class MonthlyBudgetDao {
  final DatabaseHelper _dbHelper;

  MonthlyBudgetDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<void> insertOrReplace(MonthlyBudgetModel budget) async {
    final db = await _dbHelper.database;
    await db.insert('monthly_budgets', budget.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertBatch(List<MonthlyBudgetModel> budgets) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final b in budgets) {
      batch.insert('monthly_budgets', b.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Get semua budget untuk bulan tertentu
  Future<List<MonthlyBudgetModel>> getBudgetsByMonth(
      String userId, String yearMonth) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'monthly_budgets',
      where: 'userId = ? AND yearMonth = ? AND isDeleted = 0',
      whereArgs: [userId, yearMonth],
      orderBy: 'localCreatedAt ASC',
    );
    return maps.map(MonthlyBudgetModelExtension.fromSqlite).toList();
  }

  /// Get semua bulan yang punya budget
  Future<List<String>> getDistinctMonths(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT yearMonth FROM monthly_budgets WHERE userId = ? AND isDeleted = 0 ORDER BY yearMonth DESC',
      [userId],
    );
    return result.map((r) => r['yearMonth'] as String).toList();
  }

  Future<MonthlyBudgetModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'monthly_budgets',
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MonthlyBudgetModelExtension.fromSqlite(maps.first);
  }

  Future<void> update(MonthlyBudgetModel budget) async {
    final db = await _dbHelper.database;
    await db.update('monthly_budgets', budget.toSqlite(),
        where: 'id = ?', whereArgs: [budget.id]);
  }

  Future<void> softDelete(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'monthly_budgets',
      {'isDeleted': 1, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSynced(String id, String firebaseDocId) async {
    final db = await _dbHelper.database;
    await db.update(
      'monthly_budgets',
      {
        'isSynced': 1,
        'firebaseDocId': firebaseDocId,
        'syncedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
