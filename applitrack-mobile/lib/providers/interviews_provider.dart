import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/interview.dart';
import '../core/constants/enums.dart';
import '../services/hive_service.dart';

part 'interviews_provider.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
class InterviewsNotifier extends _$InterviewsNotifier {
  @override
  List<Interview> build() => _loadAll();

  List<Interview> _loadAll() {
    return HiveService.interviewsBox.values
        .map((raw) => Interview.fromJson(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  Future<Interview> add({
    required String applicationId,
    required InterviewType type,
    required DateTime scheduledAt,
    int durationMinutes = 60,
    String? platform,
    String? interviewerName,
    String? notes,
  }) async {
    final interview = Interview(
      id: _uuid.v4(),
      applicationId: applicationId,
      type: type,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      platform: platform,
      interviewerName: interviewerName,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await HiveService.interviewsBox.put(interview.id, interview.toJson());
    state = _loadAll();
    return interview;
  }

  Future<void> update(Interview updated) async {
    await HiveService.interviewsBox.put(updated.id, updated.toJson());
    state = _loadAll();
  }

  Future<void> delete(String id) async {
    await HiveService.interviewsBox.delete(id);
    state = _loadAll();
  }

  List<Interview> forApplication(String applicationId) =>
      state.where((i) => i.applicationId == applicationId).toList();

  List<Interview> forDate(DateTime date) {
    return state.where((i) {
      final d = i.scheduledAt;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }
}

@riverpod
List<Interview> upcomingInterviews(UpcomingInterviewsRef ref) {
  final all = ref.watch(interviewsNotifierProvider);
  final now = DateTime.now();
  return all.where((i) => i.scheduledAt.isAfter(now)).take(10).toList();
}

@riverpod
List<Interview> interviewsThisWeek(InterviewsThisWeekRef ref) {
  final all = ref.watch(interviewsNotifierProvider);
  final now = DateTime.now();
  final weekEnd = now.add(const Duration(days: 7));
  return all
      .where((i) => i.scheduledAt.isAfter(now) && i.scheduledAt.isBefore(weekEnd))
      .toList();
}
