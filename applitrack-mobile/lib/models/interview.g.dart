// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Interview _$InterviewFromJson(Map<String, dynamic> json) => _Interview(
  id: json['id'] as String,
  applicationId: json['applicationId'] as String,
  type:
      $enumDecodeNullable(_$InterviewTypeEnumMap, json['type']) ??
      InterviewType.phone,
  scheduledAt: DateTime.parse(json['scheduledAt'] as String),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 60,
  platform: json['platform'] as String?,
  interviewerName: json['interviewerName'] as String?,
  notes: json['notes'] as String?,
  feedback: json['feedback'] as String?,
  outcome:
      $enumDecodeNullable(_$InterviewOutcomeEnumMap, json['outcome']) ??
      InterviewOutcome.pending,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$InterviewToJson(_Interview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'applicationId': instance.applicationId,
      'type': _$InterviewTypeEnumMap[instance.type]!,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'platform': instance.platform,
      'interviewerName': instance.interviewerName,
      'notes': instance.notes,
      'feedback': instance.feedback,
      'outcome': _$InterviewOutcomeEnumMap[instance.outcome]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$InterviewTypeEnumMap = {
  InterviewType.phone: 'phone',
  InterviewType.technical: 'technical',
  InterviewType.behavioral: 'behavioral',
  InterviewType.systemDesign: 'systemDesign',
  InterviewType.takeHome: 'takeHome',
  InterviewType.hr: 'hr',
  InterviewType.final_: 'final_',
};

const _$InterviewOutcomeEnumMap = {
  InterviewOutcome.passed: 'passed',
  InterviewOutcome.failed: 'failed',
  InterviewOutcome.pending: 'pending',
  InterviewOutcome.noFeedback: 'noFeedback',
};
