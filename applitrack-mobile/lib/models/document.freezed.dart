// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppDocument {

 String get id; String get name; DocumentType get type; String? get version; String? get content; String? get filePath; List<String> get tags; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of AppDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppDocumentCopyWith<AppDocument> get copyWith => _$AppDocumentCopyWithImpl<AppDocument>(this as AppDocument, _$identity);

  /// Serializes this AppDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.version, version) || other.version == version)&&(identical(other.content, content) || other.content == content)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,version,content,filePath,const DeepCollectionEquality().hash(tags),createdAt,updatedAt);

@override
String toString() {
  return 'AppDocument(id: $id, name: $name, type: $type, version: $version, content: $content, filePath: $filePath, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AppDocumentCopyWith<$Res>  {
  factory $AppDocumentCopyWith(AppDocument value, $Res Function(AppDocument) _then) = _$AppDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String name, DocumentType type, String? version, String? content, String? filePath, List<String> tags, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$AppDocumentCopyWithImpl<$Res>
    implements $AppDocumentCopyWith<$Res> {
  _$AppDocumentCopyWithImpl(this._self, this._then);

  final AppDocument _self;
  final $Res Function(AppDocument) _then;

/// Create a copy of AppDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? version = freezed,Object? content = freezed,Object? filePath = freezed,Object? tags = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocumentType,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppDocument].
extension AppDocumentPatterns on AppDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppDocument value)  $default,){
final _that = this;
switch (_that) {
case _AppDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppDocument value)?  $default,){
final _that = this;
switch (_that) {
case _AppDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DocumentType type,  String? version,  String? content,  String? filePath,  List<String> tags,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppDocument() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.version,_that.content,_that.filePath,_that.tags,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DocumentType type,  String? version,  String? content,  String? filePath,  List<String> tags,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppDocument():
return $default(_that.id,_that.name,_that.type,_that.version,_that.content,_that.filePath,_that.tags,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DocumentType type,  String? version,  String? content,  String? filePath,  List<String> tags,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppDocument() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.version,_that.content,_that.filePath,_that.tags,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppDocument implements AppDocument {
  const _AppDocument({required this.id, required this.name, this.type = DocumentType.resume, this.version, this.content, this.filePath, final  List<String> tags = const <String>[], required this.createdAt, required this.updatedAt}): _tags = tags;
  factory _AppDocument.fromJson(Map<String, dynamic> json) => _$AppDocumentFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  DocumentType type;
@override final  String? version;
@override final  String? content;
@override final  String? filePath;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of AppDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppDocumentCopyWith<_AppDocument> get copyWith => __$AppDocumentCopyWithImpl<_AppDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.version, version) || other.version == version)&&(identical(other.content, content) || other.content == content)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,version,content,filePath,const DeepCollectionEquality().hash(_tags),createdAt,updatedAt);

@override
String toString() {
  return 'AppDocument(id: $id, name: $name, type: $type, version: $version, content: $content, filePath: $filePath, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppDocumentCopyWith<$Res> implements $AppDocumentCopyWith<$Res> {
  factory _$AppDocumentCopyWith(_AppDocument value, $Res Function(_AppDocument) _then) = __$AppDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DocumentType type, String? version, String? content, String? filePath, List<String> tags, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$AppDocumentCopyWithImpl<$Res>
    implements _$AppDocumentCopyWith<$Res> {
  __$AppDocumentCopyWithImpl(this._self, this._then);

  final _AppDocument _self;
  final $Res Function(_AppDocument) _then;

/// Create a copy of AppDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? version = freezed,Object? content = freezed,Object? filePath = freezed,Object? tags = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AppDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocumentType,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
