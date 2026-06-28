import 'package:sqflite/sqflite.dart';
import '../../domain/models/spending_limit_model.dart';
import '../local/database_helper.dart';

class SpendingLimitDao {
  final DatabaseHelper _dbHelper;

  SpendingLimitDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<void> insertOrReplace(SpendingLimitModel limit) async {
    final db = await _dbHelper.database;
    await db.insert(
      'spending_limits',
      limit.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SpendingLimitModel>> getLimits(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'spending_limits',
      where: 'userId = ? AND isDeleted = 0 AND isActive = 1',
      whereArgs: [userId],
      orderBy: 'localCreatedAt ASC',
    );
    return maps.map(SpendingLimitModelExtension.fromSqlite).toList();
  }

  Future<SpendingLimitModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'spending_limits',
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return SpendingLimitModelExtension.fromSqlite(maps.first);
  }

  Future<SpendingLimitModel?> getGlobalLimit(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'spending_limits',
      where: 'userId = ? AND categoryId IS NULL AND isDeleted = 0 AND isActive = 1',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return SpendingLimitModelExtension.fromSqlite(maps.first);
  }

  Future<SpendingLimitModel?> getLimitByCategory(
      String userId, String categoryId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'spending_limits',
      where:
          'userId = ? AND categoryId = ? AND isDeleted = 0 AND isActive = 1',
      whereArgs: [userId, categoryId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return SpendingLimitModelExtension.fromSqlite(maps.first);
  }

  Future<void> update(SpendingLimitModel limit) async {
    final db = await _dbHelper.database;
    await db.update(
      'spending_limits',
      limit.toSqlite(),
      where: 'id = ?',
      whereArgs: [limit.id],
    );
  }

  Future<void> softDelete(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'spending_limits',
      {
        'isDeleted': 1,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSynced(String id, String firebaseDocId) async {
    final db = await _dbHelper.database;
    await db.update(
      'spending_limits',
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
