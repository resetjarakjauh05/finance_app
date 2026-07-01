import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/category_model.dart';
import '../local/category_dao.dart';
import '../local/pending_operations_dao.dart';
import 'connectivity_service.dart';

/// Mapping emoji lama → hex codepoint Material Icons
const Map<String, String> _kEmojiToHex = {
  '🍽️': 'e532', '🍽': 'e532',
  '🚗': 'e1d7',
  '🛍️': 'e59a', '🛍': 'e59a',
  '🎮': 'e5e8',
  '💊': 'e3d8',
  '📚': 'e559',
  '🧾': 'e50d',
  '☕': 'e38d',
  '💼': 'e041',
  '📈': 'e67f',
  '💸': 'e482',
  '💰': 'e553',
  '📦': 'e402',
  '🏠': 'e318',
  '✈️': 'e297', '✈': 'e297',
  '💪': 'e28d',
  '🎵': 'e415',
  '🐾': 'e4a1',
  '👕': 'e15d',
  '💄': 'e5d8',
  '🎁': 'e13e',
  '⚽': 'e5f2',
  '🔧': 'e116',
  '💻': 'e367',
  '📱': 'e5c6',
  '🎬': 'e40d',
  '🍕': 'e25a',
  '🚌': 'e1d5',
  '🏥': 'e396',
  '🌿': 'e217',
  '🎓': 'e80c',
  '❤️': 'e25b', '❤': 'e25b',
  // savings icons
  '🐷': 'e553',
  '🏖️': 'e0d6', '🏖': 'e0d6',
  '🏋️': 'e28d', '🏋': 'e28d',
  '👶': 'e160',
  '🛒': 'e59c',
  '⚡': 'e0ee',
  '🌍': 'e366',
  '📷': 'e130',
  '💍': 'f04ed',
};

class CategoryService {
  final FirebaseFirestore _firestore;
  final CategoryDao _dao;
  final ConnectivityService _connectivity;
  final PendingOperationsDao _pendingOpsDao;
  final _uuid = const Uuid();

  CategoryService({
    FirebaseFirestore? firestore,
    CategoryDao? dao,
    ConnectivityService? connectivity,
    PendingOperationsDao? pendingOpsDao,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _dao = dao ?? CategoryDao(),
        _connectivity = connectivity ?? ConnectivityService(),
        _pendingOpsDao = pendingOpsDao ?? PendingOperationsDao();

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('users').doc(userId).collection('categories');

  /// Inisialisasi preset — cek Firestore online, fallback SQLite
  Future<void> initializePresets(String userId) async {
    final hasPresets = await _dao.hasPresets(userId);
    if (hasPresets) return;

    final presets = kPresetCategories
        .map((p) => CategoryModel.fromPreset(p, userId))
        .toList();

    // Simpan ke SQLite dulu (offline-safe)
    await _dao.insertBatch(presets);
    debugPrint('CategoryService: ${presets.length} presets initialized for $userId');

    // Sync ke Firestore async
    _syncPresetsToFirestore(userId, presets);
  }

  /// Migrasi icon emoji lama → hex codepoint Material Icons (jalan sekali per user)
  Future<void> migrateIconsIfNeeded(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'icon_migrated_v2_$userId';
    if (prefs.getBool(key) == true) return;

    try {
      final all = await _dao.getCategories(userId);
      final toMigrate = all.where((c) => _isEmojiIcon(c.icon)).toList();

      if (toMigrate.isNotEmpty) {
        for (final cat in toMigrate) {
          final newHex = _emojiToHex(cat.icon);
          final updated = cat.copyWith(
            icon: newHex,
            updatedAt: DateTime.now(),
            isSynced: false,
          );
          await _dao.update(updated);
          debugPrint('CategoryService: migrated "${cat.name}" icon ${cat.icon} → $newHex');
        }
        // Sync ke Firestore async
        _syncIconMigration(userId, toMigrate.map((c) => c.copyWith(
          icon: _emojiToHex(c.icon),
          updatedAt: DateTime.now(),
        )).toList());
      }

      await prefs.setBool(key, true);
      debugPrint('CategoryService: icon migration done for $userId (${toMigrate.length} updated)');
    } catch (e) {
      debugPrint('CategoryService.migrateIconsIfNeeded error: $e');
    }
  }

  /// Cek apakah string adalah emoji (bukan hex codepoint 4-5 char)
  bool _isEmojiIcon(String icon) {
    // Hex codepoint: 4-5 char alfanumerik, mis: 'e532', 'f04ed'
    return !RegExp(r'^[0-9a-f]{4,5}$').hasMatch(icon);
  }

  /// Map emoji → hex, fallback 'e402' (more_horiz)
  String _emojiToHex(String emoji) => _kEmojiToHex[emoji] ?? 'e402';

  void _syncIconMigration(String userId, List<CategoryModel> categories) async {
    try {
      final isOnline = await _connectivity.isOnline();
      if (!isOnline) return;
      final batch = _firestore.batch();
      for (final cat in categories) {
        final docRef = cat.firebaseDocId != null
            ? _col(userId).doc(cat.firebaseDocId)
            : _col(userId).doc(cat.id);
        batch.update(docRef, {
          'icon': cat.icon,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      debugPrint('CategoryService: icon migration synced to Firestore');
    } catch (e) {
      debugPrint('CategoryService._syncIconMigration error: $e');
    }
  }

  /// Get kategori — Firestore-first, fallback SQLite
  Future<List<CategoryModel>> getCategories(String userId) async {
    await initializePresets(userId);
    await migrateIconsIfNeeded(userId);

    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snapshot = await _col(userId)
            .where('isDeleted', isEqualTo: false)
            .where('isActive', isEqualTo: true)
            .orderBy('isPreset', descending: true)
            .get();
        final categories = snapshot.docs
            .map((doc) => _fromFirestore(doc.id, doc.data(), userId))
            .toList();
        // Cache ke SQLite
        _cacheToSqlite(categories, userId);
        return categories;
      } catch (e) {
        debugPrint('CategoryService.getCategories Firestore error, fallback SQLite: $e');
      }
    }
    // Offline fallback
    return _dao.getCategories(userId);
  }

  Future<CategoryModel?> getCategoryById(String id) async =>
      _dao.getCategoryById(id);

  /// Tambah kategori custom — Firestore-first
  Future<CategoryModel> createCategory({
    required String userId,
    required String name,
    required String icon,
    required int color,
  }) async {
    final id = 'custom_${_uuid.v4()}';
    final category = CategoryModel(
      id: id,
      userId: userId,
      name: name.trim(),
      icon: icon,
      color: color,
      isPreset: false,
      localCreatedAt: DateTime.now(),
    );

    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final docRef = await _col(userId).add({
          'id': id,
          'name': category.name,
          'icon': icon,
          'color': color,
          'isPreset': false,
          'isActive': true,
          'isDeleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        final synced = category.copyWith(
          firebaseDocId: docRef.id,
          isSynced: true,
          syncedAt: DateTime.now(),
        );
        await _dao.insertOrReplace(synced);
        return synced;
      } catch (e) {
        debugPrint('CategoryService.createCategory Firestore error: $e');
      }
    }
    // Offline: save SQLite + queue pending
    await _dao.insertOrReplace(category);
    await _pendingOpsDao.addPendingOperation(
      operation: 'CREATE',
      tableName: 'categories',
      recordId: id.hashCode,
      data: {
        'id': id,
        'userId': userId,
        'name': category.name,
        'icon': icon,
        'color': color,
        'isPreset': false,
        'isActive': true,
      },
    );
    return category;
  }

  /// Update kategori — Firestore-first
  Future<void> updateCategory(CategoryModel category) async {
    if (category.isPreset) throw Exception('Kategori preset tidak dapat diubah');
    final updated = category.copyWith(updatedAt: DateTime.now());

    final isOnline = await _connectivity.isOnline();
    if (isOnline && category.firebaseDocId != null) {
      try {
        await _col(category.userId).doc(category.firebaseDocId).update({
          'name': updated.name,
          'icon': updated.icon,
          'color': updated.color,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _dao.update(updated.copyWith(isSynced: true, syncedAt: DateTime.now()));
        return;
      } catch (e) {
        debugPrint('CategoryService.updateCategory Firestore error: $e');
      }
    }
    // Offline: simpan SQLite + queue pending
    await _dao.update(updated.copyWith(isSynced: false));
    await _pendingOpsDao.addPendingOperation(
      operation: 'UPDATE',
      tableName: 'categories',
      recordId: category.id.hashCode,
      firebaseDocId: category.firebaseDocId,
      data: {
        'id': category.id,
        'userId': category.userId,
        'name': updated.name,
        'icon': updated.icon,
        'color': updated.color,
        'isPreset': category.isPreset,
        'isActive': category.isActive,
      },
    );
  }

  /// Delete kategori — Firestore-first
  Future<void> deleteCategory(CategoryModel category) async {
    if (category.isPreset) throw Exception('Kategori preset tidak dapat dihapus');

    // Soft delete lokal dulu agar UI langsung responsif
    await _dao.softDelete(category.id);

    final isOnline = await _connectivity.isOnline();
    if (isOnline && category.firebaseDocId != null) {
      try {
        await _col(category.userId).doc(category.firebaseDocId).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
        return;
      } catch (e) {
        debugPrint('CategoryService.deleteCategory Firestore error: $e');
      }
    }
    // Offline: queue pending (SQLite sudah soft-deleted di atas)
    await _pendingOpsDao.addPendingOperation(
      operation: 'DELETE',
      tableName: 'categories',
      recordId: category.id.hashCode,
      firebaseDocId: category.firebaseDocId,
      data: {
        'id': category.id,
        'userId': category.userId,
      },
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  CategoryModel _fromFirestore(
      String docId, Map<String, dynamic> data, String userId) {
    return CategoryModel(
      id: data['id'] as String? ?? docId,
      userId: userId,
      firebaseDocId: docId,
      name: data['name'] as String,
      icon: data['icon'] as String,
      color: (data['color'] as num).toInt(),
      isPreset: data['isPreset'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      isDeleted: data['isDeleted'] as bool? ?? false,
      isSynced: true,
      syncedAt: DateTime.now(),
      localCreatedAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  void _cacheToSqlite(List<CategoryModel> categories, String userId) async {
    try {
      await _dao.insertBatch(categories);
    } catch (e) {
      debugPrint('CategoryService._cacheToSqlite error: $e');
    }
  }

  void _syncPresetsToFirestore(String userId, List<CategoryModel> presets) async {
    try {
      final batch = _firestore.batch();
      for (final preset in presets) {
        final docRef = _col(userId).doc(preset.id);
        batch.set(docRef, {
          'id': preset.id,
          'name': preset.name,
          'icon': preset.icon,
          'color': preset.color,
          'isPreset': true,
          'isActive': true,
          'isDeleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      for (final preset in presets) {
        await _dao.markSynced(preset.id, preset.id);
      }
      debugPrint('CategoryService: presets synced to Firestore for $userId');
    } catch (e) {
      debugPrint('CategoryService._syncPresetsToFirestore error: $e');
    }
  }
}
