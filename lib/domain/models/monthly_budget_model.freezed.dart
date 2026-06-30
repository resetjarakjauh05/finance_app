// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_budget_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthlyBudgetModel {

 String get id; String get userId;/// Format: 'yyyy-MM' misal '2026-06'
 String get yearMonth; String get categoryId; String get categoryName; String get categoryIcon;/// Target anggaran bulan ini
 int get budgetAmount; String? get notes; String? get firebaseDocId; bool get isSynced; DateTime? get syncedAt; DateTime get localCreatedAt; DateTime? get updatedAt; bool get isDeleted;
/// Create a copy of MonthlyBudgetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyBudgetModelCopyWith<MonthlyBudgetModel> get copyWith => _$MonthlyBudgetModelCopyWithImpl<MonthlyBudgetModel>(this as MonthlyBudgetModel, _$identity);

  /// Serializes this MonthlyBudgetModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyBudgetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIcon, categoryIcon) || other.categoryIcon == categoryIcon)&&(identical(other.budgetAmount, budgetAmount) || other.budgetAmount == budgetAmount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,yearMonth,categoryId,categoryName,categoryIcon,budgetAmount,notes,firebaseDocId,isSynced,syncedAt,localCreatedAt,updatedAt,isDeleted);

@override
String toString() {
  return 'MonthlyBudgetModel(id: $id, userId: $userId, yearMonth: $yearMonth, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, budgetAmount: $budgetAmount, notes: $notes, firebaseDocId: $firebaseDocId, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $MonthlyBudgetModelCopyWith<$Res>  {
  factory $MonthlyBudgetModelCopyWith(MonthlyBudgetModel value, $Res Function(MonthlyBudgetModel) _then) = _$MonthlyBudgetModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String yearMonth, String categoryId, String categoryName, String categoryIcon, int budgetAmount, String? notes, String? firebaseDocId, bool isSynced, DateTime? syncedAt, DateTime localCreatedAt, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class _$MonthlyBudgetModelCopyWithImpl<$Res>
    implements $MonthlyBudgetModelCopyWith<$Res> {
  _$MonthlyBudgetModelCopyWithImpl(this._self, this._then);

  final MonthlyBudgetModel _self;
  final $Res Function(MonthlyBudgetModel) _then;

/// Create a copy of MonthlyBudgetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? yearMonth = null,Object? categoryId = null,Object? categoryName = null,Object? categoryIcon = null,Object? budgetAmount = null,Object? notes = freezed,Object? firebaseDocId = freezed,Object? isSynced = null,Object? syncedAt = freezed,Object? localCreatedAt = null,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,categoryIcon: null == categoryIcon ? _self.categoryIcon : categoryIcon // ignore: cast_nullable_to_non_nullable
as String,budgetAmount: null == budgetAmount ? _self.budgetAmount : budgetAmount // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,firebaseDocId: freezed == firebaseDocId ? _self.firebaseDocId : firebaseDocId // ignore: cast_nullable_to_non_nullable
as String?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,localCreatedAt: null == localCreatedAt ? _self.localCreatedAt : localCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyBudgetModel].
extension MonthlyBudgetModelPatterns on MonthlyBudgetModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyBudgetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyBudgetModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyBudgetModel value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyBudgetModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyBudgetModel value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyBudgetModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String yearMonth,  String categoryId,  String categoryName,  String categoryIcon,  int budgetAmount,  String? notes,  String? firebaseDocId,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyBudgetModel() when $default != null:
return $default(_that.id,_that.userId,_that.yearMonth,_that.categoryId,_that.categoryName,_that.categoryIcon,_that.budgetAmount,_that.notes,_that.firebaseDocId,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String yearMonth,  String categoryId,  String categoryName,  String categoryIcon,  int budgetAmount,  String? notes,  String? firebaseDocId,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _MonthlyBudgetModel():
return $default(_that.id,_that.userId,_that.yearMonth,_that.categoryId,_that.categoryName,_that.categoryIcon,_that.budgetAmount,_that.notes,_that.firebaseDocId,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String yearMonth,  String categoryId,  String categoryName,  String categoryIcon,  int budgetAmount,  String? notes,  String? firebaseDocId,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyBudgetModel() when $default != null:
return $default(_that.id,_that.userId,_that.yearMonth,_that.categoryId,_that.categoryName,_that.categoryIcon,_that.budgetAmount,_that.notes,_that.firebaseDocId,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyBudgetModel implements MonthlyBudgetModel {
  const _MonthlyBudgetModel({required this.id, required this.userId, required this.yearMonth, required this.categoryId, required this.categoryName, required this.categoryIcon, required this.budgetAmount, this.notes, this.firebaseDocId, this.isSynced = false, this.syncedAt, required this.localCreatedAt, this.updatedAt, this.isDeleted = false});
  factory _MonthlyBudgetModel.fromJson(Map<String, dynamic> json) => _$MonthlyBudgetModelFromJson(json);

@override final  String id;
@override final  String userId;
/// Format: 'yyyy-MM' misal '2026-06'
@override final  String yearMonth;
@override final  String categoryId;
@override final  String categoryName;
@override final  String categoryIcon;
/// Target anggaran bulan ini
@override final  int budgetAmount;
@override final  String? notes;
@override final  String? firebaseDocId;
@override@JsonKey() final  bool isSynced;
@override final  DateTime? syncedAt;
@override final  DateTime localCreatedAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of MonthlyBudgetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyBudgetModelCopyWith<_MonthlyBudgetModel> get copyWith => __$MonthlyBudgetModelCopyWithImpl<_MonthlyBudgetModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyBudgetModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyBudgetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIcon, categoryIcon) || other.categoryIcon == categoryIcon)&&(identical(other.budgetAmount, budgetAmount) || other.budgetAmount == budgetAmount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,yearMonth,categoryId,categoryName,categoryIcon,budgetAmount,notes,firebaseDocId,isSynced,syncedAt,localCreatedAt,updatedAt,isDeleted);

@override
String toString() {
  return 'MonthlyBudgetModel(id: $id, userId: $userId, yearMonth: $yearMonth, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, budgetAmount: $budgetAmount, notes: $notes, firebaseDocId: $firebaseDocId, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$MonthlyBudgetModelCopyWith<$Res> implements $MonthlyBudgetModelCopyWith<$Res> {
  factory _$MonthlyBudgetModelCopyWith(_MonthlyBudgetModel value, $Res Function(_MonthlyBudgetModel) _then) = __$MonthlyBudgetModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String yearMonth, String categoryId, String categoryName, String categoryIcon, int budgetAmount, String? notes, String? firebaseDocId, bool isSynced, DateTime? syncedAt, DateTime localCreatedAt, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class __$MonthlyBudgetModelCopyWithImpl<$Res>
    implements _$MonthlyBudgetModelCopyWith<$Res> {
  __$MonthlyBudgetModelCopyWithImpl(this._self, this._then);

  final _MonthlyBudgetModel _self;
  final $Res Function(_MonthlyBudgetModel) _then;

/// Create a copy of MonthlyBudgetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? yearMonth = null,Object? categoryId = null,Object? categoryName = null,Object? categoryIcon = null,Object? budgetAmount = null,Object? notes = freezed,Object? firebaseDocId = freezed,Object? isSynced = null,Object? syncedAt = freezed,Object? localCreatedAt = null,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_MonthlyBudgetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,categoryIcon: null == categoryIcon ? _self.categoryIcon : categoryIcon // ignore: cast_nullable_to_non_nullable
as String,budgetAmount: null == budgetAmount ? _self.budgetAmount : budgetAmount // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,firebaseDocId: freezed == firebaseDocId ? _self.firebaseDocId : firebaseDocId // ignore: cast_nullable_to_non_nullable
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
