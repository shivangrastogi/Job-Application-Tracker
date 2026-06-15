import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/constants/enums.dart';

part 'career_job.freezed.dart';
part 'career_job.g.dart';

/// A single opening fetched from a company's ATS, normalised across providers.
@freezed
abstract class CareerJob with _$CareerJob {
  const factory CareerJob({
    required String id,
    required String companyId,
    required String companyName,
    required String title,
    String? location,
    String? department,
    String? employmentType,
    @Default(CareerWorkType.unknown) CareerWorkType workType,
    String? url,
    DateTime? postedAt,
  }) = _CareerJob;

  factory CareerJob.fromJson(Map<String, dynamic> json) =>
      _$CareerJobFromJson(json);
}
