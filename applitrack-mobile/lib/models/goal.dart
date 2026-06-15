import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/constants/enums.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

/// A user target like "100 applications submitted per day".
@freezed
abstract class Goal with _$Goal {
  const factory Goal({
    required String id,
    @Default(GoalMetric.applicationsApplied) GoalMetric metric,
    @Default(GoalPeriod.daily) GoalPeriod period,
    required int target,
    @Default(true) bool active,
    required DateTime createdAt,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
