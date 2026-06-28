import 'database_helper.dart';

class CustodyDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Map<String, dynamic> custody) async {
    final db = await _dbHelper.database;
    return await db.insert('custody', custody);
  }

  Future<int> update(int id, Map<String, dynamic> custody) async {
    final db = await _dbHelper.database;
    return await db.update('custody', custody, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'custody',
      {'isDeleted': 1, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query('custody',
        where: 'id = ? AND isDeleted = 0', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getByFirebaseDocId(String firebaseDocId) async {
    if (firebaseDocId.isEmpty) return null;
    final db = await _dbHelper.database;
    final result = await db.query('custody',
        where: 'firebaseDocId = ? AND isDeleted = 0', whereArgs: [firebaseDocId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllByUserId(String userId) async {
    final db = await _dbHelper.database;
    return await db.query('custody',
        where: 'userId = ? AND isDeleted = 0',
        whereArgs: [userId],
        orderBy: 'localCreatedAt DESC');
  }

  Future<int> markAsSynced(int id, String firebaseDocId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'custody',
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
