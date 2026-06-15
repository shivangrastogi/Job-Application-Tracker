import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/constants/enums.dart';

part 'job_application.freezed.dart';
part 'job_application.g.dart';

@freezed
abstract class JobApplication with _$JobApplication {
  const factory JobApplication({
    required String id,
    required String company,
    required String role,
    @Default(ApplicationStatus.wishlist) ApplicationStatus status,
    DateTime? appliedDate,
    String? jobUrl,
    String? location,
    @Default(WorkType.onsite) WorkType workType,
    double? salaryMin,
    double? salaryMax,
    @Default('INR') String salaryCurrency,
    @Default(JobSource.other) JobSource source,
    String? sourceName,
    @Default(3) int priority,
    @Default(<String>[]) List<String> tags,
    String? notes,
    String? resumeVersionId,
    @Default(false) bool coverLetterUsed,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _JobApplication;

  factory JobApplication.fromJson(Map<String, dynamic> json) =>
      _$JobApplicationFromJson(json);
}
