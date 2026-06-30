import 'database_helper.dart';

class CustodyMovementDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Map<String, dynamic> movement) async {
    final db = await _dbHelper.database;
    return await db.insert('custody_movements', movement);
  }

  Future<int> update(int id, Map<String, dynamic> movement) async {
    final db = await _dbHelper.database;
    return await db.update('custody_movements', movement,
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('custody_movements',
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getByCustodyId(int custodyId) async {
    final db = await _dbHelper.database;
    return await db.query('custody_movements',
        where: 'custodyId = ?',
        whereArgs: [custodyId],
        orderBy: 'date DESC');
  }

  Future<Map<String, dynamic>?> getByFirebaseDocId(String firebaseDocId) async {
    if (firebaseDocId.isEmpty) return null;
    final db = await _dbHelper.database;
    final result = await db.query('custody_movements',
        where: 'firebaseDocId = ?', whereArgs: [firebaseDocId]);
    return result.isNotEmpty ? result.first : null;
  }

  /// Calculate balance: SUM(masuk) - SUM(keluar)
  Future<int> calculateBalance(int custodyId) async {
    final db = await _dbHelper.database;
    final masuk = await db.rawQuery(
      "SELECT COALESCE(SUM(nominal),0) as total FROM custody_movements WHERE custodyId = ? AND movementType = 'MASUK'",
      [custodyId],
    );
    final keluar = await db.rawQuery(
      "SELECT COALESCE(SUM(nominal),0) as total FROM custody_movements WHERE custodyId = ? AND movementType = 'KELUAR'",
      [custodyId],
    );
    final masukTotal = (masuk.first['total'] as num?)?.toInt() ?? 0;
    final keluarTotal = (keluar.first['total'] as num?)?.toInt() ?? 0;
    return masukTotal - keluarTotal;
  }

  /// Cek apakah ada unsynced movements untuk custody tertentu
  Future<bool> hasUnsyncedMovements(int custodyId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as cnt FROM custody_movements WHERE custodyId = ? AND isSynced = 0",
      [custodyId],
    );
    return ((result.first['cnt'] as int?) ?? 0) > 0;
  }

  Future<int> markAsSynced(int id, String firebaseDocId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'custody_movements',
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
