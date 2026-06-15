// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimelineEvent _$TimelineEventFromJson(Map<String, dynamic> json) =>
    _TimelineEvent(
      id: json['id'] as String,
      applicationId: json['applicationId'] as String,
      type:
          $enumDecodeNullable(_$TimelineEventTypeEnumMap, json['type']) ??
          TimelineEventType.manual,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      previousStatus: json['previousStatus'] as String?,
      newStatus: json['newStatus'] as String?,
      source: json['source'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
    );

Map<String, dynamic> _$TimelineEventToJson(_TimelineEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'applicationId': instance.applicationId,
      'type': _$TimelineEventTypeEnumMap[instance.type]!,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'previousStatus': instance.previousStatus,
      'newStatus': instance.newStatus,
      'source': instance.source,
      'sourceUrl': instance.sourceUrl,
    };

const _$TimelineEventTypeEnumMap = {
  TimelineEventType.statusChange: 'statusChange',
  TimelineEventType.note: 'note',
  TimelineEventType.interviewScheduled: 'interviewScheduled',
  TimelineEventType.offerReceived: 'offerReceived',
  TimelineEventType.rejection: 'rejection',
  TimelineEventType.emailDetected: 'emailDetected',
  TimelineEventType.notificationDetected: 'notificationDetected',
  TimelineEventType.manual: 'manual',
};
