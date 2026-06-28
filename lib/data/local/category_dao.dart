import 'package:sqflite/sqflite.dart';
import '../../domain/models/category_model.dart';
import '../local/database_helper.dart';

/// DAO untuk tabel categories di SQLite
class CategoryDao {
  final DatabaseHelper _dbHelper;

  CategoryDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  /// Insert atau replace category
  Future<void> insertOrReplace(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.insert(
      'categories',
      category.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert batch categories
  Future<void> insertBatch(List<CategoryModel> categories) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final cat in categories) {
      batch.insert(
        'categories',
        cat.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Get semua categories aktif milik user
  Future<List<CategoryModel>> getCategories(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'userId = ? AND isDeleted = 0 AND isActive = 1',
      whereArgs: [userId],
      orderBy: 'isPreset DESC, name ASC',
    );
    return maps.map(CategoryModelExtension.fromSqlite).toList();
  }

  /// Get category by id
  Future<CategoryModel?> getCategoryById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CategoryModelExtension.fromSqlite(maps.first);
  }

  /// Update category
  Future<void> update(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      category.toSqlite(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Soft delete category (hanya custom, preset tidak bisa dihapus)
  Future<void> softDelete(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      {
        'isDeleted': 1,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ? AND isPreset = 0',
      whereArgs: [id],
    );
  }

  /// Cek apakah preset sudah diinisialisasi untuk user
  Future<bool> hasPresets(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM categories WHERE userId = ? AND isPreset = 1',
      [userId],
    );
    return (result.first['count'] as int) > 0;
  }

  /// Get unsynced categories
  Future<List<CategoryModel>> getUnsynced(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'userId = ? AND isSynced = 0',
      whereArgs: [userId],
    );
    return maps.map(CategoryModelExtension.fromSqlite).toList();
  }

  /// Mark as synced
  Future<void> markSynced(String id, String firebaseDocId) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
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
