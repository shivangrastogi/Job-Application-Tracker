// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referral_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReferralSource {

 String get id; String get name; ReferralSourceType get type; String? get url;/// For Google Forms: a "pre-filled link" with tokens like {name}, {email},
/// {phone}, {linkedin}, {resume}, {company}, {role} that we substitute
/// before opening.
 String? get formTemplate; String? get notes; DateTime get createdAt;
/// Create a copy of ReferralSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferralSourceCopyWith<ReferralSource> get copyWith => _$ReferralSourceCopyWithImpl<ReferralSource>(this as ReferralSource, _$identity);

  /// Serializes this ReferralSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReferralSource&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.formTemplate, formTemplate) || other.formTemplate == formTemplate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,url,formTemplate,notes,createdAt);

@override
String toString() {
  return 'ReferralSource(id: $id, name: $name, type: $type, url: $url, formTemplate: $formTemplate, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReferralSourceCopyWith<$Res>  {
  factory $ReferralSourceCopyWith(ReferralSource value, $Res Function(ReferralSource) _then) = _$ReferralSourceCopyWithImpl;
@useResult
$Res call({
 String id, String name, ReferralSourceType type, String? url, String? formTemplate, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$ReferralSourceCopyWithImpl<$Res>
    implements $ReferralSourceCopyWith<$Res> {
  _$ReferralSourceCopyWithImpl(this._self, this._then);

  final ReferralSource _self;
  final $Res Function(ReferralSource) _then;

/// Create a copy of ReferralSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? url = freezed,Object? formTemplate = freezed,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReferralSourceType,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,formTemplate: freezed == formTemplate ? _self.formTemplate : formTemplate // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ReferralSource].
extension ReferralSourcePatterns on ReferralSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReferralSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReferralSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReferralSource value)  $default,){
final _that = this;
switch (_that) {
case _ReferralSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReferralSource value)?  $default,){
final _that = this;
switch (_that) {
case _ReferralSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  ReferralSourceType type,  String? url,  String? formTemplate,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReferralSource() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.url,_that.formTemplate,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  ReferralSourceType type,  String? url,  String? formTemplate,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ReferralSource():
return $default(_that.id,_that.name,_that.type,_that.url,_that.formTemplate,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  ReferralSourceType type,  String? url,  String? formTemplate,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ReferralSource() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.url,_that.formTemplate,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReferralSource implements ReferralSource {
  const _ReferralSource({required this.id, required this.name, this.type = ReferralSourceType.group, this.url, this.formTemplate, this.notes, required this.createdAt});
  factory _ReferralSource.fromJson(Map<String, dynamic> json) => _$ReferralSourceFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  ReferralSourceType type;
@override final  String? url;
/// For Google Forms: a "pre-filled link" with tokens like {name}, {email},
/// {phone}, {linkedin}, {resume}, {company}, {role} that we substitute
/// before opening.
@override final  String? formTemplate;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of ReferralSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferralSourceCopyWith<_ReferralSource> get copyWith => __$ReferralSourceCopyWithImpl<_ReferralSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReferralSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReferralSource&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.formTemplate, formTemplate) || other.formTemplate == formTemplate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,url,formTemplate,notes,createdAt);

@override
String toString() {
  return 'ReferralSource(id: $id, name: $name, type: $type, url: $url, formTemplate: $formTemplate, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReferralSourceCopyWith<$Res> implements $ReferralSourceCopyWith<$Res> {
  factory _$ReferralSourceCopyWith(_ReferralSource value, $Res Function(_ReferralSource) _then) = __$ReferralSourceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, ReferralSourceType type, String? url, String? formTemplate, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$ReferralSourceCopyWithImpl<$Res>
    implements _$ReferralSourceCopyWith<$Res> {
  __$ReferralSourceCopyWithImpl(this._self, this._then);

  final _ReferralSource _self;
  final $Res Function(_ReferralSource) _then;

/// Create a copy of ReferralSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? url = freezed,Object? formTemplate = freezed,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_ReferralSource(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReferralSourceType,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,formTemplate: freezed == formTemplate ? _self.formTemplate : formTemplate // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
