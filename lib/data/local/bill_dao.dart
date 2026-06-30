import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// DAO untuk bills table
class BillDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Map<String, dynamic> bill) async {
    final db = await _dbHelper.database;
    return await db.insert('bills', bill);
  }

  Future<int> update(int id, Map<String, dynamic> bill) async {
    final db = await _dbHelper.database;
    return await db.update('bills', bill, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'bills',
      {'isDeleted': 1, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getByFirebaseDocId(String firebaseDocId) async {
    if (firebaseDocId.isEmpty) return null;
    final db = await _dbHelper.database;
    final result = await db.query(
      'bills',
      where: 'firebaseDocId = ?',
      whereArgs: [firebaseDocId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'bills',
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllByUserId(
    String userId, {
    String? status,
  }) async {
    final db = await _dbHelper.database;
    final where = status != null
        ? 'userId = ? AND isDeleted = 0 AND status = ?'
        : 'userId = ? AND isDeleted = 0';
    final whereArgs = status != null ? [userId, status] : [userId];
    return await db.query(
      'bills',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'dueDate ASC',
    );
  }

  Future<int> getUnsyncedCount(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bills WHERE userId = ? AND isSynced = 0 AND isDeleted = 0',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> markAsSynced(int id, String firebaseDocId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'bills',
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
