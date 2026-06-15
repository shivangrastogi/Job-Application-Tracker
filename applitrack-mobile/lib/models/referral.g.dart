// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Referral _$ReferralFromJson(Map<String, dynamic> json) => _Referral(
  id: json['id'] as String,
  sourceId: json['sourceId'] as String?,
  company: json['company'] as String,
  role: json['role'] as String?,
  jobUrl: json['jobUrl'] as String?,
  referrerName: json['referrerName'] as String?,
  status:
      $enumDecodeNullable(_$ReferralStatusEnumMap, json['status']) ??
      ReferralStatus.requested,
  requestedDate: json['requestedDate'] == null
      ? null
      : DateTime.parse(json['requestedDate'] as String),
  notes: json['notes'] as String?,
  linkedApplicationId: json['linkedApplicationId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReferralToJson(_Referral instance) => <String, dynamic>{
  'id': instance.id,
  'sourceId': instance.sourceId,
  'company': instance.company,
  'role': instance.role,
  'jobUrl': instance.jobUrl,
  'referrerName': instance.referrerName,
  'status': _$ReferralStatusEnumMap[instance.status]!,
  'requestedDate': instance.requestedDate?.toIso8601String(),
  'notes': instance.notes,
  'linkedApplicationId': instance.linkedApplicationId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$ReferralStatusEnumMap = {
  ReferralStatus.requested: 'requested',
  ReferralStatus.referred: 'referred',
  ReferralStatus.applied: 'applied',
  ReferralStatus.rejected: 'rejected',
  ReferralStatus.noResponse: 'noResponse',
};
