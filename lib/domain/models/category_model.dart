import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

/// Preset kategori yang tidak bisa dihapus
/// icon: hex codepoint Material Icons, render dengan iconFromHex() dari icon_helper.dart
const List<Map<String, dynamic>> kPresetCategories = [
  {'id': 'preset_makan',     'name': 'Makan & Minum',      'icon': 'e532', 'color': 0xFFE53935, 'isPreset': true}, // restaurant
  {'id': 'preset_transport', 'name': 'Transportasi',        'icon': 'e1d7', 'color': 0xFF1E88E5, 'isPreset': true}, // directions_car
  {'id': 'preset_belanja',   'name': 'Belanja',             'icon': 'e59a', 'color': 0xFF8E24AA, 'isPreset': true}, // shopping_bag
  {'id': 'preset_hiburan',   'name': 'Hiburan',             'icon': 'e5e8', 'color': 0xFFFF8F00, 'isPreset': true}, // sports_esports
  {'id': 'preset_kesehatan', 'name': 'Kesehatan',           'icon': 'e3d8', 'color': 0xFF43A047, 'isPreset': true}, // medical_services
  {'id': 'preset_pendidikan','name': 'Pendidikan',          'icon': 'e559', 'color': 0xFF00ACC1, 'isPreset': true}, // school
  {'id': 'preset_tagihan',   'name': 'Tagihan & Utilitas',  'icon': 'e50d', 'color': 0xFF6D4C41, 'isPreset': true}, // receipt_long
  {'id': 'preset_nongkrong', 'name': 'Nongkrong',           'icon': 'e38d', 'color': 0xFF5D4037, 'isPreset': true}, // local_cafe
  {'id': 'preset_gaji',      'name': 'Gaji & Pendapatan',   'icon': 'e041', 'color': 0xFF1565C0, 'isPreset': true}, // account_balance_wallet
  {'id': 'preset_investasi', 'name': 'Investasi',           'icon': 'e67f', 'color': 0xFF00897B, 'isPreset': true}, // trending_up
  {'id': 'preset_hutang',    'name': 'Bayar Hutang',        'icon': 'e482', 'color': 0xFFE53935, 'isPreset': true}, // payments
  {'id': 'preset_piutang',   'name': 'Terima Piutang',      'icon': 'e553', 'color': 0xFF43A047, 'isPreset': true}, // savings
  {'id': 'preset_lainnya',   'name': 'Lainnya',             'icon': 'e402', 'color': 0xFF757575, 'isPreset': true}, // more_horiz
];

@freezed
abstract class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String userId,
    required String name,
    required String icon,
    required int color,
    @Default(false) bool isPreset,
    @Default(true) bool isActive,
    @Default(false) bool isSynced,
    String? firebaseDocId,
    DateTime? syncedAt,
    required DateTime localCreatedAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  /// Create preset category instance untuk user
  factory CategoryModel.fromPreset(
    Map<String, dynamic> preset,
    String userId,
  ) {
    return CategoryModel(
      id: preset['id'] as String,
      userId: userId,
      name: preset['name'] as String,
      icon: preset['icon'] as String,
      color: preset['color'] as int,
      isPreset: true,
      isActive: true,
      localCreatedAt: DateTime.now(),
    );
  }
}

extension CategoryModelExtension on CategoryModel {
  /// Convert to SQLite map
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'firebaseDocId': firebaseDocId,
      'userId': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'isPreset': isPreset ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'localCreatedAt': localCreatedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  /// Create from SQLite map
  static CategoryModel fromSqlite(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      firebaseDocId: map['firebaseDocId'] as String?,
      userId: map['userId'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as int,
      isPreset: (map['isPreset'] as int) == 1,
      isActive: (map['isActive'] as int) == 1,
      isSynced: (map['isSynced'] as int) == 1,
      syncedAt: map['syncedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['syncedAt'] as int)
          : null,
      localCreatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['localCreatedAt'] as int),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}
