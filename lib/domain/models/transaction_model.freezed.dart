// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionModel {

 int get id; String? get firebaseDocId; String get userId; String get description; TransactionCategory get category; String get paymentMethodId; String get paymentMethodName; int get nominal; DateTime get date; String? get notes;/// ID kategori custom (dari CategoryModel)
 String? get categoryId; String? get categoryName; bool get isSynced; DateTime? get syncedAt; DateTime get localCreatedAt; DateTime? get updatedAt; bool get isDeleted;
/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionModelCopyWith<TransactionModel> get copyWith => _$TransactionModelCopyWithImpl<TransactionModel>(this as TransactionModel, _$identity);

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.paymentMethodName, paymentMethodName) || other.paymentMethodName == paymentMethodName)&&(identical(other.nominal, nominal) || other.nominal == nominal)&&(identical(other.date, date) || other.date == date)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firebaseDocId,userId,description,category,paymentMethodId,paymentMethodName,nominal,date,notes,categoryId,categoryName,isSynced,syncedAt,localCreatedAt,updatedAt,isDeleted);

@override
String toString() {
  return 'TransactionModel(id: $id, firebaseDocId: $firebaseDocId, userId: $userId, description: $description, category: $category, paymentMethodId: $paymentMethodId, paymentMethodName: $paymentMethodName, nominal: $nominal, date: $date, notes: $notes, categoryId: $categoryId, categoryName: $categoryName, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $TransactionModelCopyWith<$Res>  {
  factory $TransactionModelCopyWith(TransactionModel value, $Res Function(TransactionModel) _then) = _$TransactionModelCopyWithImpl;
@useResult
$Res call({
 int id, String? firebaseDocId, String userId, String description, TransactionCategory category, String paymentMethodId, String paymentMethodName, int nominal, DateTime date, String? notes, String? categoryId, String? categoryName, bool isSynced, DateTime? syncedAt, DateTime localCreatedAt, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class _$TransactionModelCopyWithImpl<$Res>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._self, this._then);

  final TransactionModel _self;
  final $Res Function(TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firebaseDocId = freezed,Object? userId = null,Object? description = null,Object? category = null,Object? paymentMethodId = null,Object? paymentMethodName = null,Object? nominal = null,Object? date = null,Object? notes = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? isSynced = null,Object? syncedAt = freezed,Object? localCreatedAt = null,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firebaseDocId: freezed == firebaseDocId ? _self.firebaseDocId : firebaseDocId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TransactionCategory,paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String,paymentMethodName: null == paymentMethodName ? _self.paymentMethodName : paymentMethodName // ignore: cast_nullable_to_non_nullable
as String,nominal: null == nominal ? _self.nominal : nominal // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,localCreatedAt: null == localCreatedAt ? _self.localCreatedAt : localCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionModel].
extension TransactionModelPatterns on TransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? firebaseDocId,  String userId,  String description,  TransactionCategory category,  String paymentMethodId,  String paymentMethodName,  int nominal,  DateTime date,  String? notes,  String? categoryId,  String? categoryName,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.firebaseDocId,_that.userId,_that.description,_that.category,_that.paymentMethodId,_that.paymentMethodName,_that.nominal,_that.date,_that.notes,_that.categoryId,_that.categoryName,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? firebaseDocId,  String userId,  String description,  TransactionCategory category,  String paymentMethodId,  String paymentMethodName,  int nominal,  DateTime date,  String? notes,  String? categoryId,  String? categoryName,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that.id,_that.firebaseDocId,_that.userId,_that.description,_that.category,_that.paymentMethodId,_that.paymentMethodName,_that.nominal,_that.date,_that.notes,_that.categoryId,_that.categoryName,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? firebaseDocId,  String userId,  String description,  TransactionCategory category,  String paymentMethodId,  String paymentMethodName,  int nominal,  DateTime date,  String? notes,  String? categoryId,  String? categoryName,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.firebaseDocId,_that.userId,_that.description,_that.category,_that.paymentMethodId,_that.paymentMethodName,_that.nominal,_that.date,_that.notes,_that.categoryId,_that.categoryName,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionModel implements TransactionModel {
  const _TransactionModel({required this.id, this.firebaseDocId, required this.userId, required this.description, required this.category, required this.paymentMethodId, required this.paymentMethodName, required this.nominal, required this.date, this.notes, this.categoryId, this.categoryName, this.isSynced = false, this.syncedAt, required this.localCreatedAt, this.updatedAt, this.isDeleted = false});
  factory _TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

@override final  int id;
@override final  String? firebaseDocId;
@override final  String userId;
@override final  String description;
@override final  TransactionCategory category;
@override final  String paymentMethodId;
@override final  String paymentMethodName;
@override final  int nominal;
@override final  DateTime date;
@override final  String? notes;
/// ID kategori custom (dari CategoryModel)
@override final  String? categoryId;
@override final  String? categoryName;
@override@JsonKey() final  bool isSynced;
@override final  DateTime? syncedAt;
@override final  DateTime localCreatedAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionModelCopyWith<_TransactionModel> get copyWith => __$TransactionModelCopyWithImpl<_TransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.paymentMethodName, paymentMethodName) || other.paymentMethodName == paymentMethodName)&&(identical(other.nominal, nominal) || other.nominal == nominal)&&(identical(other.date, date) || other.date == date)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firebaseDocId,userId,description,category,paymentMethodId,paymentMethodName,nominal,date,notes,categoryId,categoryName,isSynced,syncedAt,localCreatedAt,updatedAt,isDeleted);

@override
String toString() {
  return 'TransactionModel(id: $id, firebaseDocId: $firebaseDocId, userId: $userId, description: $description, category: $category, paymentMethodId: $paymentMethodId, paymentMethodName: $paymentMethodName, nominal: $nominal, date: $date, notes: $notes, categoryId: $categoryId, categoryName: $categoryName, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$TransactionModelCopyWith<$Res> implements $TransactionModelCopyWith<$Res> {
  factory _$TransactionModelCopyWith(_TransactionModel value, $Res Function(_TransactionModel) _then) = __$TransactionModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String? firebaseDocId, String userId, String description, TransactionCategory category, String paymentMethodId, String paymentMethodName, int nominal, DateTime date, String? notes, String? categoryId, String? categoryName, bool isSynced, DateTime? syncedAt, DateTime localCreatedAt, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class __$TransactionModelCopyWithImpl<$Res>
    implements _$TransactionModelCopyWith<$Res> {
  __$TransactionModelCopyWithImpl(this._self, this._then);

  final _TransactionModel _self;
  final $Res Function(_TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firebaseDocId = freezed,Object? userId = null,Object? description = null,Object? category = null,Object? paymentMethodId = null,Object? paymentMethodName = null,Object? nominal = null,Object? date = null,Object? notes = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? isSynced = null,Object? syncedAt = freezed,Object? localCreatedAt = null,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_TransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firebaseDocId: freezed == firebaseDocId ? _self.firebaseDocId : firebaseDocId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TransactionCategory,paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String,paymentMethodName: null == paymentMethodName ? _self.paymentMethodName : paymentMethodName // ignore: cast_nullable_to_non_nullable
as String,nominal: null == nominal ? _self.nominal : nominal // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
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
