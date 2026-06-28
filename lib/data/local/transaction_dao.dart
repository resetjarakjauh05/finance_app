import 'package:sqflite/sqflite.dart';
import '../../domain/models/transaction_model.dart';
import 'database_helper.dart';

/// Data Access Object untuk transactions table
class TransactionDao {
  final DatabaseHelper _dbHelper;

  TransactionDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  /// Insert transaction
  Future<int> insert(Map<String, dynamic> transaction) async {
    final db = await _dbHelper.database;
    return await db.insert('transactions', transaction);
  }

  /// Update transaction
  Future<int> update(int id, Map<String, dynamic> transaction) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete transaction (soft delete)
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      {
        'isDeleted': 1,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get transaction by Firebase doc ID
  Future<Map<String, dynamic>?> getByFirebaseDocId(String firebaseDocId) async {
    if (firebaseDocId.isEmpty) return null;
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'firebaseDocId = ? AND isDeleted = 0',
      whereArgs: [firebaseDocId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get transaction by ID
  Future<Map<String, dynamic>?> getById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get all transactions untuk user
  Future<List<Map<String, dynamic>>> getAllByUserId(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;
    return await db.query(
      'transactions',
      where: 'userId = ? AND isDeleted = 0',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Get unsynced transactions
  Future<List<Map<String, dynamic>>> getUnsyncedByUserId(String userId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'transactions',
      where: 'userId = ? AND isSynced = 0 AND isDeleted = 0',
      whereArgs: [userId],
      orderBy: 'localCreatedAt DESC',
    );
  }

  /// Search transactions
  Future<List<Map<String, dynamic>>> search(
    String userId,
    String query,
  ) async {
    final db = await _dbHelper.database;
    return await db.query(
      'transactions',
      where:
          'userId = ? AND isDeleted = 0 AND (description LIKE ? OR notes LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
  }

  /// Filter transactions
  Future<List<Map<String, dynamic>>> filter(
    String userId, {
    String? category,
    String? paymentMethodId,
    int? startDate,
    int? endDate,
  }) async {
    final db = await _dbHelper.database;
    
    final where = <String>['userId = ?', 'isDeleted = 0'];
    final whereArgs = <dynamic>[userId];

    if (category != null) {
      where.add('category = ?');
      whereArgs.add(category);
    }

    if (paymentMethodId != null) {
      where.add('paymentMethodId = ?');
      whereArgs.add(paymentMethodId);
    }

    if (startDate != null) {
      where.add('date >= ?');
      whereArgs.add(startDate);
    }

    if (endDate != null) {
      where.add('date <= ?');
      whereArgs.add(endDate);
    }

    return await db.query(
      'transactions',
      where: where.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
  }

  /// Get total nominal by category untuk user
  Future<int> getTotalByCategory(String userId, String category) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(nominal) as total FROM transactions WHERE userId = ? AND category = ? AND isDeleted = 0',
      [userId, category],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get saldo per payment method (income - expense)
  Future<Map<String, int>> getBalancePerPaymentMethod(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        paymentMethodId,
        paymentMethodName,
        SUM(CASE WHEN category = 'income' THEN nominal ELSE -nominal END) as balance
      FROM transactions
      WHERE userId = ? AND isDeleted = 0
      GROUP BY paymentMethodId, paymentMethodName
    ''', [userId]);

    final Map<String, int> balances = {};
    for (final row in result) {
      final id = row['paymentMethodId'] as String;
      final balance = (row['balance'] as num?)?.toInt() ?? 0;
      balances[id] = balance;
    }
    return balances;
  }

  /// Mark as synced
  Future<int> markAsSynced(int id, String firebaseDocId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      {
        'isSynced': 1,
        'firebaseDocId': firebaseDocId,
        'syncedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Filter transactions by payment method
  Future<List<Map<String, dynamic>>> filterByPaymentMethod(
    String userId,
    String paymentMethodId,
  ) async {
    final db = await _dbHelper.database;
    return await db.query(
      'transactions',
      where: 'userId = ? AND paymentMethodId = ? AND isDeleted = 0',
      whereArgs: [userId, paymentMethodId],
      limit: 1,
    );
  }

  /// Filter transactions, return List of TransactionModel (dipakai SpendingLimitService)
  Future<List<TransactionModel>> filterTransactions(
    String userId, {
    String? category,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;
    final where = <String>['userId = ?', 'isDeleted = 0'];
    final whereArgs = <dynamic>[userId];

    if (category != null) {
      where.add('category = ?');
      whereArgs.add(category);
    }
    if (categoryId != null) {
      where.add('categoryId = ?');
      whereArgs.add(categoryId);
    }
    if (startDate != null) {
      where.add('date >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    if (endDate != null) {
      where.add('date < ?');
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final maps = await db.query(
      'transactions',
      where: where.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return maps.map(TransactionModelExtension.fromSqlite).toList();
  }
}
