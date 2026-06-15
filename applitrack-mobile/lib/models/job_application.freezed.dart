// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JobApplication {

 String get id; String get company; String get role; ApplicationStatus get status; DateTime? get appliedDate; String? get jobUrl; String? get location; WorkType get workType; double? get salaryMin; double? get salaryMax; String get salaryCurrency; JobSource get source; String? get sourceName; int get priority; List<String> get tags; String? get notes; String? get resumeVersionId; bool get coverLetterUsed; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of JobApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobApplicationCopyWith<JobApplication> get copyWith => _$JobApplicationCopyWithImpl<JobApplication>(this as JobApplication, _$identity);

  /// Serializes this JobApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.company, company) || other.company == company)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.appliedDate, appliedDate) || other.appliedDate == appliedDate)&&(identical(other.jobUrl, jobUrl) || other.jobUrl == jobUrl)&&(identical(other.location, location) || other.location == location)&&(identical(other.workType, workType) || other.workType == workType)&&(identical(other.salaryMin, salaryMin) || other.salaryMin == salaryMin)&&(identical(other.salaryMax, salaryMax) || other.salaryMax == salaryMax)&&(identical(other.salaryCurrency, salaryCurrency) || other.salaryCurrency == salaryCurrency)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.priority, priority) || other.priority == priority)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.resumeVersionId, resumeVersionId) || other.resumeVersionId == resumeVersionId)&&(identical(other.coverLetterUsed, coverLetterUsed) || other.coverLetterUsed == coverLetterUsed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,company,role,status,appliedDate,jobUrl,location,workType,salaryMin,salaryMax,salaryCurrency,source,sourceName,priority,const DeepCollectionEquality().hash(tags),notes,resumeVersionId,coverLetterUsed,createdAt,updatedAt]);

@override
String toString() {
  return 'JobApplication(id: $id, company: $company, role: $role, status: $status, appliedDate: $appliedDate, jobUrl: $jobUrl, location: $location, workType: $workType, salaryMin: $salaryMin, salaryMax: $salaryMax, salaryCurrency: $salaryCurrency, source: $source, sourceName: $sourceName, priority: $priority, tags: $tags, notes: $notes, resumeVersionId: $resumeVersionId, coverLetterUsed: $coverLetterUsed, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $JobApplicationCopyWith<$Res>  {
  factory $JobApplicationCopyWith(JobApplication value, $Res Function(JobApplication) _then) = _$JobApplicationCopyWithImpl;
@useResult
$Res call({
 String id, String company, String role, ApplicationStatus status, DateTime? appliedDate, String? jobUrl, String? location, WorkType workType, double? salaryMin, double? salaryMax, String salaryCurrency, JobSource source, String? sourceName, int priority, List<String> tags, String? notes, String? resumeVersionId, bool coverLetterUsed, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$JobApplicationCopyWithImpl<$Res>
    implements $JobApplicationCopyWith<$Res> {
  _$JobApplicationCopyWithImpl(this._self, this._then);

  final JobApplication _self;
  final $Res Function(JobApplication) _then;

/// Create a copy of JobApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? company = null,Object? role = null,Object? status = null,Object? appliedDate = freezed,Object? jobUrl = freezed,Object? location = freezed,Object? workType = null,Object? salaryMin = freezed,Object? salaryMax = freezed,Object? salaryCurrency = null,Object? source = null,Object? sourceName = freezed,Object? priority = null,Object? tags = null,Object? notes = freezed,Object? resumeVersionId = freezed,Object? coverLetterUsed = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,appliedDate: freezed == appliedDate ? _self.appliedDate : appliedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,jobUrl: freezed == jobUrl ? _self.jobUrl : jobUrl // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,workType: null == workType ? _self.workType : workType // ignore: cast_nullable_to_non_nullable
as WorkType,salaryMin: freezed == salaryMin ? _self.salaryMin : salaryMin // ignore: cast_nullable_to_non_nullable
as double?,salaryMax: freezed == salaryMax ? _self.salaryMax : salaryMax // ignore: cast_nullable_to_non_nullable
as double?,salaryCurrency: null == salaryCurrency ? _self.salaryCurrency : salaryCurrency // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as JobSource,sourceName: freezed == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,resumeVersionId: freezed == resumeVersionId ? _self.resumeVersionId : resumeVersionId // ignore: cast_nullable_to_non_nullable
as String?,coverLetterUsed: null == coverLetterUsed ? _self.coverLetterUsed : coverLetterUsed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [JobApplication].
extension JobApplicationPatterns on JobApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobApplication value)  $default,){
final _that = this;
switch (_that) {
case _JobApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobApplication value)?  $default,){
final _that = this;
switch (_that) {
case _JobApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String company,  String role,  ApplicationStatus status,  DateTime? appliedDate,  String? jobUrl,  String? location,  WorkType workType,  double? salaryMin,  double? salaryMax,  String salaryCurrency,  JobSource source,  String? sourceName,  int priority,  List<String> tags,  String? notes,  String? resumeVersionId,  bool coverLetterUsed,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobApplication() when $default != null:
return $default(_that.id,_that.company,_that.role,_that.status,_that.appliedDate,_that.jobUrl,_that.location,_that.workType,_that.salaryMin,_that.salaryMax,_that.salaryCurrency,_that.source,_that.sourceName,_that.priority,_that.tags,_that.notes,_that.resumeVersionId,_that.coverLetterUsed,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String company,  String role,  ApplicationStatus status,  DateTime? appliedDate,  String? jobUrl,  String? location,  WorkType workType,  double? salaryMin,  double? salaryMax,  String salaryCurrency,  JobSource source,  String? sourceName,  int priority,  List<String> tags,  String? notes,  String? resumeVersionId,  bool coverLetterUsed,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _JobApplication():
return $default(_that.id,_that.company,_that.role,_that.status,_that.appliedDate,_that.jobUrl,_that.location,_that.workType,_that.salaryMin,_that.salaryMax,_that.salaryCurrency,_that.source,_that.sourceName,_that.priority,_that.tags,_that.notes,_that.resumeVersionId,_that.coverLetterUsed,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String company,  String role,  ApplicationStatus status,  DateTime? appliedDate,  String? jobUrl,  String? location,  WorkType workType,  double? salaryMin,  double? salaryMax,  String salaryCurrency,  JobSource source,  String? sourceName,  int priority,  List<String> tags,  String? notes,  String? resumeVersionId,  bool coverLetterUsed,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _JobApplication() when $default != null:
return $default(_that.id,_that.company,_that.role,_that.status,_that.appliedDate,_that.jobUrl,_that.location,_that.workType,_that.salaryMin,_that.salaryMax,_that.salaryCurrency,_that.source,_that.sourceName,_that.priority,_that.tags,_that.notes,_that.resumeVersionId,_that.coverLetterUsed,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobApplication implements JobApplication {
  const _JobApplication({required this.id, required this.company, required this.role, this.status = ApplicationStatus.wishlist, this.appliedDate, this.jobUrl, this.location, this.workType = WorkType.onsite, this.salaryMin, this.salaryMax, this.salaryCurrency = 'INR', this.source = JobSource.other, this.sourceName, this.priority = 3, final  List<String> tags = const <String>[], this.notes, this.resumeVersionId, this.coverLetterUsed = false, required this.createdAt, required this.updatedAt}): _tags = tags;
  factory _JobApplication.fromJson(Map<String, dynamic> json) => _$JobApplicationFromJson(json);

@override final  String id;
@override final  String company;
@override final  String role;
@override@JsonKey() final  ApplicationStatus status;
@override final  DateTime? appliedDate;
@override final  String? jobUrl;
@override final  String? location;
@override@JsonKey() final  WorkType workType;
@override final  double? salaryMin;
@override final  double? salaryMax;
@override@JsonKey() final  String salaryCurrency;
@override@JsonKey() final  JobSource source;
@override final  String? sourceName;
@override@JsonKey() final  int priority;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? notes;
@override final  String? resumeVersionId;
@override@JsonKey() final  bool coverLetterUsed;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of JobApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobApplicationCopyWith<_JobApplication> get copyWith => __$JobApplicationCopyWithImpl<_JobApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.company, company) || other.company == company)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.appliedDate, appliedDate) || other.appliedDate == appliedDate)&&(identical(other.jobUrl, jobUrl) || other.jobUrl == jobUrl)&&(identical(other.location, location) || other.location == location)&&(identical(other.workType, workType) || other.workType == workType)&&(identical(other.salaryMin, salaryMin) || other.salaryMin == salaryMin)&&(identical(other.salaryMax, salaryMax) || other.salaryMax == salaryMax)&&(identical(other.salaryCurrency, salaryCurrency) || other.salaryCurrency == salaryCurrency)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.priority, priority) || other.priority == priority)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.resumeVersionId, resumeVersionId) || other.resumeVersionId == resumeVersionId)&&(identical(other.coverLetterUsed, coverLetterUsed) || other.coverLetterUsed == coverLetterUsed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,company,role,status,appliedDate,jobUrl,location,workType,salaryMin,salaryMax,salaryCurrency,source,sourceName,priority,const DeepCollectionEquality().hash(_tags),notes,resumeVersionId,coverLetterUsed,createdAt,updatedAt]);

@override
String toString() {
  return 'JobApplication(id: $id, company: $company, role: $role, status: $status, appliedDate: $appliedDate, jobUrl: $jobUrl, location: $location, workType: $workType, salaryMin: $salaryMin, salaryMax: $salaryMax, salaryCurrency: $salaryCurrency, source: $source, sourceName: $sourceName, priority: $priority, tags: $tags, notes: $notes, resumeVersionId: $resumeVersionId, coverLetterUsed: $coverLetterUsed, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$JobApplicationCopyWith<$Res> implements $JobApplicationCopyWith<$Res> {
  factory _$JobApplicationCopyWith(_JobApplication value, $Res Function(_JobApplication) _then) = __$JobApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String company, String role, ApplicationStatus status, DateTime? appliedDate, String? jobUrl, String? location, WorkType workType, double? salaryMin, double? salaryMax, String salaryCurrency, JobSource source, String? sourceName, int priority, List<String> tags, String? notes, String? resumeVersionId, bool coverLetterUsed, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$JobApplicationCopyWithImpl<$Res>
    implements _$JobApplicationCopyWith<$Res> {
  __$JobApplicationCopyWithImpl(this._self, this._then);

  final _JobApplication _self;
  final $Res Function(_JobApplication) _then;

/// Create a copy of JobApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? company = null,Object? role = null,Object? status = null,Object? appliedDate = freezed,Object? jobUrl = freezed,Object? location = freezed,Object? workType = null,Object? salaryMin = freezed,Object? salaryMax = freezed,Object? salaryCurrency = null,Object? source = null,Object? sourceName = freezed,Object? priority = null,Object? tags = null,Object? notes = freezed,Object? resumeVersionId = freezed,Object? coverLetterUsed = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_JobApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,appliedDate: freezed == appliedDate ? _self.appliedDate : appliedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,jobUrl: freezed == jobUrl ? _self.jobUrl : jobUrl // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,workType: null == workType ? _self.workType : workType // ignore: cast_nullable_to_non_nullable
as WorkType,salaryMin: freezed == salaryMin ? _self.salaryMin : salaryMin // ignore: cast_nullable_to_non_nullable
as double?,salaryMax: freezed == salaryMax ? _self.salaryMax : salaryMax // ignore: cast_nullable_to_non_nullable
as double?,salaryCurrency: null == salaryCurrency ? _self.salaryCurrency : salaryCurrency // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as JobSource,sourceName: freezed == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,resumeVersionId: freezed == resumeVersionId ? _self.resumeVersionId : resumeVersionId // ignore: cast_nullable_to_non_nullable
as String?,coverLetterUsed: null == coverLetterUsed ? _self.coverLetterUsed : coverLetterUsed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
