// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SavingsPlanModel _$SavingsPlanModelFromJson(Map<String, dynamic> json) {
  return _SavingsPlanModel.fromJson(json);
}

/// @nodoc
mixin _$SavingsPlanModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;

  /// Target total tabungan
  int get targetAmount => throw _privateConstructorUsedError;

  /// Sudah terkumpul (akumulasi dari semua alokasi)
  int get savedAmount => throw _privateConstructorUsedError;

  /// Target per bulan (opsional, sebagai panduan)
  int get monthlyTarget => throw _privateConstructorUsedError;

  /// Deadline target (opsional)
  DateTime? get targetDate => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get firebaseDocId => throw _privateConstructorUsedError;
  bool get isSynced => throw _privateConstructorUsedError;
  DateTime? get syncedAt => throw _privateConstructorUsedError;
  DateTime get localCreatedAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this SavingsPlanModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavingsPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavingsPlanModelCopyWith<SavingsPlanModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavingsPlanModelCopyWith<$Res> {
  factory $SavingsPlanModelCopyWith(
          SavingsPlanModel value, $Res Function(SavingsPlanModel) then) =
      _$SavingsPlanModelCopyWithImpl<$Res, SavingsPlanModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      String? icon,
      int targetAmount,
      int savedAmount,
      int monthlyTarget,
      DateTime? targetDate,
      bool isActive,
      String? firebaseDocId,
      bool isSynced,
      DateTime? syncedAt,
      DateTime localCreatedAt,
      DateTime? updatedAt,
      bool isDeleted});
}

/// @nodoc
class _$SavingsPlanModelCopyWithImpl<$Res, $Val extends SavingsPlanModel>
    implements $SavingsPlanModelCopyWith<$Res> {
  _$SavingsPlanModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavingsPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = freezed,
    Object? targetAmount = null,
    Object? savedAmount = null,
    Object? monthlyTarget = null,
    Object? targetDate = freezed,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as int,
      savedAmount: null == savedAmount
          ? _value.savedAmount
          : savedAmount // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyTarget: null == monthlyTarget
          ? _value.monthlyTarget
          : monthlyTarget // ignore: cast_nullable_to_non_nullable
              as int,
      targetDate: freezed == targetDate
          ? _value.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
abstract class _$$SavingsPlanModelImplCopyWith<$Res>
    implements $SavingsPlanModelCopyWith<$Res> {
  factory _$$SavingsPlanModelImplCopyWith(_$SavingsPlanModelImpl value,
          $Res Function(_$SavingsPlanModelImpl) then) =
      __$$SavingsPlanModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      String? icon,
      int targetAmount,
      int savedAmount,
      int monthlyTarget,
      DateTime? targetDate,
      bool isActive,
      String? firebaseDocId,
      bool isSynced,
      DateTime? syncedAt,
      DateTime localCreatedAt,
      DateTime? updatedAt,
      bool isDeleted});
}

/// @nodoc
class __$$SavingsPlanModelImplCopyWithImpl<$Res>
    extends _$SavingsPlanModelCopyWithImpl<$Res, _$SavingsPlanModelImpl>
    implements _$$SavingsPlanModelImplCopyWith<$Res> {
  __$$SavingsPlanModelImplCopyWithImpl(_$SavingsPlanModelImpl _value,
      $Res Function(_$SavingsPlanModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SavingsPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = freezed,
    Object? targetAmount = null,
    Object? savedAmount = null,
    Object? monthlyTarget = null,
    Object? targetDate = freezed,
    Object? isActive = null,
    Object? firebaseDocId = freezed,
    Object? isSynced = null,
    Object? syncedAt = freezed,
    Object? localCreatedAt = null,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(_$SavingsPlanModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as int,
      savedAmount: null == savedAmount
          ? _value.savedAmount
          : savedAmount // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyTarget: null == monthlyTarget
          ? _value.monthlyTarget
          : monthlyTarget // ignore: cast_nullable_to_non_nullable
              as int,
      targetDate: freezed == targetDate
          ? _value.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$SavingsPlanModelImpl implements _SavingsPlanModel {
  const _$SavingsPlanModelImpl(
      {required this.id,
      required this.userId,
      required this.name,
      this.description,
      this.icon,
      required this.targetAmount,
      this.savedAmount = 0,
      this.monthlyTarget = 0,
      this.targetDate,
      this.isActive = true,
      this.firebaseDocId,
      this.isSynced = false,
      this.syncedAt,
      required this.localCreatedAt,
      this.updatedAt,
      this.isDeleted = false});

  factory _$SavingsPlanModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavingsPlanModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? icon;

  /// Target total tabungan
  @override
  final int targetAmount;

  /// Sudah terkumpul (akumulasi dari semua alokasi)
  @override
  @JsonKey()
  final int savedAmount;

  /// Target per bulan (opsional, sebagai panduan)
  @override
  @JsonKey()
  final int monthlyTarget;

  /// Deadline target (opsional)
  @override
  final DateTime? targetDate;
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
    return 'SavingsPlanModel(id: $id, userId: $userId, name: $name, description: $description, icon: $icon, targetAmount: $targetAmount, savedAmount: $savedAmount, monthlyTarget: $monthlyTarget, targetDate: $targetDate, isActive: $isActive, firebaseDocId: $firebaseDocId, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavingsPlanModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.savedAmount, savedAmount) ||
                other.savedAmount == savedAmount) &&
            (identical(other.monthlyTarget, monthlyTarget) ||
                other.monthlyTarget == monthlyTarget) &&
            (identical(other.targetDate, targetDate) ||
                other.targetDate == targetDate) &&
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
      name,
      description,
      icon,
      targetAmount,
      savedAmount,
      monthlyTarget,
      targetDate,
      isActive,
      firebaseDocId,
      isSynced,
      syncedAt,
      localCreatedAt,
      updatedAt,
      isDeleted);

  /// Create a copy of SavingsPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavingsPlanModelImplCopyWith<_$SavingsPlanModelImpl> get copyWith =>
      __$$SavingsPlanModelImplCopyWithImpl<_$SavingsPlanModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavingsPlanModelImplToJson(
      this,
    );
  }
}

abstract class _SavingsPlanModel implements SavingsPlanModel {
  const factory _SavingsPlanModel(
      {required final String id,
      required final String userId,
      required final String name,
      final String? description,
      final String? icon,
      required final int targetAmount,
      final int savedAmount,
      final int monthlyTarget,
      final DateTime? targetDate,
      final bool isActive,
      final String? firebaseDocId,
      final bool isSynced,
      final DateTime? syncedAt,
      required final DateTime localCreatedAt,
      final DateTime? updatedAt,
      final bool isDeleted}) = _$SavingsPlanModelImpl;

  factory _SavingsPlanModel.fromJson(Map<String, dynamic> json) =
      _$SavingsPlanModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get icon;

  /// Target total tabungan
  @override
  int get targetAmount;

  /// Sudah terkumpul (akumulasi dari semua alokasi)
  @override
  int get savedAmount;

  /// Target per bulan (opsional, sebagai panduan)
  @override
  int get monthlyTarget;

  /// Deadline target (opsional)
  @override
  DateTime? get targetDate;
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

  /// Create a copy of SavingsPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavingsPlanModelImplCopyWith<_$SavingsPlanModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SavingsAllocationModel _$SavingsAllocationModelFromJson(
    Map<String, dynamic> json) {
  return _SavingsAllocationModel.fromJson(json);
}

/// @nodoc
mixin _$SavingsAllocationModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get savingsPlanId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// Rekening sumber (uang diambil dari sini)
  String get fromPaymentMethodId => throw _privateConstructorUsedError;
  String get fromPaymentMethodName => throw _privateConstructorUsedError;

  /// Rekening tujuan/tempat simpan (opsional, bisa sama)
  String? get toPaymentMethodId => throw _privateConstructorUsedError;
  String? get toPaymentMethodName => throw _privateConstructorUsedError;

  /// Biaya transfer opsional (dibebankan ke rekening sumber)
  int get transferFee => throw _privateConstructorUsedError;
  String? get firebaseDocId => throw _privateConstructorUsedError;
  bool get isSynced => throw _privateConstructorUsedError;
  DateTime get localCreatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this SavingsAllocationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavingsAllocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavingsAllocationModelCopyWith<SavingsAllocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavingsAllocationModelCopyWith<$Res> {
  factory $SavingsAllocationModelCopyWith(SavingsAllocationModel value,
          $Res Function(SavingsAllocationModel) then) =
      _$SavingsAllocationModelCopyWithImpl<$Res, SavingsAllocationModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String savingsPlanId,
      int amount,
      String? notes,
      DateTime date,
      String fromPaymentMethodId,
      String fromPaymentMethodName,
      String? toPaymentMethodId,
      String? toPaymentMethodName,
      int transferFee,
      String? firebaseDocId,
      bool isSynced,
      DateTime localCreatedAt,
      bool isDeleted});
}

/// @nodoc
class _$SavingsAllocationModelCopyWithImpl<$Res,
        $Val extends SavingsAllocationModel>
    implements $SavingsAllocationModelCopyWith<$Res> {
  _$SavingsAllocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavingsAllocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? savingsPlanId = null,
    Object? amount = null,
    Object? notes = freezed,
    Object? date = null,
    Object? fromPaymentMethodId = null,
    Object? fromPaymentMethodName = null,
    Object? toPaymentMethodId = freezed,
    Object? toPaymentMethodName = freezed,
    Object? transferFee = null,
    Object? firebaseDocId = freezed,
    Object? isSynced = null,
    Object? localCreatedAt = null,
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
      savingsPlanId: null == savingsPlanId
          ? _value.savingsPlanId
          : savingsPlanId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fromPaymentMethodId: null == fromPaymentMethodId
          ? _value.fromPaymentMethodId
          : fromPaymentMethodId // ignore: cast_nullable_to_non_nullable
              as String,
      fromPaymentMethodName: null == fromPaymentMethodName
          ? _value.fromPaymentMethodName
          : fromPaymentMethodName // ignore: cast_nullable_to_non_nullable
              as String,
      toPaymentMethodId: freezed == toPaymentMethodId
          ? _value.toPaymentMethodId
          : toPaymentMethodId // ignore: cast_nullable_to_non_nullable
              as String?,
      toPaymentMethodName: freezed == toPaymentMethodName
          ? _value.toPaymentMethodName
          : toPaymentMethodName // ignore: cast_nullable_to_non_nullable
              as String?,
      transferFee: null == transferFee
          ? _value.transferFee
          : transferFee // ignore: cast_nullable_to_non_nullable
              as int,
      firebaseDocId: freezed == firebaseDocId
          ? _value.firebaseDocId
          : firebaseDocId // ignore: cast_nullable_to_non_nullable
              as String?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      localCreatedAt: null == localCreatedAt
          ? _value.localCreatedAt
          : localCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SavingsAllocationModelImplCopyWith<$Res>
    implements $SavingsAllocationModelCopyWith<$Res> {
  factory _$$SavingsAllocationModelImplCopyWith(
          _$SavingsAllocationModelImpl value,
          $Res Function(_$SavingsAllocationModelImpl) then) =
      __$$SavingsAllocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String savingsPlanId,
      int amount,
      String? notes,
      DateTime date,
      String fromPaymentMethodId,
      String fromPaymentMethodName,
      String? toPaymentMethodId,
      String? toPaymentMethodName,
      int transferFee,
      String? firebaseDocId,
      bool isSynced,
      DateTime localCreatedAt,
      bool isDeleted});
}

/// @nodoc
class __$$SavingsAllocationModelImplCopyWithImpl<$Res>
    extends _$SavingsAllocationModelCopyWithImpl<$Res,
        _$SavingsAllocationModelImpl>
    implements _$$SavingsAllocationModelImplCopyWith<$Res> {
  __$$SavingsAllocationModelImplCopyWithImpl(
      _$SavingsAllocationModelImpl _value,
      $Res Function(_$SavingsAllocationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SavingsAllocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? savingsPlanId = null,
    Object? amount = null,
    Object? notes = freezed,
    Object? date = null,
    Object? fromPaymentMethodId = null,
    Object? fromPaymentMethodName = null,
    Object? toPaymentMethodId = freezed,
    Object? toPaymentMethodName = freezed,
    Object? transferFee = null,
    Object? firebaseDocId = freezed,
    Object? isSynced = null,
    Object? localCreatedAt = null,
    Object? isDeleted = null,
  }) {
    return _then(_$SavingsAllocationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      savingsPlanId: null == savingsPlanId
          ? _value.savingsPlanId
          : savingsPlanId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fromPaymentMethodId: null == fromPaymentMethodId
          ? _value.fromPaymentMethodId
          : fromPaymentMethodId // ignore: cast_nullable_to_non_nullable
              as String,
      fromPaymentMethodName: null == fromPaymentMethodName
          ? _value.fromPaymentMethodName
          : fromPaymentMethodName // ignore: cast_nullable_to_non_nullable
              as String,
      toPaymentMethodId: freezed == toPaymentMethodId
          ? _value.toPaymentMethodId
          : toPaymentMethodId // ignore: cast_nullable_to_non_nullable
              as String?,
      toPaymentMethodName: freezed == toPaymentMethodName
          ? _value.toPaymentMethodName
          : toPaymentMethodName // ignore: cast_nullable_to_non_nullable
              as String?,
      transferFee: null == transferFee
          ? _value.transferFee
          : transferFee // ignore: cast_nullable_to_non_nullable
              as int,
      firebaseDocId: freezed == firebaseDocId
          ? _value.firebaseDocId
          : firebaseDocId // ignore: cast_nullable_to_non_nullable
              as String?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      localCreatedAt: null == localCreatedAt
          ? _value.localCreatedAt
          : localCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SavingsAllocationModelImpl implements _SavingsAllocationModel {
  const _$SavingsAllocationModelImpl(
      {required this.id,
      required this.userId,
      required this.savingsPlanId,
      required this.amount,
      this.notes,
      required this.date,
      required this.fromPaymentMethodId,
      required this.fromPaymentMethodName,
      this.toPaymentMethodId,
      this.toPaymentMethodName,
      this.transferFee = 0,
      this.firebaseDocId,
      this.isSynced = false,
      required this.localCreatedAt,
      this.isDeleted = false});

  factory _$SavingsAllocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavingsAllocationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String savingsPlanId;
  @override
  final int amount;
  @override
  final String? notes;
  @override
  final DateTime date;

  /// Rekening sumber (uang diambil dari sini)
  @override
  final String fromPaymentMethodId;
  @override
  final String fromPaymentMethodName;

  /// Rekening tujuan/tempat simpan (opsional, bisa sama)
  @override
  final String? toPaymentMethodId;
  @override
  final String? toPaymentMethodName;

  /// Biaya transfer opsional (dibebankan ke rekening sumber)
  @override
  @JsonKey()
  final int transferFee;
  @override
  final String? firebaseDocId;
  @override
  @JsonKey()
  final bool isSynced;
  @override
  final DateTime localCreatedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'SavingsAllocationModel(id: $id, userId: $userId, savingsPlanId: $savingsPlanId, amount: $amount, notes: $notes, date: $date, fromPaymentMethodId: $fromPaymentMethodId, fromPaymentMethodName: $fromPaymentMethodName, toPaymentMethodId: $toPaymentMethodId, toPaymentMethodName: $toPaymentMethodName, transferFee: $transferFee, firebaseDocId: $firebaseDocId, isSynced: $isSynced, localCreatedAt: $localCreatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavingsAllocationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.savingsPlanId, savingsPlanId) ||
                other.savingsPlanId == savingsPlanId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.fromPaymentMethodId, fromPaymentMethodId) ||
                other.fromPaymentMethodId == fromPaymentMethodId) &&
            (identical(other.fromPaymentMethodName, fromPaymentMethodName) ||
                other.fromPaymentMethodName == fromPaymentMethodName) &&
            (identical(other.toPaymentMethodId, toPaymentMethodId) ||
                other.toPaymentMethodId == toPaymentMethodId) &&
            (identical(other.toPaymentMethodName, toPaymentMethodName) ||
                other.toPaymentMethodName == toPaymentMethodName) &&
            (identical(other.transferFee, transferFee) ||
                other.transferFee == transferFee) &&
            (identical(other.firebaseDocId, firebaseDocId) ||
                other.firebaseDocId == firebaseDocId) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced) &&
            (identical(other.localCreatedAt, localCreatedAt) ||
                other.localCreatedAt == localCreatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      savingsPlanId,
      amount,
      notes,
      date,
      fromPaymentMethodId,
      fromPaymentMethodName,
      toPaymentMethodId,
      toPaymentMethodName,
      transferFee,
      firebaseDocId,
      isSynced,
      localCreatedAt,
      isDeleted);

  /// Create a copy of SavingsAllocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavingsAllocationModelImplCopyWith<_$SavingsAllocationModelImpl>
      get copyWith => __$$SavingsAllocationModelImplCopyWithImpl<
          _$SavingsAllocationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavingsAllocationModelImplToJson(
      this,
    );
  }
}

abstract class _SavingsAllocationModel implements SavingsAllocationModel {
  const factory _SavingsAllocationModel(
      {required final String id,
      required final String userId,
      required final String savingsPlanId,
      required final int amount,
      final String? notes,
      required final DateTime date,
      required final String fromPaymentMethodId,
      required final String fromPaymentMethodName,
      final String? toPaymentMethodId,
      final String? toPaymentMethodName,
      final int transferFee,
      final String? firebaseDocId,
      final bool isSynced,
      required final DateTime localCreatedAt,
      final bool isDeleted}) = _$SavingsAllocationModelImpl;

  factory _SavingsAllocationModel.fromJson(Map<String, dynamic> json) =
      _$SavingsAllocationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get savingsPlanId;
  @override
  int get amount;
  @override
  String? get notes;
  @override
  DateTime get date;

  /// Rekening sumber (uang diambil dari sini)
  @override
  String get fromPaymentMethodId;
  @override
  String get fromPaymentMethodName;

  /// Rekening tujuan/tempat simpan (opsional, bisa sama)
  @override
  String? get toPaymentMethodId;
  @override
  String? get toPaymentMethodName;

  /// Biaya transfer opsional (dibebankan ke rekening sumber)
  @override
  int get transferFee;
  @override
  String? get firebaseDocId;
  @override
  bool get isSynced;
  @override
  DateTime get localCreatedAt;
  @override
  bool get isDeleted;

  /// Create a copy of SavingsAllocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavingsAllocationModelImplCopyWith<_$SavingsAllocationModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
