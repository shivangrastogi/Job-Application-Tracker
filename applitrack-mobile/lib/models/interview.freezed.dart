// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Interview {

 String get id; String get applicationId; InterviewType get type; DateTime get scheduledAt; int get durationMinutes; String? get platform; String? get interviewerName; String? get notes; String? get feedback; InterviewOutcome get outcome; DateTime get createdAt;
/// Create a copy of Interview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterviewCopyWith<Interview> get copyWith => _$InterviewCopyWithImpl<Interview>(this as Interview, _$identity);

  /// Serializes this Interview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Interview&&(identical(other.id, id) || other.id == id)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.interviewerName, interviewerName) || other.interviewerName == interviewerName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.feedback, feedback) || other.feedback == feedback)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,applicationId,type,scheduledAt,durationMinutes,platform,interviewerName,notes,feedback,outcome,createdAt);

@override
String toString() {
  return 'Interview(id: $id, applicationId: $applicationId, type: $type, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, platform: $platform, interviewerName: $interviewerName, notes: $notes, feedback: $feedback, outcome: $outcome, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InterviewCopyWith<$Res>  {
  factory $InterviewCopyWith(Interview value, $Res Function(Interview) _then) = _$InterviewCopyWithImpl;
@useResult
$Res call({
 String id, String applicationId, InterviewType type, DateTime scheduledAt, int durationMinutes, String? platform, String? interviewerName, String? notes, String? feedback, InterviewOutcome outcome, DateTime createdAt
});




}
/// @nodoc
class _$InterviewCopyWithImpl<$Res>
    implements $InterviewCopyWith<$Res> {
  _$InterviewCopyWithImpl(this._self, this._then);

  final Interview _self;
  final $Res Function(Interview) _then;

/// Create a copy of Interview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? applicationId = null,Object? type = null,Object? scheduledAt = null,Object? durationMinutes = null,Object? platform = freezed,Object? interviewerName = freezed,Object? notes = freezed,Object? feedback = freezed,Object? outcome = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InterviewType,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,interviewerName: freezed == interviewerName ? _self.interviewerName : interviewerName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as InterviewOutcome,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Interview].
extension InterviewPatterns on Interview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Interview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Interview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Interview value)  $default,){
final _that = this;
switch (_that) {
case _Interview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Interview value)?  $default,){
final _that = this;
switch (_that) {
case _Interview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String applicationId,  InterviewType type,  DateTime scheduledAt,  int durationMinutes,  String? platform,  String? interviewerName,  String? notes,  String? feedback,  InterviewOutcome outcome,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Interview() when $default != null:
return $default(_that.id,_that.applicationId,_that.type,_that.scheduledAt,_that.durationMinutes,_that.platform,_that.interviewerName,_that.notes,_that.feedback,_that.outcome,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String applicationId,  InterviewType type,  DateTime scheduledAt,  int durationMinutes,  String? platform,  String? interviewerName,  String? notes,  String? feedback,  InterviewOutcome outcome,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Interview():
return $default(_that.id,_that.applicationId,_that.type,_that.scheduledAt,_that.durationMinutes,_that.platform,_that.interviewerName,_that.notes,_that.feedback,_that.outcome,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String applicationId,  InterviewType type,  DateTime scheduledAt,  int durationMinutes,  String? platform,  String? interviewerName,  String? notes,  String? feedback,  InterviewOutcome outcome,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Interview() when $default != null:
return $default(_that.id,_that.applicationId,_that.type,_that.scheduledAt,_that.durationMinutes,_that.platform,_that.interviewerName,_that.notes,_that.feedback,_that.outcome,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Interview implements Interview {
  const _Interview({required this.id, required this.applicationId, this.type = InterviewType.phone, required this.scheduledAt, this.durationMinutes = 60, this.platform, this.interviewerName, this.notes, this.feedback, this.outcome = InterviewOutcome.pending, required this.createdAt});
  factory _Interview.fromJson(Map<String, dynamic> json) => _$InterviewFromJson(json);

@override final  String id;
@override final  String applicationId;
@override@JsonKey() final  InterviewType type;
@override final  DateTime scheduledAt;
@override@JsonKey() final  int durationMinutes;
@override final  String? platform;
@override final  String? interviewerName;
@override final  String? notes;
@override final  String? feedback;
@override@JsonKey() final  InterviewOutcome outcome;
@override final  DateTime createdAt;

/// Create a copy of Interview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterviewCopyWith<_Interview> get copyWith => __$InterviewCopyWithImpl<_Interview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Interview&&(identical(other.id, id) || other.id == id)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.interviewerName, interviewerName) || other.interviewerName == interviewerName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.feedback, feedback) || other.feedback == feedback)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,applicationId,type,scheduledAt,durationMinutes,platform,interviewerName,notes,feedback,outcome,createdAt);

@override
String toString() {
  return 'Interview(id: $id, applicationId: $applicationId, type: $type, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, platform: $platform, interviewerName: $interviewerName, notes: $notes, feedback: $feedback, outcome: $outcome, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InterviewCopyWith<$Res> implements $InterviewCopyWith<$Res> {
  factory _$InterviewCopyWith(_Interview value, $Res Function(_Interview) _then) = __$InterviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String applicationId, InterviewType type, DateTime scheduledAt, int durationMinutes, String? platform, String? interviewerName, String? notes, String? feedback, InterviewOutcome outcome, DateTime createdAt
});




}
/// @nodoc
class __$InterviewCopyWithImpl<$Res>
    implements _$InterviewCopyWith<$Res> {
  __$InterviewCopyWithImpl(this._self, this._then);

  final _Interview _self;
  final $Res Function(_Interview) _then;

/// Create a copy of Interview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? applicationId = null,Object? type = null,Object? scheduledAt = null,Object? durationMinutes = null,Object? platform = freezed,Object? interviewerName = freezed,Object? notes = freezed,Object? feedback = freezed,Object? outcome = null,Object? createdAt = null,}) {
  return _then(_Interview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InterviewType,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,interviewerName: freezed == interviewerName ? _self.interviewerName : interviewerName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as InterviewOutcome,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
