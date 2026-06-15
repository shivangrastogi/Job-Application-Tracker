import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/enums.dart';
import '../models/goal.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import 'applications_provider.dart';
import 'interviews_provider.dart';

part 'goals_provider.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
class GoalsNotifier extends _$GoalsNotifier {
  @override
  List<Goal> build() => _loadAll();

  List<Goal> _loadAll() {
    return HiveService.goalsBox.values
        .map((raw) => Goal.fromJson(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => a.period.index.compareTo(b.period.index));
  }

  Future<Goal> add({
    required GoalMetric metric,
    required GoalPeriod period,
    required int target,
  }) async {
    final goal = Goal(
      id: _uuid.v4(),
      metric: metric,
      period: period,
      target: target,
      createdAt: DateTime.now(),
    );
    await HiveService.goalsBox.put(goal.id, goal.toJson());
    state = _loadAll();
    _syncReminder();
    return goal;
  }

  Future<void> update(Goal goal) async {
    await HiveService.goalsBox.put(goal.id, goal.toJson());
    state = _loadAll();
    _syncReminder();
  }

  Future<void> delete(String id) async {
    await HiveService.goalsBox.delete(id);
    state = _loadAll();
    _syncReminder();
  }

  /// Schedule a daily reminder while at least one daily goal is active;
  /// otherwise cancel it.
  void _syncReminder() {
    final hasDaily =
        state.any((g) => g.active && g.period == GoalPeriod.daily);
    if (hasDaily) {
      NotificationService.scheduleDailyGoalReminder();
    } else {
      NotificationService.cancelDailyGoalReminder();
    }
  }

  Future<void> toggleActive(Goal goal) =>
      update(goal.copyWith(active: !goal.active));
}

/// Progress of one goal against its target within the current period window.
class GoalProgress {
  final Goal goal;
  final int current;

  const GoalProgress({required this.goal, required this.current});

  int get target => goal.target;
  double get fraction => target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);
  bool get achieved => current >= target;
  int get remaining => (target - current).clamp(0, target);
}

/// Computes live progress for every goal from applications + interviews.
@riverpod
List<GoalProgress> goalProgress(GoalProgressRef ref) {
  final goals = ref.watch(goalsNotifierProvider);
  final apps = ref.watch(applicationsNotifierProvider);
  final interviews = ref.watch(interviewsNotifierProvider);
  final now = DateTime.now();

  return goals.map((goal) {
    final start = _windowStart(goal.period, now);
    int count;
    switch (goal.metric) {
      case GoalMetric.applicationsAdded:
        count = apps.where((a) => !a.createdAt.isBefore(start)).length;
        break;
      case GoalMetric.applicationsApplied:
        count = apps
            .where((a) => a.appliedDate != null && !a.appliedDate!.isBefore(start))
            .length;
        break;
      case GoalMetric.interviews:
        count = interviews.where((i) => !i.createdAt.isBefore(start)).length;
        break;
    }
    return GoalProgress(goal: goal, current: count);
  }).toList();
}

DateTime _windowStart(GoalPeriod period, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  switch (period) {
    case GoalPeriod.daily:
      return today;
    case GoalPeriod.weekly:
      // Week starts Monday.
      return today.subtract(Duration(days: today.weekday - 1));
    case GoalPeriod.monthly:
      return DateTime(now.year, now.month, 1);
  }
}
