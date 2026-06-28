import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/category_model.dart';
import '../local/category_dao.dart';
import 'connectivity_service.dart';

class CategoryService {
  final FirebaseFirestore _firestore;
  final CategoryDao _dao;
  final ConnectivityService _connectivity;
  final _uuid = const Uuid();

  CategoryService({
    FirebaseFirestore? firestore,
    CategoryDao? dao,
    ConnectivityService? connectivity,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _dao = dao ?? CategoryDao(),
        _connectivity = connectivity ?? ConnectivityService();

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

  /// Get kategori — Firestore-first, fallback SQLite
  Future<List<CategoryModel>> getCategories(String userId) async {
    await initializePresets(userId);

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
    // Offline: save SQLite only
    await _dao.insertOrReplace(category);
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
    await _dao.update(updated.copyWith(isSynced: false));
  }

  /// Delete kategori — Firestore-first
  Future<void> deleteCategory(CategoryModel category) async {
    if (category.isPreset) throw Exception('Kategori preset tidak dapat dihapus');

    final isOnline = await _connectivity.isOnline();
    if (isOnline && category.firebaseDocId != null) {
      try {
        await _col(category.userId).doc(category.firebaseDocId).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('CategoryService.deleteCategory Firestore error: $e');
      }
    }
    await _dao.softDelete(category.id);
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
