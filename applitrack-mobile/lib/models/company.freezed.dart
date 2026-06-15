// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Company {

 String get id; String get name; AtsProvider get provider; String? get slug; String? get careerUrl; String? get logoUrl; String? get location; CompanyCategory get category; List<String> get tags; String? get notes;/// Provider-specific parameters: Workday {tenant, dc, site}, Amazon
/// {loc_query, country, query, category}, etc.
 Map<String, String> get config; DateTime? get lastFetchedAt; int get lastJobCount; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyCopyWith<Company> get copyWith => _$CompanyCopyWithImpl<Company>(this as Company, _$identity);

  /// Serializes this Company to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Company&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.careerUrl, careerUrl) || other.careerUrl == careerUrl)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.location, location) || other.location == location)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.config, config)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.lastJobCount, lastJobCount) || other.lastJobCount == lastJobCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,provider,slug,careerUrl,logoUrl,location,category,const DeepCollectionEquality().hash(tags),notes,const DeepCollectionEquality().hash(config),lastFetchedAt,lastJobCount,createdAt,updatedAt);

@override
String toString() {
  return 'Company(id: $id, name: $name, provider: $provider, slug: $slug, careerUrl: $careerUrl, logoUrl: $logoUrl, location: $location, category: $category, tags: $tags, notes: $notes, config: $config, lastFetchedAt: $lastFetchedAt, lastJobCount: $lastJobCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CompanyCopyWith<$Res>  {
  factory $CompanyCopyWith(Company value, $Res Function(Company) _then) = _$CompanyCopyWithImpl;
@useResult
$Res call({
 String id, String name, AtsProvider provider, String? slug, String? careerUrl, String? logoUrl, String? location, CompanyCategory category, List<String> tags, String? notes, Map<String, String> config, DateTime? lastFetchedAt, int lastJobCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$CompanyCopyWithImpl<$Res>
    implements $CompanyCopyWith<$Res> {
  _$CompanyCopyWithImpl(this._self, this._then);

  final Company _self;
  final $Res Function(Company) _then;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? provider = null,Object? slug = freezed,Object? careerUrl = freezed,Object? logoUrl = freezed,Object? location = freezed,Object? category = null,Object? tags = null,Object? notes = freezed,Object? config = null,Object? lastFetchedAt = freezed,Object? lastJobCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as AtsProvider,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,careerUrl: freezed == careerUrl ? _self.careerUrl : careerUrl // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CompanyCategory,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, String>,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastJobCount: null == lastJobCount ? _self.lastJobCount : lastJobCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Company].
extension CompanyPatterns on Company {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Company value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Company() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Company value)  $default,){
final _that = this;
switch (_that) {
case _Company():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Company value)?  $default,){
final _that = this;
switch (_that) {
case _Company() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  AtsProvider provider,  String? slug,  String? careerUrl,  String? logoUrl,  String? location,  CompanyCategory category,  List<String> tags,  String? notes,  Map<String, String> config,  DateTime? lastFetchedAt,  int lastJobCount,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that.id,_that.name,_that.provider,_that.slug,_that.careerUrl,_that.logoUrl,_that.location,_that.category,_that.tags,_that.notes,_that.config,_that.lastFetchedAt,_that.lastJobCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  AtsProvider provider,  String? slug,  String? careerUrl,  String? logoUrl,  String? location,  CompanyCategory category,  List<String> tags,  String? notes,  Map<String, String> config,  DateTime? lastFetchedAt,  int lastJobCount,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Company():
return $default(_that.id,_that.name,_that.provider,_that.slug,_that.careerUrl,_that.logoUrl,_that.location,_that.category,_that.tags,_that.notes,_that.config,_that.lastFetchedAt,_that.lastJobCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  AtsProvider provider,  String? slug,  String? careerUrl,  String? logoUrl,  String? location,  CompanyCategory category,  List<String> tags,  String? notes,  Map<String, String> config,  DateTime? lastFetchedAt,  int lastJobCount,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that.id,_that.name,_that.provider,_that.slug,_that.careerUrl,_that.logoUrl,_that.location,_that.category,_that.tags,_that.notes,_that.config,_that.lastFetchedAt,_that.lastJobCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Company implements Company {
  const _Company({required this.id, required this.name, this.provider = AtsProvider.custom, this.slug, this.careerUrl, this.logoUrl, this.location, this.category = CompanyCategory.other, final  List<String> tags = const <String>[], this.notes, final  Map<String, String> config = const <String, String>{}, this.lastFetchedAt, this.lastJobCount = 0, required this.createdAt, required this.updatedAt}): _tags = tags,_config = config;
  factory _Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  AtsProvider provider;
@override final  String? slug;
@override final  String? careerUrl;
@override final  String? logoUrl;
@override final  String? location;
@override@JsonKey() final  CompanyCategory category;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? notes;
/// Provider-specific parameters: Workday {tenant, dc, site}, Amazon
/// {loc_query, country, query, category}, etc.
 final  Map<String, String> _config;
/// Provider-specific parameters: Workday {tenant, dc, site}, Amazon
/// {loc_query, country, query, category}, etc.
@override@JsonKey() Map<String, String> get config {
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_config);
}

@override final  DateTime? lastFetchedAt;
@override@JsonKey() final  int lastJobCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyCopyWith<_Company> get copyWith => __$CompanyCopyWithImpl<_Company>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Company&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.careerUrl, careerUrl) || other.careerUrl == careerUrl)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.location, location) || other.location == location)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._config, _config)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.lastJobCount, lastJobCount) || other.lastJobCount == lastJobCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,provider,slug,careerUrl,logoUrl,location,category,const DeepCollectionEquality().hash(_tags),notes,const DeepCollectionEquality().hash(_config),lastFetchedAt,lastJobCount,createdAt,updatedAt);

@override
String toString() {
  return 'Company(id: $id, name: $name, provider: $provider, slug: $slug, careerUrl: $careerUrl, logoUrl: $logoUrl, location: $location, category: $category, tags: $tags, notes: $notes, config: $config, lastFetchedAt: $lastFetchedAt, lastJobCount: $lastJobCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CompanyCopyWith<$Res> implements $CompanyCopyWith<$Res> {
  factory _$CompanyCopyWith(_Company value, $Res Function(_Company) _then) = __$CompanyCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, AtsProvider provider, String? slug, String? careerUrl, String? logoUrl, String? location, CompanyCategory category, List<String> tags, String? notes, Map<String, String> config, DateTime? lastFetchedAt, int lastJobCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$CompanyCopyWithImpl<$Res>
    implements _$CompanyCopyWith<$Res> {
  __$CompanyCopyWithImpl(this._self, this._then);

  final _Company _self;
  final $Res Function(_Company) _then;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? provider = null,Object? slug = freezed,Object? careerUrl = freezed,Object? logoUrl = freezed,Object? location = freezed,Object? category = null,Object? tags = null,Object? notes = freezed,Object? config = null,Object? lastFetchedAt = freezed,Object? lastJobCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Company(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as AtsProvider,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,careerUrl: freezed == careerUrl ? _self.careerUrl : careerUrl // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CompanyCategory,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,config: null == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, String>,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastJobCount: null == lastJobCount ? _self.lastJobCount : lastJobCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
