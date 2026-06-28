// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spending_limit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpendingLimitModel _$SpendingLimitModelFromJson(Map<String, dynamic> json) {
  return _SpendingLimitModel.fromJson(json);
}

/// @nodoc
mixin _$SpendingLimitModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// null = global (semua kategori), isi = per kategori
  String? get categoryId => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;
  String? get categoryIcon => throw _privateConstructorUsedError;

  /// Nominal limit harian dalam rupiah
  int get dailyLimit => throw _privateConstructorUsedError;

  /// Threshold notifikasi "hampir habis" (0.0 - 1.0), default 0.8 = 80%
  double get warningThreshold => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get firebaseDocId => throw _privateConstructorUsedError;
  bool get isSynced => throw _privateConstructorUsedError;
  DateTime? get syncedAt => throw _privateConstructorUsedError;
  DateTime get localCreatedAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this SpendingLimitModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpendingLimitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpendingLimitModelCopyWith<SpendingLimitModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpendingLimitModelCopyWith<$Res> {
  factory $SpendingLimitModelCopyWith(
          SpendingLimitModel value, $Res Function(SpendingLimitModel) then) =
      _$SpendingLimitModelCopyWithImpl<$Res, SpendingLimitModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? categoryId,
      String? categoryName,
      String? categoryIcon,
      int dailyLimit,
      double warningThreshold,
      bool isActive,
      String? firebaseDocId,
      bool isSynced,
      DateTime? syncedAt,
      DateTime localCreatedAt,
      DateTime? updatedAt,
      bool isDeleted});
}

/// @nodoc
class _$SpendingLimitModelCopyWithImpl<$Res, $Val extends SpendingLimitModel>
    implements $SpendingLimitModelCopyWith<$Res> {
  _$SpendingLimitModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpendingLimitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? categoryIcon = freezed,
    Object? dailyLimit = null,
    Object? warningThreshold = null,
    Object? isActive = null,
    Object? firebaseDocId = freezed,
    Object? isSynced = null,
    Object? syncedAt = freezed,
    Object? localCreatedAt = null,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryIcon: freezed == categoryIcon
          ? _value.categoryIcon
          : categoryIcon // ignore: cast_nullable_to_non_nullable
              as String?,
      dailyLimit: null == dailyLimit
          ? _value.dailyLimit
          : dailyLimit // ignore: cast_nullable_to_non_nullable
              as int,
      warningThreshold: null == warningThreshold
          ? _value.warningThreshold
          : warningThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      firebaseDocId: freezed == firebaseDocId
          ? _value.firebaseDocId
          : firebaseDocId // ignore: cast_nullable_to_non_nullable
              as String?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      syncedAt: freezed == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      localCreatedAt: null == localCreatedAt
          ? _value.localCreatedAt
          : localCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpendingLimitModelImplCopyWith<$Res>
    implements $SpendingLimitModelCopyWith<$Res> {
  factory _$$SpendingLimitModelImplCopyWith(_$SpendingLimitModelImpl value,
          $Res Function(_$SpendingLimitModelImpl) then) =
      __$$SpendingLimitModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? categoryId,
      String? categoryName,
      String? categoryIcon,
      int dailyLimit,
      double warningThreshold,
      bool isActive,
      String? firebaseDocId,
      bool isSynced,
      DateTime? syncedAt,
      DateTime localCreatedAt,
      DateTime? updatedAt,
      bool isDeleted});
}

/// @nodoc
class __$$SpendingLimitModelImplCopyWithImpl<$Res>
    extends _$SpendingLimitModelCopyWithImpl<$Res, _$SpendingLimitModelImpl>
    implements _$$SpendingLimitModelImplCopyWith<$Res> {
  __$$SpendingLimitModelImplCopyWithImpl(_$SpendingLimitModelImpl _value,
      $Res Function(_$SpendingLimitModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpendingLimitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? categoryIcon = freezed,
    Object? dailyLimit = null,
    Object? warningThreshold = null,
    Object? isActive = null,
    Object? firebaseDocId = freezed,
    Object? isSynced = null,
    Object? syncedAt = freezed,
    Object? localCreatedAt = null,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(_$SpendingLimitModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryIcon: freezed == categoryIcon
          ? _value.categoryIcon
          : categoryIcon // ignore: cast_nullable_to_non_nullable
              as String?,
      dailyLimit: null == dailyLimit
          ? _value.dailyLimit
          : dailyLimit // ignore: cast_nullable_to_non_nullable
              as int,
      warningThreshold: null == warningThreshold
          ? _value.warningThreshold
          : warningThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      firebaseDocId: freezed == firebaseDocId
          ? _value.firebaseDocId
          : firebaseDocId // ignore: cast_nullable_to_non_nullable
              as String?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      syncedAt: freezed == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      localCreatedAt: null == localCreatedAt
          ? _value.localCreatedAt
          : localCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpendingLimitModelImpl implements _SpendingLimitModel {
  const _$SpendingLimitModelImpl(
      {required this.id,
      required this.userId,
      this.categoryId,
      this.categoryName,
      this.categoryIcon,
      required this.dailyLimit,
      this.warningThreshold = 0.8,
      this.isActive = true,
      this.firebaseDocId,
      this.isSynced = false,
      this.syncedAt,
      required this.localCreatedAt,
      this.updatedAt,
      this.isDeleted = false});

  factory _$SpendingLimitModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpendingLimitModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;

  /// null = global (semua kategori), isi = per kategori
  @override
  final String? categoryId;
  @override
  final String? categoryName;
  @override
  final String? categoryIcon;

  /// Nominal limit harian dalam rupiah
  @override
  final int dailyLimit;

  /// Threshold notifikasi "hampir habis" (0.0 - 1.0), default 0.8 = 80%
  @override
  @JsonKey()
  final double warningThreshold;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? firebaseDocId;
  @override
  @JsonKey()
  final bool isSynced;
  @override
  final DateTime? syncedAt;
  @override
  final DateTime localCreatedAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'SpendingLimitModel(id: $id, userId: $userId, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, dailyLimit: $dailyLimit, warningThreshold: $warningThreshold, isActive: $isActive, firebaseDocId: $firebaseDocId, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpendingLimitModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.categoryIcon, categoryIcon) ||
                other.categoryIcon == categoryIcon) &&
            (identical(other.dailyLimit, dailyLimit) ||
                other.dailyLimit == dailyLimit) &&
            (identical(other.warningThreshold, warningThreshold) ||
                other.warningThreshold == warningThreshold) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.firebaseDocId, firebaseDocId) ||
                other.firebaseDocId == firebaseDocId) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced) &&
            (identical(other.syncedAt, syncedAt) ||
                other.syncedAt == syncedAt) &&
            (identical(other.localCreatedAt, localCreatedAt) ||
                other.localCreatedAt == localCreatedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      categoryId,
      categoryName,
      categoryIcon,
      dailyLimit,
      warningThreshold,
      isActive,
      firebaseDocId,
      isSynced,
      syncedAt,
      localCreatedAt,
      updatedAt,
      isDeleted);

  /// Create a copy of SpendingLimitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpendingLimitModelImplCopyWith<_$SpendingLimitModelImpl> get copyWith =>
      __$$SpendingLimitModelImplCopyWithImpl<_$SpendingLimitModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpendingLimitModelImplToJson(
      this,
    );
  }
}

abstract class _SpendingLimitModel implements SpendingLimitModel {
  const factory _SpendingLimitModel(
      {required final String id,
      required final String userId,
      final String? categoryId,
      final String? categoryName,
      final String? categoryIcon,
      required final int dailyLimit,
      final double warningThreshold,
      final bool isActive,
      final String? firebaseDocId,
      final bool isSynced,
      final DateTime? syncedAt,
      required final DateTime localCreatedAt,
      final DateTime? updatedAt,
      final bool isDeleted}) = _$SpendingLimitModelImpl;

  factory _SpendingLimitModel.fromJson(Map<String, dynamic> json) =
      _$SpendingLimitModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;

  /// null = global (semua kategori), isi = per kategori
  @override
  String? get categoryId;
  @override
  String? get categoryName;
  @override
  String? get categoryIcon;

  /// Nominal limit harian dalam rupiah
  @override
  int get dailyLimit;

  /// Threshold notifikasi "hampir habis" (0.0 - 1.0), default 0.8 = 80%
  @override
  double get warningThreshold;
  @override
  bool get isActive;
  @override
  String? get firebaseDocId;
  @override
  bool get isSynced;
  @override
  DateTime? get syncedAt;
  @override
  DateTime get localCreatedAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get isDeleted;

  /// Create a copy of SpendingLimitModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpendingLimitModelImplCopyWith<_$SpendingLimitModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
