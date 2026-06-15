// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReferralSource _$ReferralSourceFromJson(Map<String, dynamic> json) =>
    _ReferralSource(
      id: json['id'] as String,
      name: json['name'] as String,
      type:
          $enumDecodeNullable(_$ReferralSourceTypeEnumMap, json['type']) ??
          ReferralSourceType.group,
      url: json['url'] as String?,
      formTemplate: json['formTemplate'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ReferralSourceToJson(_ReferralSource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ReferralSourceTypeEnumMap[instance.type]!,
      'url': instance.url,
      'formTemplate': instance.formTemplate,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ReferralSourceTypeEnumMap = {
  ReferralSourceType.googleForm: 'googleForm',
  ReferralSourceType.group: 'group',
  ReferralSourceType.linkedin: 'linkedin',
  ReferralSourceType.person: 'person',
};
