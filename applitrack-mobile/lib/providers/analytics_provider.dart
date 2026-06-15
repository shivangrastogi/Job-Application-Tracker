import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/constants/enums.dart';
import 'applications_provider.dart';
import 'documents_provider.dart';
import 'interviews_provider.dart';

part 'analytics_provider.g.dart';

/// Below this many sent applications, a resume's rates are noise — flagged as
/// "low data" so they aren't trusted or surfaced as the top resume.
const int kMinResumeSample = 5;

/// Per-resume conversion stats — "which resume is working".
class ResumeStat {
  final String id; // document id, or '__none__' for applications with no resume
  final String name;
  final int sent;
  final int responded;
  final int interviewed;
  final int offered;

  const ResumeStat({
    required this.id,
    required this.name,
    required this.sent,
    required this.responded,
    required this.interviewed,
    required this.offered,
  });

  double get responseRate => sent == 0 ? 0 : responded / sent;
  double get interviewRate => sent == 0 ? 0 : interviewed / sent;
  double get offerRate => sent == 0 ? 0 : offered / sent;
  bool get lowData => sent < kMinResumeSample;
}

// Status sets shared with the web app so numbers match across platforms.
const _respondedStatuses = {
  ApplicationStatus.phoneScreen,
  ApplicationStatus.technicalRound,
  ApplicationStatus.onsiteInterview,
  ApplicationStatus.offerReceived,
  ApplicationStatus.accepted,
  ApplicationStatus.rejected,
};
const _interviewedStatuses = {
  ApplicationStatus.phoneScreen,
  ApplicationStatus.technicalRound,
  ApplicationStatus.onsiteInterview,
  ApplicationStatus.offerReceived,
  ApplicationStatus.accepted,
};
const _offeredStatuses = {
  ApplicationStatus.offerReceived,
  ApplicationStatus.accepted,
};

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
  final List<ResumeStat> byResume;
  final List<ResumeStat> byCoverLetter;

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
    required this.byResume,
    required this.byCoverLetter,
  });
}

@riverpod
AnalyticsSummary analyticsSummary(AnalyticsSummaryRef ref) {
  final apps = ref.watch(applicationsNotifierProvider);
  final thisWeekInterviews = ref.watch(interviewsThisWeekProvider);
  final documents = ref.watch(documentsNotifierProvider);

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

  // ── Per-resume performance ──
  // Bucket sent applications (status != wishlist) by their resume; null → shared
  // "No resume" bucket. Then sort strongest-first by interview rate.
  final resumeBuckets = <String, List<int>>{}; // [sent, responded, interviewed, offered]
  for (final a in apps) {
    if (a.status == ApplicationStatus.wishlist) continue;
    final key = a.resumeVersionId ?? '__none__';
    final b = resumeBuckets.putIfAbsent(key, () => [0, 0, 0, 0]);
    b[0]++;
    if (_respondedStatuses.contains(a.status)) b[1]++;
    if (_interviewedStatuses.contains(a.status)) b[2]++;
    if (_offeredStatuses.contains(a.status)) b[3]++;
  }
  final docsById = {for (final d in documents) d.id: d};
  String resumeName(String id) {
    if (id == '__none__') return 'No resume';
    final doc = docsById[id];
    if (doc == null) return 'Deleted resume';
    return (doc.version != null && doc.version!.isNotEmpty)
        ? '${doc.name} · v${doc.version}'
        : doc.name;
  }

  final byResume = resumeBuckets.entries
      .map((e) => ResumeStat(
            id: e.key,
            name: resumeName(e.key),
            sent: e.value[0],
            responded: e.value[1],
            interviewed: e.value[2],
            offered: e.value[3],
          ))
      .toList()
    ..sort((a, b) {
      // Enough-data resumes first, then by interview rate, then volume.
      if (a.lowData != b.lowData) return a.lowData ? 1 : -1;
      final byInterview = b.interviewRate.compareTo(a.interviewRate);
      return byInterview != 0 ? byInterview : b.sent.compareTo(a.sent);
    });

  // ── Cover-letter impact: with vs without, across sent applications ──
  final clWith = [0, 0, 0, 0];
  final clWithout = [0, 0, 0, 0];
  for (final a in apps) {
    if (a.status == ApplicationStatus.wishlist) continue;
    final b = a.coverLetterUsed ? clWith : clWithout;
    b[0]++;
    if (_respondedStatuses.contains(a.status)) b[1]++;
    if (_interviewedStatuses.contains(a.status)) b[2]++;
    if (_offeredStatuses.contains(a.status)) b[3]++;
  }
  final byCoverLetter = <ResumeStat>[
    ResumeStat(
        id: 'with',
        name: 'With cover letter',
        sent: clWith[0],
        responded: clWith[1],
        interviewed: clWith[2],
        offered: clWith[3]),
    ResumeStat(
        id: 'without',
        name: 'Without cover letter',
        sent: clWithout[0],
        responded: clWithout[1],
        interviewed: clWithout[2],
        offered: clWithout[3]),
  ].where((r) => r.sent > 0).toList();

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
    byResume: byResume,
    byCoverLetter: byCoverLetter,
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
