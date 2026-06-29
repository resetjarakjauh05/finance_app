import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../domain/models/payment_method_model.dart';

/// DAO untuk SQLite backup payment_methods (offline cache)
class PaymentMethodDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<Database> get _db async => _dbHelper.database;

  /// Insert or replace (upsert)
  Future<void> insertOrReplace(PaymentMethodModel m) async {
    final db = await _db;
    await db.insert(
      'payment_methods',
      _toSqlite(m),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update by firebaseDocId
  Future<void> update(PaymentMethodModel m) async {
    final db = await _db;
    await db.update(
      'payment_methods',
      _toSqlite(m),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  /// Soft delete
  Future<void> softDelete(String id) async {
    final db = await _db;
    await db.update(
      'payment_methods',
      {'isActive': 0, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all active methods for userId
  Future<List<PaymentMethodModel>> getAll(String userId) async {
    final db = await _db;
    final rows = await db.query(
      'payment_methods',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: '`order` ASC',
    );
    return rows.map(_fromSqlite).toList();
  }

  /// Get active only
  Future<List<PaymentMethodModel>> getActive(String userId) async {
    final db = await _db;
    final rows = await db.query(
      'payment_methods',
      where: 'userId = ? AND isActive = 1',
      whereArgs: [userId],
      orderBy: '`order` ASC',
    );
    return rows.map(_fromSqlite).toList();
  }

  /// Delete all for userId (saat sync fresh dari Firestore)
  Future<void> deleteAll(String userId) async {
    final db = await _db;
    await db.delete(
      'payment_methods',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Map<String, dynamic> _toSqlite(PaymentMethodModel m) => {
    'id': m.id,
    'userId': m.userId,
    'name': m.name,
    'type': m.type.name,
    'bankName': m.bankName,
    'accountNumber': m.accountNumber,
    'isActive': m.isActive ? 1 : 0,
    'order': m.order,
    'createdAt': m.createdAt?.millisecondsSinceEpoch,
    'updatedAt': m.updatedAt?.millisecondsSinceEpoch,
  };

  PaymentMethodModel _fromSqlite(Map<String, dynamic> row) {
    return PaymentMethodModel(
      id: row['id'] as String,
      userId: row['userId'] as String,
      name: row['name'] as String,
      type: PaymentMethodType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => PaymentMethodType.bank,
      ),
      bankName: row['bankName'] as String?,
      accountNumber: row['accountNumber'] as String?,
      isActive: (row['isActive'] as int) == 1,
      order: row['order'] as int? ?? 0,
      createdAt: row['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int)
          : null,
      updatedAt: row['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['updatedAt'] as int)
          : null,
    );
  }
}
