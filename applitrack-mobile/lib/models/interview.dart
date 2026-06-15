import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/constants/enums.dart';

part 'interview.freezed.dart';
part 'interview.g.dart';

@freezed
abstract class Interview with _$Interview {
  const factory Interview({
    required String id,
    required String applicationId,
    @Default(InterviewType.phone) InterviewType type,
    required DateTime scheduledAt,
    @Default(60) int durationMinutes,
    String? platform,
    String? interviewerName,
    String? notes,
    String? feedback,
    @Default(InterviewOutcome.pending) InterviewOutcome outcome,
    required DateTime createdAt,
  }) = _Interview;

  factory Interview.fromJson(Map<String, dynamic> json) =>
      _$InterviewFromJson(json);
}
