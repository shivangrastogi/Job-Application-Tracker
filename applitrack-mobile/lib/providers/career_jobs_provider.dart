import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/career_job.dart';
import '../services/job_board_service.dart';
import 'companies_provider.dart';

part 'career_jobs_provider.g.dart';

/// Fetches live openings for one company from its ATS. Pull-to-refresh in the
/// UI calls `ref.invalidate` / `ref.refresh` on this family.
@riverpod
Future<List<CareerJob>> careerJobs(CareerJobsRef ref, String companyId) async {
  final company = ref.watch(companiesNotifierProvider.notifier).getById(companyId);
  if (company == null) {
    throw JobBoardException('Company not found.');
  }
  final jobs = await JobBoardService.fetchJobs(company);
  // Newest first when we have dates.
  jobs.sort((a, b) {
    final ad = a.postedAt, bd = b.postedAt;
    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;
    return bd.compareTo(ad);
  });
  await ref
      .read(companiesNotifierProvider.notifier)
      .recordFetch(companyId, jobs.length);
  return jobs;
}
