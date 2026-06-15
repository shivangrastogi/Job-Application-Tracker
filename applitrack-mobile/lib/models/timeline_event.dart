import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/constants/enums.dart';

part 'timeline_event.freezed.dart';
part 'timeline_event.g.dart';

@freezed
abstract class TimelineEvent with _$TimelineEvent {
  const factory TimelineEvent({
    required String id,
    required String applicationId,
    @Default(TimelineEventType.manual) TimelineEventType type,
    required String description,
    required DateTime timestamp,
    String? previousStatus,
    String? newStatus,
    String? source,     // e.g. "Naukri", "LinkedIn", "Gmail"
    String? sourceUrl,  // Gmail thread URL or notification package name
  }) = _TimelineEvent;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventFromJson(json);
}
