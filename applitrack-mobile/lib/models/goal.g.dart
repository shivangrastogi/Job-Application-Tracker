// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Goal _$GoalFromJson(Map<String, dynamic> json) => _Goal(
  id: json['id'] as String,
  metric:
      $enumDecodeNullable(_$GoalMetricEnumMap, json['metric']) ??
      GoalMetric.applicationsApplied,
  period:
      $enumDecodeNullable(_$GoalPeriodEnumMap, json['period']) ??
      GoalPeriod.daily,
  target: (json['target'] as num).toInt(),
  active: json['active'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GoalToJson(_Goal instance) => <String, dynamic>{
  'id': instance.id,
  'metric': _$GoalMetricEnumMap[instance.metric]!,
  'period': _$GoalPeriodEnumMap[instance.period]!,
  'target': instance.target,
  'active': instance.active,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$GoalMetricEnumMap = {
  GoalMetric.applicationsAdded: 'applicationsAdded',
  GoalMetric.applicationsApplied: 'applicationsApplied',
  GoalMetric.interviews: 'interviews',
};

const _$GoalPeriodEnumMap = {
  GoalPeriod.daily: 'daily',
  GoalPeriod.weekly: 'weekly',
  GoalPeriod.monthly: 'monthly',
};
