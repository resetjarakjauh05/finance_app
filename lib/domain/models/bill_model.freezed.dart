// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillModel {

 int get id; String? get firebaseDocId; String get userId; String get name; int get nominal; int get paidAmount; DateTime get dueDate; BillStatus get status; BillType get type; String? get category; String? get categoryId; String? get categoryName; String? get notes; bool get isSynced; DateTime? get syncedAt; DateTime get localCreatedAt; DateTime? get updatedAt; bool get isDeleted;
/// Create a copy of BillModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillModelCopyWith<BillModel> get copyWith => _$BillModelCopyWithImpl<BillModel>(this as BillModel, _$identity);

  /// Serializes this BillModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillModel&&(identical(other.id, id) || other.id == id)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.nominal, nominal) || other.nominal == nominal)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firebaseDocId,userId,name,nominal,paidAmount,dueDate,status,type,category,categoryId,categoryName,notes,isSynced,syncedAt,localCreatedAt,updatedAt,isDeleted);

@override
String toString() {
  return 'BillModel(id: $id, firebaseDocId: $firebaseDocId, userId: $userId, name: $name, nominal: $nominal, paidAmount: $paidAmount, dueDate: $dueDate, status: $status, type: $type, category: $category, categoryId: $categoryId, categoryName: $categoryName, notes: $notes, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $BillModelCopyWith<$Res>  {
  factory $BillModelCopyWith(BillModel value, $Res Function(BillModel) _then) = _$BillModelCopyWithImpl;
@useResult
$Res call({
 int id, String? firebaseDocId, String userId, String name, int nominal, int paidAmount, DateTime dueDate, BillStatus status, BillType type, String? category, String? categoryId, String? categoryName, String? notes, bool isSynced, DateTime? syncedAt, DateTime localCreatedAt, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class _$BillModelCopyWithImpl<$Res>
    implements $BillModelCopyWith<$Res> {
  _$BillModelCopyWithImpl(this._self, this._then);

  final BillModel _self;
  final $Res Function(BillModel) _then;

/// Create a copy of BillModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firebaseDocId = freezed,Object? userId = null,Object? name = null,Object? nominal = null,Object? paidAmount = null,Object? dueDate = null,Object? status = null,Object? type = null,Object? category = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? notes = freezed,Object? isSynced = null,Object? syncedAt = freezed,Object? localCreatedAt = null,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firebaseDocId: freezed == firebaseDocId ? _self.firebaseDocId : firebaseDocId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nominal: null == nominal ? _self.nominal : nominal // ignore: cast_nullable_to_non_nullable
as int,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as int,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BillType,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,localCreatedAt: null == localCreatedAt ? _self.localCreatedAt : localCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BillModel].
extension BillModelPatterns on BillModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillModel value)  $default,){
final _that = this;
switch (_that) {
case _BillModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillModel value)?  $default,){
final _that = this;
switch (_that) {
case _BillModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? firebaseDocId,  String userId,  String name,  int nominal,  int paidAmount,  DateTime dueDate,  BillStatus status,  BillType type,  String? category,  String? categoryId,  String? categoryName,  String? notes,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillModel() when $default != null:
return $default(_that.id,_that.firebaseDocId,_that.userId,_that.name,_that.nominal,_that.paidAmount,_that.dueDate,_that.status,_that.type,_that.category,_that.categoryId,_that.categoryName,_that.notes,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? firebaseDocId,  String userId,  String name,  int nominal,  int paidAmount,  DateTime dueDate,  BillStatus status,  BillType type,  String? category,  String? categoryId,  String? categoryName,  String? notes,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _BillModel():
return $default(_that.id,_that.firebaseDocId,_that.userId,_that.name,_that.nominal,_that.paidAmount,_that.dueDate,_that.status,_that.type,_that.category,_that.categoryId,_that.categoryName,_that.notes,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? firebaseDocId,  String userId,  String name,  int nominal,  int paidAmount,  DateTime dueDate,  BillStatus status,  BillType type,  String? category,  String? categoryId,  String? categoryName,  String? notes,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _BillModel() when $default != null:
return $default(_that.id,_that.firebaseDocId,_that.userId,_that.name,_that.nominal,_that.paidAmount,_that.dueDate,_that.status,_that.type,_that.category,_that.categoryId,_that.categoryName,_that.notes,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillModel implements BillModel {
  const _BillModel({required this.id, this.firebaseDocId, required this.userId, required this.name, required this.nominal, this.paidAmount = 0, required this.dueDate, required this.status, this.type = BillType.hutang, this.category, this.categoryId, this.categoryName, this.notes, this.isSynced = false, this.syncedAt, required this.localCreatedAt, this.updatedAt, this.isDeleted = false});
  factory _BillModel.fromJson(Map<String, dynamic> json) => _$BillModelFromJson(json);

@override final  int id;
@override final  String? firebaseDocId;
@override final  String userId;
@override final  String name;
@override final  int nominal;
@override@JsonKey() final  int paidAmount;
@override final  DateTime dueDate;
@override final  BillStatus status;
@override@JsonKey() final  BillType type;
@override final  String? category;
@override final  String? categoryId;
@override final  String? categoryName;
@override final  String? notes;
@override@JsonKey() final  bool isSynced;
@override final  DateTime? syncedAt;
@override final  DateTime localCreatedAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of BillModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillModelCopyWith<_BillModel> get copyWith => __$BillModelCopyWithImpl<_BillModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillModel&&(identical(other.id, id) || other.id == id)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.nominal, nominal) || other.nominal == nominal)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firebaseDocId,userId,name,nominal,paidAmount,dueDate,status,type,category,categoryId,categoryName,notes,isSynced,syncedAt,localCreatedAt,updatedAt,isDeleted);

@override
String toString() {
  return 'BillModel(id: $id, firebaseDocId: $firebaseDocId, userId: $userId, name: $name, nominal: $nominal, paidAmount: $paidAmount, dueDate: $dueDate, status: $status, type: $type, category: $category, categoryId: $categoryId, categoryName: $categoryName, notes: $notes, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$BillModelCopyWith<$Res> implements $BillModelCopyWith<$Res> {
  factory _$BillModelCopyWith(_BillModel value, $Res Function(_BillModel) _then) = __$BillModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String? firebaseDocId, String userId, String name, int nominal, int paidAmount, DateTime dueDate, BillStatus status, BillType type, String? category, String? categoryId, String? categoryName, String? notes, bool isSynced, DateTime? syncedAt, DateTime localCreatedAt, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class __$BillModelCopyWithImpl<$Res>
    implements _$BillModelCopyWith<$Res> {
  __$BillModelCopyWithImpl(this._self, this._then);

  final _BillModel _self;
  final $Res Function(_BillModel) _then;

/// Create a copy of BillModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firebaseDocId = freezed,Object? userId = null,Object? name = null,Object? nominal = null,Object? paidAmount = null,Object? dueDate = null,Object? status = null,Object? type = null,Object? category = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? notes = freezed,Object? isSynced = null,Object? syncedAt = freezed,Object? localCreatedAt = null,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_BillModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firebaseDocId: freezed == firebaseDocId ? _self.firebaseDocId : firebaseDocId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nominal: null == nominal ? _self.nominal : nominal // ignore: cast_nullable_to_non_nullable
as int,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as int,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BillType,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,localCreatedAt: null == localCreatedAt ? _self.localCreatedAt : localCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
