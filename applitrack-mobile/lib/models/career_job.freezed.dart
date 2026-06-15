// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'career_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CareerJob {

 String get id; String get companyId; String get companyName; String get title; String? get location; String? get department; String? get employmentType; CareerWorkType get workType; String? get url; DateTime? get postedAt;
/// Create a copy of CareerJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CareerJobCopyWith<CareerJob> get copyWith => _$CareerJobCopyWithImpl<CareerJob>(this as CareerJob, _$identity);

  /// Serializes this CareerJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CareerJob&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.title, title) || other.title == title)&&(identical(other.location, location) || other.location == location)&&(identical(other.department, department) || other.department == department)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType)&&(identical(other.workType, workType) || other.workType == workType)&&(identical(other.url, url) || other.url == url)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,companyName,title,location,department,employmentType,workType,url,postedAt);

@override
String toString() {
  return 'CareerJob(id: $id, companyId: $companyId, companyName: $companyName, title: $title, location: $location, department: $department, employmentType: $employmentType, workType: $workType, url: $url, postedAt: $postedAt)';
}


}

/// @nodoc
abstract mixin class $CareerJobCopyWith<$Res>  {
  factory $CareerJobCopyWith(CareerJob value, $Res Function(CareerJob) _then) = _$CareerJobCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String companyName, String title, String? location, String? department, String? employmentType, CareerWorkType workType, String? url, DateTime? postedAt
});




}
/// @nodoc
class _$CareerJobCopyWithImpl<$Res>
    implements $CareerJobCopyWith<$Res> {
  _$CareerJobCopyWithImpl(this._self, this._then);

  final CareerJob _self;
  final $Res Function(CareerJob) _then;

/// Create a copy of CareerJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? companyName = null,Object? title = null,Object? location = freezed,Object? department = freezed,Object? employmentType = freezed,Object? workType = null,Object? url = freezed,Object? postedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,employmentType: freezed == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as String?,workType: null == workType ? _self.workType : workType // ignore: cast_nullable_to_non_nullable
as CareerWorkType,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CareerJob].
extension CareerJobPatterns on CareerJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CareerJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CareerJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CareerJob value)  $default,){
final _that = this;
switch (_that) {
case _CareerJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CareerJob value)?  $default,){
final _that = this;
switch (_that) {
case _CareerJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String companyName,  String title,  String? location,  String? department,  String? employmentType,  CareerWorkType workType,  String? url,  DateTime? postedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CareerJob() when $default != null:
return $default(_that.id,_that.companyId,_that.companyName,_that.title,_that.location,_that.department,_that.employmentType,_that.workType,_that.url,_that.postedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String companyName,  String title,  String? location,  String? department,  String? employmentType,  CareerWorkType workType,  String? url,  DateTime? postedAt)  $default,) {final _that = this;
switch (_that) {
case _CareerJob():
return $default(_that.id,_that.companyId,_that.companyName,_that.title,_that.location,_that.department,_that.employmentType,_that.workType,_that.url,_that.postedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String companyName,  String title,  String? location,  String? department,  String? employmentType,  CareerWorkType workType,  String? url,  DateTime? postedAt)?  $default,) {final _that = this;
switch (_that) {
case _CareerJob() when $default != null:
return $default(_that.id,_that.companyId,_that.companyName,_that.title,_that.location,_that.department,_that.employmentType,_that.workType,_that.url,_that.postedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CareerJob implements CareerJob {
  const _CareerJob({required this.id, required this.companyId, required this.companyName, required this.title, this.location, this.department, this.employmentType, this.workType = CareerWorkType.unknown, this.url, this.postedAt});
  factory _CareerJob.fromJson(Map<String, dynamic> json) => _$CareerJobFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String companyName;
@override final  String title;
@override final  String? location;
@override final  String? department;
@override final  String? employmentType;
@override@JsonKey() final  CareerWorkType workType;
@override final  String? url;
@override final  DateTime? postedAt;

/// Create a copy of CareerJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CareerJobCopyWith<_CareerJob> get copyWith => __$CareerJobCopyWithImpl<_CareerJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CareerJobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CareerJob&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.title, title) || other.title == title)&&(identical(other.location, location) || other.location == location)&&(identical(other.department, department) || other.department == department)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType)&&(identical(other.workType, workType) || other.workType == workType)&&(identical(other.url, url) || other.url == url)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,companyName,title,location,department,employmentType,workType,url,postedAt);

@override
String toString() {
  return 'CareerJob(id: $id, companyId: $companyId, companyName: $companyName, title: $title, location: $location, department: $department, employmentType: $employmentType, workType: $workType, url: $url, postedAt: $postedAt)';
}


}

/// @nodoc
abstract mixin class _$CareerJobCopyWith<$Res> implements $CareerJobCopyWith<$Res> {
  factory _$CareerJobCopyWith(_CareerJob value, $Res Function(_CareerJob) _then) = __$CareerJobCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String companyName, String title, String? location, String? department, String? employmentType, CareerWorkType workType, String? url, DateTime? postedAt
});




}
/// @nodoc
class __$CareerJobCopyWithImpl<$Res>
    implements _$CareerJobCopyWith<$Res> {
  __$CareerJobCopyWithImpl(this._self, this._then);

  final _CareerJob _self;
  final $Res Function(_CareerJob) _then;

/// Create a copy of CareerJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? companyName = null,Object? title = null,Object? location = freezed,Object? department = freezed,Object? employmentType = freezed,Object? workType = null,Object? url = freezed,Object? postedAt = freezed,}) {
  return _then(_CareerJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,employmentType: freezed == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as String?,workType: null == workType ? _self.workType : workType // ignore: cast_nullable_to_non_nullable
as CareerWorkType,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
