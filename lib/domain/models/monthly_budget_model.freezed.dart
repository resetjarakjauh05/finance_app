// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_budget_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MonthlyBudgetModel _$MonthlyBudgetModelFromJson(Map<String, dynamic> json) {
  return _MonthlyBudgetModel.fromJson(json);
}

/// @nodoc
mixin _$MonthlyBudgetModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// Format: 'yyyy-MM' misal '2026-06'
  String get yearMonth => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String get categoryIcon => throw _privateConstructorUsedError;

  /// Target anggaran bulan ini
  int get budgetAmount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get firebaseDocId => throw _privateConstructorUsedError;
  bool get isSynced => throw _privateConstructorUsedError;
  DateTime? get syncedAt => throw _privateConstructorUsedError;
  DateTime get localCreatedAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this MonthlyBudgetModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyBudgetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyBudgetModelCopyWith<MonthlyBudgetModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyBudgetModelCopyWith<$Res> {
  factory $MonthlyBudgetModelCopyWith(
          MonthlyBudgetModel value, $Res Function(MonthlyBudgetModel) then) =
      _$MonthlyBudgetModelCopyWithImpl<$Res, MonthlyBudgetModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String yearMonth,
      String categoryId,
      String categoryName,
      String categoryIcon,
      int budgetAmount,
      String? notes,
      String? firebaseDocId,
      bool isSynced,
      DateTime? syncedAt,
      DateTime localCreatedAt,
      DateTime? updatedAt,
      bool isDeleted});
}

/// @nodoc
class _$MonthlyBudgetModelCopyWithImpl<$Res, $Val extends MonthlyBudgetModel>
    implements $MonthlyBudgetModelCopyWith<$Res> {
  _$MonthlyBudgetModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyBudgetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? yearMonth = null,
    Object? categoryId = null,
    Object? categoryName = null,
    Object? categoryIcon = null,
    Object? budgetAmount = null,
    Object? notes = freezed,
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
      yearMonth: null == yearMonth
          ? _value.yearMonth
          : yearMonth // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      categoryIcon: null == categoryIcon
          ? _value.categoryIcon
          : categoryIcon // ignore: cast_nullable_to_non_nullable
              as String,
      budgetAmount: null == budgetAmount
          ? _value.budgetAmount
          : budgetAmount // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$MonthlyBudgetModelImplCopyWith<$Res>
    implements $MonthlyBudgetModelCopyWith<$Res> {
  factory _$$MonthlyBudgetModelImplCopyWith(_$MonthlyBudgetModelImpl value,
          $Res Function(_$MonthlyBudgetModelImpl) then) =
      __$$MonthlyBudgetModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String yearMonth,
      String categoryId,
      String categoryName,
      String categoryIcon,
      int budgetAmount,
      String? notes,
      String? firebaseDocId,
      bool isSynced,
      DateTime? syncedAt,
      DateTime localCreatedAt,
      DateTime? updatedAt,
      bool isDeleted});
}

/// @nodoc
class __$$MonthlyBudgetModelImplCopyWithImpl<$Res>
    extends _$MonthlyBudgetModelCopyWithImpl<$Res, _$MonthlyBudgetModelImpl>
    implements _$$MonthlyBudgetModelImplCopyWith<$Res> {
  __$$MonthlyBudgetModelImplCopyWithImpl(_$MonthlyBudgetModelImpl _value,
      $Res Function(_$MonthlyBudgetModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MonthlyBudgetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? yearMonth = null,
    Object? categoryId = null,
    Object? categoryName = null,
    Object? categoryIcon = null,
    Object? budgetAmount = null,
    Object? notes = freezed,
    Object? firebaseDocId = freezed,
    Object? isSynced = null,
    Object? syncedAt = freezed,
    Object? localCreatedAt = null,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(_$MonthlyBudgetModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      yearMonth: null == yearMonth
          ? _value.yearMonth
          : yearMonth // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      categoryIcon: null == categoryIcon
          ? _value.categoryIcon
          : categoryIcon // ignore: cast_nullable_to_non_nullable
              as String,
      budgetAmount: null == budgetAmount
          ? _value.budgetAmount
          : budgetAmount // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$MonthlyBudgetModelImpl implements _MonthlyBudgetModel {
  const _$MonthlyBudgetModelImpl(
      {required this.id,
      required this.userId,
      required this.yearMonth,
      required this.categoryId,
      required this.categoryName,
      required this.categoryIcon,
      required this.budgetAmount,
      this.notes,
      this.firebaseDocId,
      this.isSynced = false,
      this.syncedAt,
      required this.localCreatedAt,
      this.updatedAt,
      this.isDeleted = false});

  factory _$MonthlyBudgetModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyBudgetModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;

  /// Format: 'yyyy-MM' misal '2026-06'
  @override
  final String yearMonth;
  @override
  final String categoryId;
  @override
  final String categoryName;
  @override
  final String categoryIcon;

  /// Target anggaran bulan ini
  @override
  final int budgetAmount;
  @override
  final String? notes;
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
    return 'MonthlyBudgetModel(id: $id, userId: $userId, yearMonth: $yearMonth, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, budgetAmount: $budgetAmount, notes: $notes, firebaseDocId: $firebaseDocId, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyBudgetModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.yearMonth, yearMonth) ||
                other.yearMonth == yearMonth) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.categoryIcon, categoryIcon) ||
                other.categoryIcon == categoryIcon) &&
            (identical(other.budgetAmount, budgetAmount) ||
                other.budgetAmount == budgetAmount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
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
      yearMonth,
      categoryId,
      categoryName,
      categoryIcon,
      budgetAmount,
      notes,
      firebaseDocId,
      isSynced,
      syncedAt,
      localCreatedAt,
      updatedAt,
      isDeleted);

  /// Create a copy of MonthlyBudgetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyBudgetModelImplCopyWith<_$MonthlyBudgetModelImpl> get copyWith =>
      __$$MonthlyBudgetModelImplCopyWithImpl<_$MonthlyBudgetModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyBudgetModelImplToJson(
      this,
    );
  }
}

abstract class _MonthlyBudgetModel implements MonthlyBudgetModel {
  const factory _MonthlyBudgetModel(
      {required final String id,
      required final String userId,
      required final String yearMonth,
      required final String categoryId,
      required final String categoryName,
      required final String categoryIcon,
      required final int budgetAmount,
      final String? notes,
      final String? firebaseDocId,
      final bool isSynced,
      final DateTime? syncedAt,
      required final DateTime localCreatedAt,
      final DateTime? updatedAt,
      final bool isDeleted}) = _$MonthlyBudgetModelImpl;

  factory _MonthlyBudgetModel.fromJson(Map<String, dynamic> json) =
      _$MonthlyBudgetModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;

  /// Format: 'yyyy-MM' misal '2026-06'
  @override
  String get yearMonth;
  @override
  String get categoryId;
  @override
  String get categoryName;
  @override
  String get categoryIcon;

  /// Target anggaran bulan ini
  @override
  int get budgetAmount;
  @override
  String? get notes;
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

  /// Create a copy of MonthlyBudgetModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyBudgetModelImplCopyWith<_$MonthlyBudgetModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
