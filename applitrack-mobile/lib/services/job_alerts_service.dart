import '../models/company.dart';
import 'hive_service.dart';
import 'job_board_service.dart';
import 'notification_service.dart';

class JobAlertResult {
  final String companyId;
  final String companyName;
  final int newCount;
  final int totalCount;
  const JobAlertResult({
    required this.companyId,
    required this.companyName,
    required this.newCount,
    required this.totalCount,
  });
}

/// Checks tracked companies for new openings by diffing fetched job IDs against
/// a per-company "seen" set in Hive, then fires notifications. Runs on demand
/// (refresh button) or best-effort on app launch — no background plugin needed.
class JobAlertsService {
  static const _lastCheckKey = 'jobAlertsLastCheck';

  /// Diffs one company and (optionally) notifies. The very first check for a
  /// company just records the baseline silently.
  static Future<JobAlertResult> checkCompany(Company company,
      {bool notify = true}) async {
    final jobs = await JobBoardService.fetchJobs(company);
    final ids = jobs.map((j) => j.id).toList();
    final box = HiveService.seenJobsBox;
    final stored = box.get(company.id);
    final seen = stored is List ? stored.cast<String>().toSet() : <String>{};
    final isBaseline = stored == null;

    final newIds = ids.where((id) => !seen.contains(id)).toList();
    await box.put(company.id, ids);

    final newCount = isBaseline ? 0 : newIds.length;
    if (notify && newCount > 0) {
      final sample = jobs
          .where((j) => newIds.contains(j.id))
          .take(2)
          .map((j) => j.title)
          .join(', ');
      await NotificationService.showNewJobs(
        id: company.id.hashCode.abs(),
        title: '$newCount new at ${company.name}',
        body: sample.isEmpty ? 'Tap to view openings' : sample,
      );
    }
    return JobAlertResult(
      companyId: company.id,
      companyName: company.name,
      newCount: newCount,
      totalCount: ids.length,
    );
  }

  /// Checks every fetchable company. Returns per-company results (best-effort:
  /// failures are skipped silently).
  static Future<List<JobAlertResult>> checkAll(List<Company> companies,
      {bool notify = true}) async {
    final results = <JobAlertResult>[];
    for (final c in companies.where((c) => c.provider.fetchable)) {
      try {
        results.add(await checkCompany(c, notify: notify));
      } catch (_) {
        // Skip companies that fail; don't block the rest.
      }
    }
    HiveService.settingsBox
        .put(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
    return results;
  }

  /// Best-effort launch check, throttled so it runs at most once per [minGap].
  static Future<void> maybeCheckOnLaunch(List<Company> companies,
      {Duration minGap = const Duration(hours: 6)}) async {
    final last = HiveService.settingsBox.get(_lastCheckKey) as int?;
    if (last != null) {
      final since = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(last));
      if (since < minGap) return;
    }
    await checkAll(companies);
  }
}
