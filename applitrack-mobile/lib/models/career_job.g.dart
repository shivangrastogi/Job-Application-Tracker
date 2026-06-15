// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CareerJob _$CareerJobFromJson(Map<String, dynamic> json) => _CareerJob(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  companyName: json['companyName'] as String,
  title: json['title'] as String,
  location: json['location'] as String?,
  department: json['department'] as String?,
  employmentType: json['employmentType'] as String?,
  workType:
      $enumDecodeNullable(_$CareerWorkTypeEnumMap, json['workType']) ??
      CareerWorkType.unknown,
  url: json['url'] as String?,
  postedAt: json['postedAt'] == null
      ? null
      : DateTime.parse(json['postedAt'] as String),
);

Map<String, dynamic> _$CareerJobToJson(_CareerJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'companyName': instance.companyName,
      'title': instance.title,
      'location': instance.location,
      'department': instance.department,
      'employmentType': instance.employmentType,
      'workType': _$CareerWorkTypeEnumMap[instance.workType]!,
      'url': instance.url,
      'postedAt': instance.postedAt?.toIso8601String(),
    };

const _$CareerWorkTypeEnumMap = {
  CareerWorkType.remote: 'remote',
  CareerWorkType.hybrid: 'hybrid',
  CareerWorkType.onsite: 'onsite',
  CareerWorkType.unknown: 'unknown',
};
