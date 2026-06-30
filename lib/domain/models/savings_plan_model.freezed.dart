// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingsPlanModel {

 String get id; String get userId; String get name; String? get description; String? get icon;/// Target total tabungan
 int get targetAmount;/// Sudah terkumpul (akumulasi dari semua alokasi)
 int get savedAmount;/// Target per bulan (opsional, sebagai panduan)
 int get monthlyTarget;/// Deadline target (opsional)
 DateTime? get targetDate;/// Rekening tujuan tabungan (ditetapkan saat buat plan)
 String? get savingsPaymentMethodId; String? get savingsPaymentMethodName; bool get isActive; String? get firebaseDocId; bool get isSynced; DateTime? get syncedAt; DateTime get localCreatedAt; DateTime? get updatedAt; bool get isDeleted;
/// Create a copy of SavingsPlanModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsPlanModelCopyWith<SavingsPlanModel> get copyWith => _$SavingsPlanModelCopyWithImpl<SavingsPlanModel>(this as SavingsPlanModel, _$identity);

  /// Serializes this SavingsPlanModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingsPlanModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.savedAmount, savedAmount) || other.savedAmount == savedAmount)&&(identical(other.monthlyTarget, monthlyTarget) || other.monthlyTarget == monthlyTarget)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.savingsPaymentMethodId, savingsPaymentMethodId) || other.savingsPaymentMethodId == savingsPaymentMethodId)&&(identical(other.savingsPaymentMethodName, savingsPaymentMethodName) || other.savingsPaymentMethodName == savingsPaymentMethodName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,description,icon,targetAmount,savedAmount,monthlyTarget,targetDate,savingsPaymentMethodId,savingsPaymentMethodName,isActive,firebaseDocId,isSynced,syncedAt,localCreatedAt,updatedAt,isDeleted);

@override
String toString() {
  return 'SavingsPlanModel(id: $id, userId: $userId, name: $name, description: $description, icon: $icon, targetAmount: $targetAmount, savedAmount: $savedAmount, monthlyTarget: $monthlyTarget, targetDate: $targetDate, savingsPaymentMethodId: $savingsPaymentMethodId, savingsPaymentMethodName: $savingsPaymentMethodName, isActive: $isActive, firebaseDocId: $firebaseDocId, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $SavingsPlanModelCopyWith<$Res>  {
  factory $SavingsPlanModelCopyWith(SavingsPlanModel value, $Res Function(SavingsPlanModel) _then) = _$SavingsPlanModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String? description, String? icon, int targetAmount, int savedAmount, int monthlyTarget, DateTime? targetDate, String? savingsPaymentMethodId, String? savingsPaymentMethodName, bool isActive, String? firebaseDocId, bool isSynced, DateTime? syncedAt, DateTime localCreatedAt, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class _$SavingsPlanModelCopyWithImpl<$Res>
    implements $SavingsPlanModelCopyWith<$Res> {
  _$SavingsPlanModelCopyWithImpl(this._self, this._then);

  final SavingsPlanModel _self;
  final $Res Function(SavingsPlanModel) _then;

/// Create a copy of SavingsPlanModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? icon = freezed,Object? targetAmount = null,Object? savedAmount = null,Object? monthlyTarget = null,Object? targetDate = freezed,Object? savingsPaymentMethodId = freezed,Object? savingsPaymentMethodName = freezed,Object? isActive = null,Object? firebaseDocId = freezed,Object? isSynced = null,Object? syncedAt = freezed,Object? localCreatedAt = null,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,savedAmount: null == savedAmount ? _self.savedAmount : savedAmount // ignore: cast_nullable_to_non_nullable
as int,monthlyTarget: null == monthlyTarget ? _self.monthlyTarget : monthlyTarget // ignore: cast_nullable_to_non_nullable
as int,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,savingsPaymentMethodId: freezed == savingsPaymentMethodId ? _self.savingsPaymentMethodId : savingsPaymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,savingsPaymentMethodName: freezed == savingsPaymentMethodName ? _self.savingsPaymentMethodName : savingsPaymentMethodName // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,firebaseDocId: freezed == firebaseDocId ? _self.firebaseDocId : firebaseDocId // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,localCreatedAt: null == localCreatedAt ? _self.localCreatedAt : localCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingsPlanModel].
extension SavingsPlanModelPatterns on SavingsPlanModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingsPlanModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingsPlanModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingsPlanModel value)  $default,){
final _that = this;
switch (_that) {
case _SavingsPlanModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingsPlanModel value)?  $default,){
final _that = this;
switch (_that) {
case _SavingsPlanModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? description,  String? icon,  int targetAmount,  int savedAmount,  int monthlyTarget,  DateTime? targetDate,  String? savingsPaymentMethodId,  String? savingsPaymentMethodName,  bool isActive,  String? firebaseDocId,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingsPlanModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.icon,_that.targetAmount,_that.savedAmount,_that.monthlyTarget,_that.targetDate,_that.savingsPaymentMethodId,_that.savingsPaymentMethodName,_that.isActive,_that.firebaseDocId,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? description,  String? icon,  int targetAmount,  int savedAmount,  int monthlyTarget,  DateTime? targetDate,  String? savingsPaymentMethodId,  String? savingsPaymentMethodName,  bool isActive,  String? firebaseDocId,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _SavingsPlanModel():
return $default(_that.id,_that.userId,_that.name,_that.description,_that.icon,_that.targetAmount,_that.savedAmount,_that.monthlyTarget,_that.targetDate,_that.savingsPaymentMethodId,_that.savingsPaymentMethodName,_that.isActive,_that.firebaseDocId,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String? description,  String? icon,  int targetAmount,  int savedAmount,  int monthlyTarget,  DateTime? targetDate,  String? savingsPaymentMethodId,  String? savingsPaymentMethodName,  bool isActive,  String? firebaseDocId,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _SavingsPlanModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.icon,_that.targetAmount,_that.savedAmount,_that.monthlyTarget,_that.targetDate,_that.savingsPaymentMethodId,_that.savingsPaymentMethodName,_that.isActive,_that.firebaseDocId,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingsPlanModel implements SavingsPlanModel {
  const _SavingsPlanModel({required this.id, required this.userId, required this.name, this.description, this.icon, required this.targetAmount, this.savedAmount = 0, this.monthlyTarget = 0, this.targetDate, this.savingsPaymentMethodId, this.savingsPaymentMethodName, this.isActive = true, this.firebaseDocId, this.isSynced = false, this.syncedAt, required this.localCreatedAt, this.updatedAt, this.isDeleted = false});
  factory _SavingsPlanModel.fromJson(Map<String, dynamic> json) => _$SavingsPlanModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String? description;
@override final  String? icon;
/// Target total tabungan
@override final  int targetAmount;
/// Sudah terkumpul (akumulasi dari semua alokasi)
@override@JsonKey() final  int savedAmount;
/// Target per bulan (opsional, sebagai panduan)
@override@JsonKey() final  int monthlyTarget;
/// Deadline target (opsional)
@override final  DateTime? targetDate;
/// Rekening tujuan tabungan (ditetapkan saat buat plan)
@override final  String? savingsPaymentMethodId;
@override final  String? savingsPaymentMethodName;
@override@JsonKey() final  bool isActive;
@override final  String? firebaseDocId;
@override@JsonKey() final  bool isSynced;
@override final  DateTime? syncedAt;
@override final  DateTime localCreatedAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of SavingsPlanModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsPlanModelCopyWith<_SavingsPlanModel> get copyWith => __$SavingsPlanModelCopyWithImpl<_SavingsPlanModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingsPlanModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingsPlanModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.savedAmount, savedAmount) || other.savedAmount == savedAmount)&&(identical(other.monthlyTarget, monthlyTarget) || other.monthlyTarget == monthlyTarget)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.savingsPaymentMethodId, savingsPaymentMethodId) || other.savingsPaymentMethodId == savingsPaymentMethodId)&&(identical(other.savingsPaymentMethodName, savingsPaymentMethodName) || other.savingsPaymentMethodName == savingsPaymentMethodName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,description,icon,targetAmount,savedAmount,monthlyTarget,targetDate,savingsPaymentMethodId,savingsPaymentMethodName,isActive,firebaseDocId,isSynced,syncedAt,localCreatedAt,updatedAt,isDeleted);

@override
String toString() {
  return 'SavingsPlanModel(id: $id, userId: $userId, name: $name, description: $description, icon: $icon, targetAmount: $targetAmount, savedAmount: $savedAmount, monthlyTarget: $monthlyTarget, targetDate: $targetDate, savingsPaymentMethodId: $savingsPaymentMethodId, savingsPaymentMethodName: $savingsPaymentMethodName, isActive: $isActive, firebaseDocId: $firebaseDocId, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$SavingsPlanModelCopyWith<$Res> implements $SavingsPlanModelCopyWith<$Res> {
  factory _$SavingsPlanModelCopyWith(_SavingsPlanModel value, $Res Function(_SavingsPlanModel) _then) = __$SavingsPlanModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String? description, String? icon, int targetAmount, int savedAmount, int monthlyTarget, DateTime? targetDate, String? savingsPaymentMethodId, String? savingsPaymentMethodName, bool isActive, String? firebaseDocId, bool isSynced, DateTime? syncedAt, DateTime localCreatedAt, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class __$SavingsPlanModelCopyWithImpl<$Res>
    implements _$SavingsPlanModelCopyWith<$Res> {
  __$SavingsPlanModelCopyWithImpl(this._self, this._then);

  final _SavingsPlanModel _self;
  final $Res Function(_SavingsPlanModel) _then;

/// Create a copy of SavingsPlanModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? icon = freezed,Object? targetAmount = null,Object? savedAmount = null,Object? monthlyTarget = null,Object? targetDate = freezed,Object? savingsPaymentMethodId = freezed,Object? savingsPaymentMethodName = freezed,Object? isActive = null,Object? firebaseDocId = freezed,Object? isSynced = null,Object? syncedAt = freezed,Object? localCreatedAt = null,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_SavingsPlanModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,savedAmount: null == savedAmount ? _self.savedAmount : savedAmount // ignore: cast_nullable_to_non_nullable
as int,monthlyTarget: null == monthlyTarget ? _self.monthlyTarget : monthlyTarget // ignore: cast_nullable_to_non_nullable
as int,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,savingsPaymentMethodId: freezed == savingsPaymentMethodId ? _self.savingsPaymentMethodId : savingsPaymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,savingsPaymentMethodName: freezed == savingsPaymentMethodName ? _self.savingsPaymentMethodName : savingsPaymentMethodName // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,firebaseDocId: freezed == firebaseDocId ? _self.firebaseDocId : firebaseDocId // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,localCreatedAt: null == localCreatedAt ? _self.localCreatedAt : localCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SavingsAllocationModel {

 String get id; String get userId; String get savingsPlanId; int get amount; String? get notes; DateTime get date;/// Rekening sumber (uang diambil dari sini)
 String get fromPaymentMethodId; String get fromPaymentMethodName;/// Rekening tujuan/tempat simpan (opsional, bisa sama)
 String? get toPaymentMethodId; String? get toPaymentMethodName;/// Biaya transfer opsional (dibebankan ke rekening sumber)
 int get transferFee; String? get firebaseDocId; bool get isSynced; DateTime get localCreatedAt; bool get isDeleted;
/// Create a copy of SavingsAllocationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsAllocationModelCopyWith<SavingsAllocationModel> get copyWith => _$SavingsAllocationModelCopyWithImpl<SavingsAllocationModel>(this as SavingsAllocationModel, _$identity);

  /// Serializes this SavingsAllocationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingsAllocationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.savingsPlanId, savingsPlanId) || other.savingsPlanId == savingsPlanId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.date, date) || other.date == date)&&(identical(other.fromPaymentMethodId, fromPaymentMethodId) || other.fromPaymentMethodId == fromPaymentMethodId)&&(identical(other.fromPaymentMethodName, fromPaymentMethodName) || other.fromPaymentMethodName == fromPaymentMethodName)&&(identical(other.toPaymentMethodId, toPaymentMethodId) || other.toPaymentMethodId == toPaymentMethodId)&&(identical(other.toPaymentMethodName, toPaymentMethodName) || other.toPaymentMethodName == toPaymentMethodName)&&(identical(other.transferFee, transferFee) || other.transferFee == transferFee)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,savingsPlanId,amount,notes,date,fromPaymentMethodId,fromPaymentMethodName,toPaymentMethodId,toPaymentMethodName,transferFee,firebaseDocId,isSynced,localCreatedAt,isDeleted);

@override
String toString() {
  return 'SavingsAllocationModel(id: $id, userId: $userId, savingsPlanId: $savingsPlanId, amount: $amount, notes: $notes, date: $date, fromPaymentMethodId: $fromPaymentMethodId, fromPaymentMethodName: $fromPaymentMethodName, toPaymentMethodId: $toPaymentMethodId, toPaymentMethodName: $toPaymentMethodName, transferFee: $transferFee, firebaseDocId: $firebaseDocId, isSynced: $isSynced, localCreatedAt: $localCreatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $SavingsAllocationModelCopyWith<$Res>  {
  factory $SavingsAllocationModelCopyWith(SavingsAllocationModel value, $Res Function(SavingsAllocationModel) _then) = _$SavingsAllocationModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String savingsPlanId, int amount, String? notes, DateTime date, String fromPaymentMethodId, String fromPaymentMethodName, String? toPaymentMethodId, String? toPaymentMethodName, int transferFee, String? firebaseDocId, bool isSynced, DateTime localCreatedAt, bool isDeleted
});




}
/// @nodoc
class _$SavingsAllocationModelCopyWithImpl<$Res>
    implements $SavingsAllocationModelCopyWith<$Res> {
  _$SavingsAllocationModelCopyWithImpl(this._self, this._then);

  final SavingsAllocationModel _self;
  final $Res Function(SavingsAllocationModel) _then;

/// Create a copy of SavingsAllocationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? savingsPlanId = null,Object? amount = null,Object? notes = freezed,Object? date = null,Object? fromPaymentMethodId = null,Object? fromPaymentMethodName = null,Object? toPaymentMethodId = freezed,Object? toPaymentMethodName = freezed,Object? transferFee = null,Object? firebaseDocId = freezed,Object? isSynced = null,Object? localCreatedAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,savingsPlanId: null == savingsPlanId ? _self.savingsPlanId : savingsPlanId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,fromPaymentMethodId: null == fromPaymentMethodId ? _self.fromPaymentMethodId : fromPaymentMethodId // ignore: cast_nullable_to_non_nullable
as String,fromPaymentMethodName: null == fromPaymentMethodName ? _self.fromPaymentMethodName : fromPaymentMethodName // ignore: cast_nullable_to_non_nullable
as String,toPaymentMethodId: freezed == toPaymentMethodId ? _self.toPaymentMethodId : toPaymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,toPaymentMethodName: freezed == toPaymentMethodName ? _self.toPaymentMethodName : toPaymentMethodName // ignore: cast_nullable_to_non_nullable
as String?,transferFee: null == transferFee ? _self.transferFee : transferFee // ignore: cast_nullable_to_non_nullable
as int,firebaseDocId: freezed == firebaseDocId ? _self.firebaseDocId : firebaseDocId // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,localCreatedAt: null == localCreatedAt ? _self.localCreatedAt : localCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingsAllocationModel].
extension SavingsAllocationModelPatterns on SavingsAllocationModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingsAllocationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingsAllocationModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingsAllocationModel value)  $default,){
final _that = this;
switch (_that) {
case _SavingsAllocationModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingsAllocationModel value)?  $default,){
final _that = this;
switch (_that) {
case _SavingsAllocationModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String savingsPlanId,  int amount,  String? notes,  DateTime date,  String fromPaymentMethodId,  String fromPaymentMethodName,  String? toPaymentMethodId,  String? toPaymentMethodName,  int transferFee,  String? firebaseDocId,  bool isSynced,  DateTime localCreatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingsAllocationModel() when $default != null:
return $default(_that.id,_that.userId,_that.savingsPlanId,_that.amount,_that.notes,_that.date,_that.fromPaymentMethodId,_that.fromPaymentMethodName,_that.toPaymentMethodId,_that.toPaymentMethodName,_that.transferFee,_that.firebaseDocId,_that.isSynced,_that.localCreatedAt,_that.isDeleted);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String savingsPlanId,  int amount,  String? notes,  DateTime date,  String fromPaymentMethodId,  String fromPaymentMethodName,  String? toPaymentMethodId,  String? toPaymentMethodName,  int transferFee,  String? firebaseDocId,  bool isSynced,  DateTime localCreatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _SavingsAllocationModel():
return $default(_that.id,_that.userId,_that.savingsPlanId,_that.amount,_that.notes,_that.date,_that.fromPaymentMethodId,_that.fromPaymentMethodName,_that.toPaymentMethodId,_that.toPaymentMethodName,_that.transferFee,_that.firebaseDocId,_that.isSynced,_that.localCreatedAt,_that.isDeleted);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String savingsPlanId,  int amount,  String? notes,  DateTime date,  String fromPaymentMethodId,  String fromPaymentMethodName,  String? toPaymentMethodId,  String? toPaymentMethodName,  int transferFee,  String? firebaseDocId,  bool isSynced,  DateTime localCreatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _SavingsAllocationModel() when $default != null:
return $default(_that.id,_that.userId,_that.savingsPlanId,_that.amount,_that.notes,_that.date,_that.fromPaymentMethodId,_that.fromPaymentMethodName,_that.toPaymentMethodId,_that.toPaymentMethodName,_that.transferFee,_that.firebaseDocId,_that.isSynced,_that.localCreatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingsAllocationModel implements SavingsAllocationModel {
  const _SavingsAllocationModel({required this.id, required this.userId, required this.savingsPlanId, required this.amount, this.notes, required this.date, required this.fromPaymentMethodId, required this.fromPaymentMethodName, this.toPaymentMethodId, this.toPaymentMethodName, this.transferFee = 0, this.firebaseDocId, this.isSynced = false, required this.localCreatedAt, this.isDeleted = false});
  factory _SavingsAllocationModel.fromJson(Map<String, dynamic> json) => _$SavingsAllocationModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String savingsPlanId;
@override final  int amount;
@override final  String? notes;
@override final  DateTime date;
/// Rekening sumber (uang diambil dari sini)
@override final  String fromPaymentMethodId;
@override final  String fromPaymentMethodName;
/// Rekening tujuan/tempat simpan (opsional, bisa sama)
@override final  String? toPaymentMethodId;
@override final  String? toPaymentMethodName;
/// Biaya transfer opsional (dibebankan ke rekening sumber)
@override@JsonKey() final  int transferFee;
@override final  String? firebaseDocId;
@override@JsonKey() final  bool isSynced;
@override final  DateTime localCreatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of SavingsAllocationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsAllocationModelCopyWith<_SavingsAllocationModel> get copyWith => __$SavingsAllocationModelCopyWithImpl<_SavingsAllocationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingsAllocationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingsAllocationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.savingsPlanId, savingsPlanId) || other.savingsPlanId == savingsPlanId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.date, date) || other.date == date)&&(identical(other.fromPaymentMethodId, fromPaymentMethodId) || other.fromPaymentMethodId == fromPaymentMethodId)&&(identical(other.fromPaymentMethodName, fromPaymentMethodName) || other.fromPaymentMethodName == fromPaymentMethodName)&&(identical(other.toPaymentMethodId, toPaymentMethodId) || other.toPaymentMethodId == toPaymentMethodId)&&(identical(other.toPaymentMethodName, toPaymentMethodName) || other.toPaymentMethodName == toPaymentMethodName)&&(identical(other.transferFee, transferFee) || other.transferFee == transferFee)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,savingsPlanId,amount,notes,date,fromPaymentMethodId,fromPaymentMethodName,toPaymentMethodId,toPaymentMethodName,transferFee,firebaseDocId,isSynced,localCreatedAt,isDeleted);

@override
String toString() {
  return 'SavingsAllocationModel(id: $id, userId: $userId, savingsPlanId: $savingsPlanId, amount: $amount, notes: $notes, date: $date, fromPaymentMethodId: $fromPaymentMethodId, fromPaymentMethodName: $fromPaymentMethodName, toPaymentMethodId: $toPaymentMethodId, toPaymentMethodName: $toPaymentMethodName, transferFee: $transferFee, firebaseDocId: $firebaseDocId, isSynced: $isSynced, localCreatedAt: $localCreatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$SavingsAllocationModelCopyWith<$Res> implements $SavingsAllocationModelCopyWith<$Res> {
  factory _$SavingsAllocationModelCopyWith(_SavingsAllocationModel value, $Res Function(_SavingsAllocationModel) _then) = __$SavingsAllocationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String savingsPlanId, int amount, String? notes, DateTime date, String fromPaymentMethodId, String fromPaymentMethodName, String? toPaymentMethodId, String? toPaymentMethodName, int transferFee, String? firebaseDocId, bool isSynced, DateTime localCreatedAt, bool isDeleted
});




}
/// @nodoc
class __$SavingsAllocationModelCopyWithImpl<$Res>
    implements _$SavingsAllocationModelCopyWith<$Res> {
  __$SavingsAllocationModelCopyWithImpl(this._self, this._then);

  final _SavingsAllocationModel _self;
  final $Res Function(_SavingsAllocationModel) _then;

/// Create a copy of SavingsAllocationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? savingsPlanId = null,Object? amount = null,Object? notes = freezed,Object? date = null,Object? fromPaymentMethodId = null,Object? fromPaymentMethodName = null,Object? toPaymentMethodId = freezed,Object? toPaymentMethodName = freezed,Object? transferFee = null,Object? firebaseDocId = freezed,Object? isSynced = null,Object? localCreatedAt = null,Object? isDeleted = null,}) {
  return _then(_SavingsAllocationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,savingsPlanId: null == savingsPlanId ? _self.savingsPlanId : savingsPlanId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,fromPaymentMethodId: null == fromPaymentMethodId ? _self.fromPaymentMethodId : fromPaymentMethodId // ignore: cast_nullable_to_non_nullable
as String,fromPaymentMethodName: null == fromPaymentMethodName ? _self.fromPaymentMethodName : fromPaymentMethodName // ignore: cast_nullable_to_non_nullable
as String,toPaymentMethodId: freezed == toPaymentMethodId ? _self.toPaymentMethodId : toPaymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,toPaymentMethodName: freezed == toPaymentMethodName ? _self.toPaymentMethodName : toPaymentMethodName // ignore: cast_nullable_to_non_nullable
as String?,transferFee: null == transferFee ? _self.transferFee : transferFee // ignore: cast_nullable_to_non_nullable
as int,firebaseDocId: freezed == firebaseDocId ? _self.firebaseDocId : firebaseDocId // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,localCreatedAt: null == localCreatedAt ? _self.localCreatedAt : localCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
