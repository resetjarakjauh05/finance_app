import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// Data Access Object untuk pending_operations table
class PendingOperationsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Add pending operation
  Future<int> addPendingOperation({
    required String operation,
    required String tableName,
    required int recordId,
    String? firebaseDocId,
    required Map<String, dynamic> data,
  }) async {
    final db = await _dbHelper.database;
    return await db.insert('pending_operations', {
      'operation': operation,
      'tableName': tableName,
      'recordId': recordId,
      'firebaseDocId': firebaseDocId,
      'data': jsonEncode(data),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'retryCount': 0,
      'status': 'PENDING',
    });
  }

  /// Get all pending operations
  Future<List<Map<String, dynamic>>> getAllPending() async {
    final db = await _dbHelper.database;
    return await db.query(
      'pending_operations',
      where: 'status = ? AND retryCount < ?',
      whereArgs: ['PENDING', 3],
      orderBy: 'timestamp ASC',
    );
  }

  /// Update operation status
  Future<int> updateStatus(
    int id,
    String status, {
    String? firebaseDocId,
    String? error,
  }) async {
    final db = await _dbHelper.database;
    final updates = <String, dynamic>{
      'status': status,
    };

    if (firebaseDocId != null) {
      updates['firebaseDocId'] = firebaseDocId;
    }

    if (error != null) {
      updates['error'] = error;
    }

    return await db.update(
      'pending_operations',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Increment retry count
  Future<int> incrementRetryCount(int id) async {
    final db = await _dbHelper.database;
    return await db.rawUpdate(
      'UPDATE pending_operations SET retryCount = retryCount + 1 WHERE id = ?',
      [id],
    );
  }

  /// Delete operation
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'pending_operations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get failed operations
  Future<List<Map<String, dynamic>>> getFailedOperations() async {
    final db = await _dbHelper.database;
    return await db.query(
      'pending_operations',
      where: 'status = ?',
      whereArgs: ['FAILED'],
      orderBy: 'timestamp DESC',
    );
  }

  /// Clear all completed operations
  Future<int> clearCompleted() async {
    final db = await _dbHelper.database;
    return await db.delete(
      'pending_operations',
      where: 'status = ?',
      whereArgs: ['SUCCESS'],
    );
  }

  /// Get pending count
  Future<int> getPendingCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM pending_operations WHERE status = ?',
      ['PENDING'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
