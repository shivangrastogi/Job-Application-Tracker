import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/constants/enums.dart';
import 'applications_provider.dart';
import 'interviews_provider.dart';

part 'analytics_provider.g.dart';

class AnalyticsSummary {
  final int total;
  final int active;
  final int interviewsThisWeek;
  final int offers;
  final int rejected;
  final double responseRate;
  final double offerRate;
  final Map<ApplicationStatus, int> byStatus;
  final Map<JobSource, int> bySource;
  final Map<WorkType, int> byWorkType;

  const AnalyticsSummary({
    required this.total,
    required this.active,
    required this.interviewsThisWeek,
    required this.offers,
    required this.rejected,
    required this.responseRate,
    required this.offerRate,
    required this.byStatus,
    required this.bySource,
    required this.byWorkType,
  });
}

@riverpod
AnalyticsSummary analyticsSummary(AnalyticsSummaryRef ref) {
  final apps = ref.watch(applicationsNotifierProvider);
  final thisWeekInterviews = ref.watch(interviewsThisWeekProvider);

  final byStatus = <ApplicationStatus, int>{};
  for (final s in ApplicationStatus.values) {
    byStatus[s] = apps.where((a) => a.status == s).length;
  }

  final bySource = <JobSource, int>{};
  for (final s in JobSource.values) {
    bySource[s] = apps.where((a) => a.source == s).length;
  }

  final byWorkType = <WorkType, int>{};
  for (final w in WorkType.values) {
    byWorkType[w] = apps.where((a) => a.workType == w).length;
  }

  final applied = apps.where((a) => a.status != ApplicationStatus.wishlist).length;
  final anyResponse = apps.where((a) {
    return a.status.pipelineOrder >= ApplicationStatus.phoneScreen.pipelineOrder;
  }).length;
  final offersCount = byStatus[ApplicationStatus.offerReceived]! +
      byStatus[ApplicationStatus.accepted]!;

  return AnalyticsSummary(
    total: apps.length,
    active: apps.where((a) => a.status.isActive).length,
    interviewsThisWeek: thisWeekInterviews.length,
    offers: offersCount,
    rejected: byStatus[ApplicationStatus.rejected]!,
    responseRate: applied == 0 ? 0 : anyResponse / applied,
    offerRate: applied == 0 ? 0 : offersCount / applied,
    byStatus: byStatus,
    bySource: bySource,
    byWorkType: byWorkType,
  );
}

@riverpod
List<MapEntry<DateTime, int>> applicationsOverTime(
    ApplicationsOverTimeRef ref) {
  final apps = ref.watch(applicationsNotifierProvider);
  final map = <DateTime, int>{};
  for (final app in apps) {
    final day = DateTime(
        app.createdAt.year, app.createdAt.month, app.createdAt.day);
    map[day] = (map[day] ?? 0) + 1;
  }
  final entries = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  return entries;
}
