// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BillModel _$BillModelFromJson(Map<String, dynamic> json) {
  return _BillModel.fromJson(json);
}

/// @nodoc
mixin _$BillModel {
  int get id => throw _privateConstructorUsedError;
  String? get firebaseDocId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get nominal => throw _privateConstructorUsedError;
  int get paidAmount => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  BillStatus get status => throw _privateConstructorUsedError;
  BillType get type => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get isSynced => throw _privateConstructorUsedError;
  DateTime? get syncedAt => throw _privateConstructorUsedError;
  DateTime get localCreatedAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this BillModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BillModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BillModelCopyWith<BillModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillModelCopyWith<$Res> {
  factory $BillModelCopyWith(BillModel value, $Res Function(BillModel) then) =
      _$BillModelCopyWithImpl<$Res, BillModel>;
  @useResult
  $Res call(
      {int id,
      String? firebaseDocId,
      String userId,
      String name,
      int nominal,
      int paidAmount,
      DateTime dueDate,
      BillStatus status,
      BillType type,
      String? category,
      String? categoryId,
      String? categoryName,
      String? notes,
      bool isSynced,
      DateTime? syncedAt,
      DateTime localCreatedAt,
      DateTime? updatedAt,
      bool isDeleted});
}

/// @nodoc
class _$BillModelCopyWithImpl<$Res, $Val extends BillModel>
    implements $BillModelCopyWith<$Res> {
  _$BillModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BillModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firebaseDocId = freezed,
    Object? userId = null,
    Object? name = null,
    Object? nominal = null,
    Object? paidAmount = null,
    Object? dueDate = null,
    Object? status = null,
    Object? type = null,
    Object? category = freezed,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? notes = freezed,
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
              as int,
      firebaseDocId: freezed == firebaseDocId
          ? _value.firebaseDocId
          : firebaseDocId // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nominal: null == nominal
          ? _value.nominal
          : nominal // ignore: cast_nullable_to_non_nullable
              as int,
      paidAmount: null == paidAmount
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as int,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BillStatus,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BillType,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$BillModelImplCopyWith<$Res>
    implements $BillModelCopyWith<$Res> {
  factory _$$BillModelImplCopyWith(
          _$BillModelImpl value, $Res Function(_$BillModelImpl) then) =
      __$$BillModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String? firebaseDocId,
      String userId,
      String name,
      int nominal,
      int paidAmount,
      DateTime dueDate,
      BillStatus status,
      BillType type,
      String? category,
      String? categoryId,
      String? categoryName,
      String? notes,
      bool isSynced,
      DateTime? syncedAt,
      DateTime localCreatedAt,
      DateTime? updatedAt,
      bool isDeleted});
}

/// @nodoc
class __$$BillModelImplCopyWithImpl<$Res>
    extends _$BillModelCopyWithImpl<$Res, _$BillModelImpl>
    implements _$$BillModelImplCopyWith<$Res> {
  __$$BillModelImplCopyWithImpl(
      _$BillModelImpl _value, $Res Function(_$BillModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BillModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firebaseDocId = freezed,
    Object? userId = null,
    Object? name = null,
    Object? nominal = null,
    Object? paidAmount = null,
    Object? dueDate = null,
    Object? status = null,
    Object? type = null,
    Object? category = freezed,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? notes = freezed,
    Object? isSynced = null,
    Object? syncedAt = freezed,
    Object? localCreatedAt = null,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(_$BillModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      firebaseDocId: freezed == firebaseDocId
          ? _value.firebaseDocId
          : firebaseDocId // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nominal: null == nominal
          ? _value.nominal
          : nominal // ignore: cast_nullable_to_non_nullable
              as int,
      paidAmount: null == paidAmount
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as int,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BillStatus,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BillType,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
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
class _$BillModelImpl implements _BillModel {
  const _$BillModelImpl(
      {required this.id,
      this.firebaseDocId,
      required this.userId,
      required this.name,
      required this.nominal,
      this.paidAmount = 0,
      required this.dueDate,
      required this.status,
      this.type = BillType.hutang,
      this.category,
      this.categoryId,
      this.categoryName,
      this.notes,
      this.isSynced = false,
      this.syncedAt,
      required this.localCreatedAt,
      this.updatedAt,
      this.isDeleted = false});

  factory _$BillModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BillModelImplFromJson(json);

  @override
  final int id;
  @override
  final String? firebaseDocId;
  @override
  final String userId;
  @override
  final String name;
  @override
  final int nominal;
  @override
  @JsonKey()
  final int paidAmount;
  @override
  final DateTime dueDate;
  @override
  final BillStatus status;
  @override
  @JsonKey()
  final BillType type;
  @override
  final String? category;
  @override
  final String? categoryId;
  @override
  final String? categoryName;
  @override
  final String? notes;
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
    return 'BillModel(id: $id, firebaseDocId: $firebaseDocId, userId: $userId, name: $name, nominal: $nominal, paidAmount: $paidAmount, dueDate: $dueDate, status: $status, type: $type, category: $category, categoryId: $categoryId, categoryName: $categoryName, notes: $notes, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firebaseDocId, firebaseDocId) ||
                other.firebaseDocId == firebaseDocId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nominal, nominal) || other.nominal == nominal) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.notes, notes) || other.notes == notes) &&
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
      firebaseDocId,
      userId,
      name,
      nominal,
      paidAmount,
      dueDate,
      status,
      type,
      category,
      categoryId,
      categoryName,
      notes,
      isSynced,
      syncedAt,
      localCreatedAt,
      updatedAt,
      isDeleted);

  /// Create a copy of BillModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BillModelImplCopyWith<_$BillModelImpl> get copyWith =>
      __$$BillModelImplCopyWithImpl<_$BillModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BillModelImplToJson(
      this,
    );
  }
}

abstract class _BillModel implements BillModel {
  const factory _BillModel(
      {required final int id,
      final String? firebaseDocId,
      required final String userId,
      required final String name,
      required final int nominal,
      final int paidAmount,
      required final DateTime dueDate,
      required final BillStatus status,
      final BillType type,
      final String? category,
      final String? categoryId,
      final String? categoryName,
      final String? notes,
      final bool isSynced,
      final DateTime? syncedAt,
      required final DateTime localCreatedAt,
      final DateTime? updatedAt,
      final bool isDeleted}) = _$BillModelImpl;

  factory _BillModel.fromJson(Map<String, dynamic> json) =
      _$BillModelImpl.fromJson;

  @override
  int get id;
  @override
  String? get firebaseDocId;
  @override
  String get userId;
  @override
  String get name;
  @override
  int get nominal;
  @override
  int get paidAmount;
  @override
  DateTime get dueDate;
  @override
  BillStatus get status;
  @override
  BillType get type;
  @override
  String? get category;
  @override
  String? get categoryId;
  @override
  String? get categoryName;
  @override
  String? get notes;
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

  /// Create a copy of BillModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BillModelImplCopyWith<_$BillModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
