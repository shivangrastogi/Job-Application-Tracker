// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referral.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Referral {

 String get id; String? get sourceId; String get company; String? get role; String? get jobUrl; String? get referrerName; ReferralStatus get status; DateTime? get requestedDate; String? get notes;/// Set once converted into a tracked JobApplication.
 String? get linkedApplicationId; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Referral
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferralCopyWith<Referral> get copyWith => _$ReferralCopyWithImpl<Referral>(this as Referral, _$identity);

  /// Serializes this Referral to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Referral&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.company, company) || other.company == company)&&(identical(other.role, role) || other.role == role)&&(identical(other.jobUrl, jobUrl) || other.jobUrl == jobUrl)&&(identical(other.referrerName, referrerName) || other.referrerName == referrerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedDate, requestedDate) || other.requestedDate == requestedDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.linkedApplicationId, linkedApplicationId) || other.linkedApplicationId == linkedApplicationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceId,company,role,jobUrl,referrerName,status,requestedDate,notes,linkedApplicationId,createdAt,updatedAt);

@override
String toString() {
  return 'Referral(id: $id, sourceId: $sourceId, company: $company, role: $role, jobUrl: $jobUrl, referrerName: $referrerName, status: $status, requestedDate: $requestedDate, notes: $notes, linkedApplicationId: $linkedApplicationId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReferralCopyWith<$Res>  {
  factory $ReferralCopyWith(Referral value, $Res Function(Referral) _then) = _$ReferralCopyWithImpl;
@useResult
$Res call({
 String id, String? sourceId, String company, String? role, String? jobUrl, String? referrerName, ReferralStatus status, DateTime? requestedDate, String? notes, String? linkedApplicationId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ReferralCopyWithImpl<$Res>
    implements $ReferralCopyWith<$Res> {
  _$ReferralCopyWithImpl(this._self, this._then);

  final Referral _self;
  final $Res Function(Referral) _then;

/// Create a copy of Referral
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sourceId = freezed,Object? company = null,Object? role = freezed,Object? jobUrl = freezed,Object? referrerName = freezed,Object? status = null,Object? requestedDate = freezed,Object? notes = freezed,Object? linkedApplicationId = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,jobUrl: freezed == jobUrl ? _self.jobUrl : jobUrl // ignore: cast_nullable_to_non_nullable
as String?,referrerName: freezed == referrerName ? _self.referrerName : referrerName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReferralStatus,requestedDate: freezed == requestedDate ? _self.requestedDate : requestedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,linkedApplicationId: freezed == linkedApplicationId ? _self.linkedApplicationId : linkedApplicationId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Referral].
extension ReferralPatterns on Referral {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Referral value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Referral() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Referral value)  $default,){
final _that = this;
switch (_that) {
case _Referral():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Referral value)?  $default,){
final _that = this;
switch (_that) {
case _Referral() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? sourceId,  String company,  String? role,  String? jobUrl,  String? referrerName,  ReferralStatus status,  DateTime? requestedDate,  String? notes,  String? linkedApplicationId,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Referral() when $default != null:
return $default(_that.id,_that.sourceId,_that.company,_that.role,_that.jobUrl,_that.referrerName,_that.status,_that.requestedDate,_that.notes,_that.linkedApplicationId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? sourceId,  String company,  String? role,  String? jobUrl,  String? referrerName,  ReferralStatus status,  DateTime? requestedDate,  String? notes,  String? linkedApplicationId,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Referral():
return $default(_that.id,_that.sourceId,_that.company,_that.role,_that.jobUrl,_that.referrerName,_that.status,_that.requestedDate,_that.notes,_that.linkedApplicationId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? sourceId,  String company,  String? role,  String? jobUrl,  String? referrerName,  ReferralStatus status,  DateTime? requestedDate,  String? notes,  String? linkedApplicationId,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Referral() when $default != null:
return $default(_that.id,_that.sourceId,_that.company,_that.role,_that.jobUrl,_that.referrerName,_that.status,_that.requestedDate,_that.notes,_that.linkedApplicationId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Referral implements Referral {
  const _Referral({required this.id, this.sourceId, required this.company, this.role, this.jobUrl, this.referrerName, this.status = ReferralStatus.requested, this.requestedDate, this.notes, this.linkedApplicationId, required this.createdAt, required this.updatedAt});
  factory _Referral.fromJson(Map<String, dynamic> json) => _$ReferralFromJson(json);

@override final  String id;
@override final  String? sourceId;
@override final  String company;
@override final  String? role;
@override final  String? jobUrl;
@override final  String? referrerName;
@override@JsonKey() final  ReferralStatus status;
@override final  DateTime? requestedDate;
@override final  String? notes;
/// Set once converted into a tracked JobApplication.
@override final  String? linkedApplicationId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Referral
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferralCopyWith<_Referral> get copyWith => __$ReferralCopyWithImpl<_Referral>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReferralToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Referral&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.company, company) || other.company == company)&&(identical(other.role, role) || other.role == role)&&(identical(other.jobUrl, jobUrl) || other.jobUrl == jobUrl)&&(identical(other.referrerName, referrerName) || other.referrerName == referrerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedDate, requestedDate) || other.requestedDate == requestedDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.linkedApplicationId, linkedApplicationId) || other.linkedApplicationId == linkedApplicationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceId,company,role,jobUrl,referrerName,status,requestedDate,notes,linkedApplicationId,createdAt,updatedAt);

@override
String toString() {
  return 'Referral(id: $id, sourceId: $sourceId, company: $company, role: $role, jobUrl: $jobUrl, referrerName: $referrerName, status: $status, requestedDate: $requestedDate, notes: $notes, linkedApplicationId: $linkedApplicationId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReferralCopyWith<$Res> implements $ReferralCopyWith<$Res> {
  factory _$ReferralCopyWith(_Referral value, $Res Function(_Referral) _then) = __$ReferralCopyWithImpl;
@override @useResult
$Res call({
 String id, String? sourceId, String company, String? role, String? jobUrl, String? referrerName, ReferralStatus status, DateTime? requestedDate, String? notes, String? linkedApplicationId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ReferralCopyWithImpl<$Res>
    implements _$ReferralCopyWith<$Res> {
  __$ReferralCopyWithImpl(this._self, this._then);

  final _Referral _self;
  final $Res Function(_Referral) _then;

/// Create a copy of Referral
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sourceId = freezed,Object? company = null,Object? role = freezed,Object? jobUrl = freezed,Object? referrerName = freezed,Object? status = null,Object? requestedDate = freezed,Object? notes = freezed,Object? linkedApplicationId = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Referral(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,jobUrl: freezed == jobUrl ? _self.jobUrl : jobUrl // ignore: cast_nullable_to_non_nullable
as String?,referrerName: freezed == referrerName ? _self.referrerName : referrerName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReferralStatus,requestedDate: freezed == requestedDate ? _self.requestedDate : requestedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,linkedApplicationId: freezed == linkedApplicationId ? _self.linkedApplicationId : linkedApplicationId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
