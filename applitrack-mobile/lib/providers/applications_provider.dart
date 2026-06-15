import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/job_application.dart';
import '../models/timeline_event.dart';
import '../core/constants/enums.dart';
import '../services/hive_service.dart';

part 'applications_provider.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
class ApplicationsNotifier extends _$ApplicationsNotifier {
  @override
  List<JobApplication> build() {
    return _loadAll();
  }

  List<JobApplication> _loadAll() {
    final box = HiveService.applicationsBox;
    return box.values
        .map((raw) => JobApplication.fromJson(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<JobApplication> add({
    required String company,
    required String role,
    ApplicationStatus status = ApplicationStatus.wishlist,
    DateTime? appliedDate,
    String? jobUrl,
    String? location,
    WorkType workType = WorkType.onsite,
    double? salaryMin,
    double? salaryMax,
    String salaryCurrency = 'INR',
    JobSource source = JobSource.other,
    String? sourceName,
    int priority = 3,
    List<String> tags = const [],
    String? notes,
    String? resumeVersionId,
    bool coverLetterUsed = false,
  }) async {
    final now = DateTime.now();
    final app = JobApplication(
      id: _uuid.v4(),
      company: company,
      role: role,
      status: status,
      appliedDate: appliedDate,
      jobUrl: jobUrl,
      location: location,
      workType: workType,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      salaryCurrency: salaryCurrency,
      source: source,
      sourceName: sourceName,
      priority: priority,
      tags: tags,
      notes: notes,
      resumeVersionId: resumeVersionId,
      coverLetterUsed: coverLetterUsed,
      createdAt: now,
      updatedAt: now,
    );
    await HiveService.applicationsBox.put(app.id, app.toJson());
    _addTimelineEvent(
      applicationId: app.id,
      type: TimelineEventType.statusChange,
      description: 'Application created as ${status.label}',
      newStatus: status.name,
    );
    state = _loadAll();
    return app;
  }

  Future<void> update(JobApplication updated) async {
    final previous = getById(updated.id);
    final app = updated.copyWith(updatedAt: DateTime.now());
    await HiveService.applicationsBox.put(app.id, app.toJson());
    if (previous != null && previous.status != updated.status) {
      _addTimelineEvent(
        applicationId: app.id,
        type: TimelineEventType.statusChange,
        description: 'Status changed from ${previous.status.label} to ${updated.status.label}',
        previousStatus: previous.status.name,
        newStatus: updated.status.name,
      );
    }
    state = _loadAll();
  }

  Future<void> delete(String id) async {
    await HiveService.applicationsBox.delete(id);
    // Clean up related data
    final interviewKeys = HiveService.interviewsBox.keys
        .where((k) => HiveService.interviewsBox.get(k)?['applicationId'] == id)
        .toList();
    final contactKeys = HiveService.contactsBox.keys
        .where((k) => HiveService.contactsBox.get(k)?['applicationId'] == id)
        .toList();
    final timelineKeys = HiveService.timelineBox.keys
        .where((k) => HiveService.timelineBox.get(k)?['applicationId'] == id)
        .toList();
    for (final k in [...interviewKeys, ...contactKeys, ...timelineKeys]) {
      HiveService.timelineBox.delete(k);
    }
    state = _loadAll();
  }

  JobApplication? getById(String id) {
    final raw = HiveService.applicationsBox.get(id);
    if (raw == null) return null;
    return JobApplication.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> addNote(String applicationId, String note) async {
    _addTimelineEvent(
      applicationId: applicationId,
      type: TimelineEventType.note,
      description: note,
    );
  }

  // Public — used by notification import to attach a pre-built event
  Future<void> addTimelineEvent(TimelineEvent event) async {
    HiveService.timelineBox.put(event.id, event.toJson());
  }

  // Public — used by notification import; saves directly to avoid double timeline event
  Future<void> updateStatus(
      JobApplication app, ApplicationStatus newStatus) async {
    final previous = app.status;
    if (previous == newStatus) return;
    final updated = app.copyWith(status: newStatus, updatedAt: DateTime.now());
    await HiveService.applicationsBox.put(updated.id, updated.toJson());
    _addTimelineEvent(
      applicationId: app.id,
      type: TimelineEventType.statusChange,
      description: 'Status → ${newStatus.label} (via notification)',
      previousStatus: previous.name,
      newStatus: newStatus.name,
    );
    state = _loadAll();
  }

  void _addTimelineEvent({
    required String applicationId,
    required TimelineEventType type,
    required String description,
    String? previousStatus,
    String? newStatus,
  }) {
    final event = TimelineEvent(
      id: _uuid.v4(),
      applicationId: applicationId,
      type: type,
      description: description,
      timestamp: DateTime.now(),
      previousStatus: previousStatus,
      newStatus: newStatus,
    );
    HiveService.timelineBox.put(event.id, event.toJson());
  }
}

@riverpod
List<JobApplication> applicationsByStatus(
  ApplicationsByStatusRef ref,
  ApplicationStatus status,
) {
  final all = ref.watch(applicationsNotifierProvider);
  return all.where((a) => a.status == status).toList();
}

@riverpod
List<JobApplication> activeApplications(ActiveApplicationsRef ref) {
  final all = ref.watch(applicationsNotifierProvider);
  return all.where((a) => a.status.isActive).toList();
}

@riverpod
List<JobApplication> recentApplications(RecentApplicationsRef ref) {
  final all = ref.watch(applicationsNotifierProvider);
  return all.take(10).toList();
}

@riverpod
Map<ApplicationStatus, int> applicationCountsByStatus(
  ApplicationCountsByStatusRef ref,
) {
  final all = ref.watch(applicationsNotifierProvider);
  final map = <ApplicationStatus, int>{};
  for (final status in ApplicationStatus.values) {
    map[status] = all.where((a) => a.status == status).length;
  }
  return map;
}
