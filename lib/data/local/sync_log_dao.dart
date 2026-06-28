import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// Data Access Object untuk sync_log table
class SyncLogDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Add sync log entry
  Future<int> addLog({
    required String operation,
    required String entityType,
    int? entityId,
    String? firebaseDocId,
    required String status,
    String? error,
  }) async {
    final db = await _dbHelper.database;
    return await db.insert('sync_log', {
      'operation': operation,
      'entityType': entityType,
      'entityId': entityId,
      'firebaseDocId': firebaseDocId,
      'status': status,
      'error': error,
      'localCreatedAt': DateTime.now().millisecondsSinceEpoch,
      'syncedAt': status == 'SUCCESS'
          ? DateTime.now().millisecondsSinceEpoch
          : null,
    });
  }

  /// Get all logs (with pagination)
  Future<List<Map<String, dynamic>>> getAllLogs({
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;
    return await db.query(
      'sync_log',
      orderBy: 'localCreatedAt DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Get logs by status
  Future<List<Map<String, dynamic>>> getLogsByStatus(String status) async {
    final db = await _dbHelper.database;
    return await db.query(
      'sync_log',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'localCreatedAt DESC',
    );
  }

  /// Get logs by entity type
  Future<List<Map<String, dynamic>>> getLogsByEntityType(
    String entityType,
  ) async {
    final db = await _dbHelper.database;
    return await db.query(
      'sync_log',
      where: 'entityType = ?',
      whereArgs: [entityType],
      orderBy: 'localCreatedAt DESC',
    );
  }

  /// Get recent logs (last 100)
  Future<List<Map<String, dynamic>>> getRecentLogs() async {
    final db = await _dbHelper.database;
    return await db.query(
      'sync_log',
      orderBy: 'localCreatedAt DESC',
      limit: 100,
    );
  }

  /// Clear old logs (older than specified days)
  Future<int> clearOldLogs(int daysToKeep) async {
    final db = await _dbHelper.database;
    final cutoffTimestamp = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .millisecondsSinceEpoch;

    return await db.delete(
      'sync_log',
      where: 'localCreatedAt < ?',
      whereArgs: [cutoffTimestamp],
    );
  }

  /// Get sync statistics
  Future<Map<String, int>> getSyncStats() async {
    final db = await _dbHelper.database;

    // Total logs
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sync_log',
    );
    final total = Sqflite.firstIntValue(totalResult) ?? 0;

    // Success count
    final successResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sync_log WHERE status = ?',
      ['SUCCESS'],
    );
    final success = Sqflite.firstIntValue(successResult) ?? 0;

    // Failed count
    final failedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sync_log WHERE status = ?',
      ['FAILED'],
    );
    final failed = Sqflite.firstIntValue(failedResult) ?? 0;

    return {
      'total': total,
      'success': success,
      'failed': failed,
    };
  }

  /// Delete all logs
  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return await db.delete('sync_log');
  }
}
