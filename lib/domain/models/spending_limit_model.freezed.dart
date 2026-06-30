// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spending_limit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpendingLimitModel {

 String get id; String get userId;/// null = global (semua kategori), isi = per kategori
 String? get categoryId; String? get categoryName; String? get categoryIcon;/// Nominal limit harian dalam rupiah
 int get dailyLimit;/// Threshold notifikasi "hampir habis" (0.0 - 1.0), default 0.8 = 80%
 double get warningThreshold; bool get isActive; String? get firebaseDocId; bool get isSynced; DateTime? get syncedAt; DateTime get localCreatedAt; DateTime? get updatedAt; bool get isDeleted;
/// Create a copy of SpendingLimitModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpendingLimitModelCopyWith<SpendingLimitModel> get copyWith => _$SpendingLimitModelCopyWithImpl<SpendingLimitModel>(this as SpendingLimitModel, _$identity);

  /// Serializes this SpendingLimitModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpendingLimitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIcon, categoryIcon) || other.categoryIcon == categoryIcon)&&(identical(other.dailyLimit, dailyLimit) || other.dailyLimit == dailyLimit)&&(identical(other.warningThreshold, warningThreshold) || other.warningThreshold == warningThreshold)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,categoryId,categoryName,categoryIcon,dailyLimit,warningThreshold,isActive,firebaseDocId,isSynced,syncedAt,localCreatedAt,updatedAt,isDeleted);

@override
String toString() {
  return 'SpendingLimitModel(id: $id, userId: $userId, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, dailyLimit: $dailyLimit, warningThreshold: $warningThreshold, isActive: $isActive, firebaseDocId: $firebaseDocId, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $SpendingLimitModelCopyWith<$Res>  {
  factory $SpendingLimitModelCopyWith(SpendingLimitModel value, $Res Function(SpendingLimitModel) _then) = _$SpendingLimitModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? categoryId, String? categoryName, String? categoryIcon, int dailyLimit, double warningThreshold, bool isActive, String? firebaseDocId, bool isSynced, DateTime? syncedAt, DateTime localCreatedAt, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class _$SpendingLimitModelCopyWithImpl<$Res>
    implements $SpendingLimitModelCopyWith<$Res> {
  _$SpendingLimitModelCopyWithImpl(this._self, this._then);

  final SpendingLimitModel _self;
  final $Res Function(SpendingLimitModel) _then;

/// Create a copy of SpendingLimitModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? categoryId = freezed,Object? categoryName = freezed,Object? categoryIcon = freezed,Object? dailyLimit = null,Object? warningThreshold = null,Object? isActive = null,Object? firebaseDocId = freezed,Object? isSynced = null,Object? syncedAt = freezed,Object? localCreatedAt = null,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,categoryIcon: freezed == categoryIcon ? _self.categoryIcon : categoryIcon // ignore: cast_nullable_to_non_nullable
as String?,dailyLimit: null == dailyLimit ? _self.dailyLimit : dailyLimit // ignore: cast_nullable_to_non_nullable
as int,warningThreshold: null == warningThreshold ? _self.warningThreshold : warningThreshold // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [SpendingLimitModel].
extension SpendingLimitModelPatterns on SpendingLimitModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpendingLimitModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpendingLimitModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpendingLimitModel value)  $default,){
final _that = this;
switch (_that) {
case _SpendingLimitModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpendingLimitModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpendingLimitModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? categoryId,  String? categoryName,  String? categoryIcon,  int dailyLimit,  double warningThreshold,  bool isActive,  String? firebaseDocId,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpendingLimitModel() when $default != null:
return $default(_that.id,_that.userId,_that.categoryId,_that.categoryName,_that.categoryIcon,_that.dailyLimit,_that.warningThreshold,_that.isActive,_that.firebaseDocId,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? categoryId,  String? categoryName,  String? categoryIcon,  int dailyLimit,  double warningThreshold,  bool isActive,  String? firebaseDocId,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _SpendingLimitModel():
return $default(_that.id,_that.userId,_that.categoryId,_that.categoryName,_that.categoryIcon,_that.dailyLimit,_that.warningThreshold,_that.isActive,_that.firebaseDocId,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? categoryId,  String? categoryName,  String? categoryIcon,  int dailyLimit,  double warningThreshold,  bool isActive,  String? firebaseDocId,  bool isSynced,  DateTime? syncedAt,  DateTime localCreatedAt,  DateTime? updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _SpendingLimitModel() when $default != null:
return $default(_that.id,_that.userId,_that.categoryId,_that.categoryName,_that.categoryIcon,_that.dailyLimit,_that.warningThreshold,_that.isActive,_that.firebaseDocId,_that.isSynced,_that.syncedAt,_that.localCreatedAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpendingLimitModel implements SpendingLimitModel {
  const _SpendingLimitModel({required this.id, required this.userId, this.categoryId, this.categoryName, this.categoryIcon, required this.dailyLimit, this.warningThreshold = 0.8, this.isActive = true, this.firebaseDocId, this.isSynced = false, this.syncedAt, required this.localCreatedAt, this.updatedAt, this.isDeleted = false});
  factory _SpendingLimitModel.fromJson(Map<String, dynamic> json) => _$SpendingLimitModelFromJson(json);

@override final  String id;
@override final  String userId;
/// null = global (semua kategori), isi = per kategori
@override final  String? categoryId;
@override final  String? categoryName;
@override final  String? categoryIcon;
/// Nominal limit harian dalam rupiah
@override final  int dailyLimit;
/// Threshold notifikasi "hampir habis" (0.0 - 1.0), default 0.8 = 80%
@override@JsonKey() final  double warningThreshold;
@override@JsonKey() final  bool isActive;
@override final  String? firebaseDocId;
@override@JsonKey() final  bool isSynced;
@override final  DateTime? syncedAt;
@override final  DateTime localCreatedAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of SpendingLimitModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpendingLimitModelCopyWith<_SpendingLimitModel> get copyWith => __$SpendingLimitModelCopyWithImpl<_SpendingLimitModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpendingLimitModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpendingLimitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIcon, categoryIcon) || other.categoryIcon == categoryIcon)&&(identical(other.dailyLimit, dailyLimit) || other.dailyLimit == dailyLimit)&&(identical(other.warningThreshold, warningThreshold) || other.warningThreshold == warningThreshold)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.firebaseDocId, firebaseDocId) || other.firebaseDocId == firebaseDocId)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.localCreatedAt, localCreatedAt) || other.localCreatedAt == localCreatedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,categoryId,categoryName,categoryIcon,dailyLimit,warningThreshold,isActive,firebaseDocId,isSynced,syncedAt,localCreatedAt,updatedAt,isDeleted);

@override
String toString() {
  return 'SpendingLimitModel(id: $id, userId: $userId, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, dailyLimit: $dailyLimit, warningThreshold: $warningThreshold, isActive: $isActive, firebaseDocId: $firebaseDocId, isSynced: $isSynced, syncedAt: $syncedAt, localCreatedAt: $localCreatedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$SpendingLimitModelCopyWith<$Res> implements $SpendingLimitModelCopyWith<$Res> {
  factory _$SpendingLimitModelCopyWith(_SpendingLimitModel value, $Res Function(_SpendingLimitModel) _then) = __$SpendingLimitModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? categoryId, String? categoryName, String? categoryIcon, int dailyLimit, double warningThreshold, bool isActive, String? firebaseDocId, bool isSynced, DateTime? syncedAt, DateTime localCreatedAt, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class __$SpendingLimitModelCopyWithImpl<$Res>
    implements _$SpendingLimitModelCopyWith<$Res> {
  __$SpendingLimitModelCopyWithImpl(this._self, this._then);

  final _SpendingLimitModel _self;
  final $Res Function(_SpendingLimitModel) _then;

/// Create a copy of SpendingLimitModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? categoryId = freezed,Object? categoryName = freezed,Object? categoryIcon = freezed,Object? dailyLimit = null,Object? warningThreshold = null,Object? isActive = null,Object? firebaseDocId = freezed,Object? isSynced = null,Object? syncedAt = freezed,Object? localCreatedAt = null,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_SpendingLimitModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,categoryIcon: freezed == categoryIcon ? _self.categoryIcon : categoryIcon // ignore: cast_nullable_to_non_nullable
as String?,dailyLimit: null == dailyLimit ? _self.dailyLimit : dailyLimit // ignore: cast_nullable_to_non_nullable
as int,warningThreshold: null == warningThreshold ? _self.warningThreshold : warningThreshold // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
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

// dart format on
