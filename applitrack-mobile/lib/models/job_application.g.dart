// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JobApplication _$JobApplicationFromJson(Map<String, dynamic> json) =>
    _JobApplication(
      id: json['id'] as String,
      company: json['company'] as String,
      role: json['role'] as String,
      status:
          $enumDecodeNullable(_$ApplicationStatusEnumMap, json['status']) ??
          ApplicationStatus.wishlist,
      appliedDate: json['appliedDate'] == null
          ? null
          : DateTime.parse(json['appliedDate'] as String),
      jobUrl: json['jobUrl'] as String?,
      location: json['location'] as String?,
      workType:
          $enumDecodeNullable(_$WorkTypeEnumMap, json['workType']) ??
          WorkType.onsite,
      salaryMin: (json['salaryMin'] as num?)?.toDouble(),
      salaryMax: (json['salaryMax'] as num?)?.toDouble(),
      salaryCurrency: json['salaryCurrency'] as String? ?? 'INR',
      source:
          $enumDecodeNullable(_$JobSourceEnumMap, json['source']) ??
          JobSource.other,
      sourceName: json['sourceName'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 3,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      notes: json['notes'] as String?,
      resumeVersionId: json['resumeVersionId'] as String?,
      coverLetterUsed: json['coverLetterUsed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$JobApplicationToJson(_JobApplication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company': instance.company,
      'role': instance.role,
      'status': _$ApplicationStatusEnumMap[instance.status]!,
      'appliedDate': instance.appliedDate?.toIso8601String(),
      'jobUrl': instance.jobUrl,
      'location': instance.location,
      'workType': _$WorkTypeEnumMap[instance.workType]!,
      'salaryMin': instance.salaryMin,
      'salaryMax': instance.salaryMax,
      'salaryCurrency': instance.salaryCurrency,
      'source': _$JobSourceEnumMap[instance.source]!,
      'sourceName': instance.sourceName,
      'priority': instance.priority,
      'tags': instance.tags,
      'notes': instance.notes,
      'resumeVersionId': instance.resumeVersionId,
      'coverLetterUsed': instance.coverLetterUsed,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.wishlist: 'wishlist',
  ApplicationStatus.applied: 'applied',
  ApplicationStatus.phoneScreen: 'phoneScreen',
  ApplicationStatus.technicalRound: 'technicalRound',
  ApplicationStatus.onsiteInterview: 'onsiteInterview',
  ApplicationStatus.offerReceived: 'offerReceived',
  ApplicationStatus.accepted: 'accepted',
  ApplicationStatus.rejected: 'rejected',
  ApplicationStatus.withdrawn: 'withdrawn',
  ApplicationStatus.ghosted: 'ghosted',
};

const _$WorkTypeEnumMap = {
  WorkType.remote: 'remote',
  WorkType.hybrid: 'hybrid',
  WorkType.onsite: 'onsite',
};

const _$JobSourceEnumMap = {
  JobSource.linkedin: 'linkedin',
  JobSource.naukri: 'naukri',
  JobSource.indeed: 'indeed',
  JobSource.company: 'company',
  JobSource.referral: 'referral',
  JobSource.other: 'other',
};
