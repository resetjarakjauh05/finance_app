import 'package:sqflite/sqflite.dart';
import '../../domain/models/savings_plan_model.dart';
import '../local/database_helper.dart';

class SavingsPlanDao {
  final DatabaseHelper _dbHelper;

  SavingsPlanDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<void> insertOrReplace(SavingsPlanModel plan) async {
    final db = await _dbHelper.database;
    await db.insert('savings_plans', plan.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SavingsPlanModel>> getPlans(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'savings_plans',
      where: 'userId = ? AND isDeleted = 0 AND isActive = 1',
      whereArgs: [userId],
      orderBy: 'localCreatedAt ASC',
    );
    return maps.map(SavingsPlanModelExtension.fromSqlite).toList();
  }

  Future<SavingsPlanModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('savings_plans',
        where: 'id = ? AND isDeleted = 0', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return SavingsPlanModelExtension.fromSqlite(maps.first);
  }

  Future<void> update(SavingsPlanModel plan) async {
    final db = await _dbHelper.database;
    await db.update('savings_plans', plan.toSqlite(),
        where: 'id = ?', whereArgs: [plan.id]);
  }

  /// Update savedAmount saja (setelah alokasi)
  Future<void> updateSavedAmount(String id, int savedAmount) async {
    final db = await _dbHelper.database;
    await db.update(
      'savings_plans',
      {'savedAmount': savedAmount, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> softDelete(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'savings_plans',
      {'isDeleted': 1, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSynced(String id, String firebaseDocId) async {
    final db = await _dbHelper.database;
    await db.update(
      'savings_plans',
      {'isSynced': 1, 'firebaseDocId': firebaseDocId, 'syncedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class SavingsAllocationDao {
  final DatabaseHelper _dbHelper;

  SavingsAllocationDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<void> insert(SavingsAllocationModel allocation) async {
    final db = await _dbHelper.database;
    await db.insert('savings_allocations', allocation.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SavingsAllocationModel>> getByPlanId(String planId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'savings_allocations',
      where: 'savingsPlanId = ? AND isDeleted = 0',
      whereArgs: [planId],
      orderBy: 'date DESC',
    );
    return maps.map(SavingsAllocationModelExtension.fromSqlite).toList();
  }

  Future<void> softDelete(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'savings_allocations',
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
