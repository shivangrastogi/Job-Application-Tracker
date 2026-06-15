import 'package:flutter_test/flutter_test.dart';
import 'package:applitrack/models/job_application.dart';
import 'package:applitrack/models/interview.dart';
import 'package:applitrack/models/contact.dart';
import 'package:applitrack/models/timeline_event.dart';
import 'package:applitrack/core/constants/enums.dart';

void main() {
  final now = DateTime(2025, 6, 1, 12);

  group('JobApplication', () {
    late JobApplication app;

    setUp(() {
      app = JobApplication(
        id: 'id-1',
        company: 'Acme Corp',
        role: 'Flutter Developer',
        status: ApplicationStatus.applied,
        workType: WorkType.remote,
        source: JobSource.linkedin,
        priority: 4,
        tags: const ['flutter', 'remote'],
        salaryCurrency: 'INR',
        coverLetterUsed: false,
        createdAt: now,
        updatedAt: now,
      );
    });

    test('fromJson / toJson round-trip preserves all fields', () {
      final json = app.toJson();
      final restored = JobApplication.fromJson(json);
      expect(restored.id, app.id);
      expect(restored.company, app.company);
      expect(restored.role, app.role);
      expect(restored.status, app.status);
      expect(restored.workType, app.workType);
      expect(restored.source, app.source);
      expect(restored.priority, app.priority);
      expect(restored.tags, app.tags);
      expect(restored.createdAt, app.createdAt);
    });

    test('copyWith changes only specified fields', () {
      final updated = app.copyWith(
          status: ApplicationStatus.offerReceived, priority: 5);
      expect(updated.status, ApplicationStatus.offerReceived);
      expect(updated.priority, 5);
      expect(updated.company, 'Acme Corp');
      expect(updated.role, 'Flutter Developer');
    });

    test('status.isActive is true for pipeline stages', () {
      for (final s in [
        ApplicationStatus.wishlist,
        ApplicationStatus.applied,
        ApplicationStatus.phoneScreen,
        ApplicationStatus.technicalRound,
        ApplicationStatus.onsiteInterview,
        ApplicationStatus.offerReceived,
      ]) {
        expect(s.isActive, isTrue, reason: '${s.name} should be active');
      }
    });

    test('status.isClosed is true for terminal stages', () {
      for (final s in [
        ApplicationStatus.accepted,
        ApplicationStatus.rejected,
        ApplicationStatus.withdrawn,
        ApplicationStatus.ghosted,
      ]) {
        expect(s.isClosed, isTrue, reason: '${s.name} should be closed');
      }
    });

    test('status.pipelineOrder increases through funnel', () {
      final stages = [
        ApplicationStatus.wishlist,
        ApplicationStatus.applied,
        ApplicationStatus.phoneScreen,
        ApplicationStatus.technicalRound,
        ApplicationStatus.onsiteInterview,
        ApplicationStatus.offerReceived,
      ];
      for (int i = 1; i < stages.length; i++) {
        expect(stages[i].pipelineOrder,
            greaterThan(stages[i - 1].pipelineOrder));
      }
    });
  });

  group('Interview', () {
    test('fromJson / toJson round-trip', () {
      final interview = Interview(
        id: 'iv-1',
        applicationId: 'app-1',
        type: InterviewType.technical,
        scheduledAt: now,
        durationMinutes: 60,
        outcome: InterviewOutcome.pending,
        createdAt: now,
      );
      final restored = Interview.fromJson(interview.toJson());
      expect(restored.id, interview.id);
      expect(restored.type, interview.type);
      expect(restored.scheduledAt, interview.scheduledAt);
      expect(restored.durationMinutes, interview.durationMinutes);
      expect(restored.outcome, interview.outcome);
    });
  });

  group('Contact', () {
    test('fromJson / toJson round-trip', () {
      final contact = Contact(
        id: 'c-1',
        applicationId: 'app-1',
        name: 'Jane Doe',
        title: 'Recruiter',
        email: 'jane@acme.com',
        createdAt: now,
      );
      final restored = Contact.fromJson(contact.toJson());
      expect(restored.id, contact.id);
      expect(restored.name, contact.name);
      expect(restored.email, contact.email);
      expect(restored.title, contact.title);
    });
  });

  group('TimelineEvent', () {
    test('fromJson / toJson round-trip', () {
      final event = TimelineEvent(
        id: 'ev-1',
        applicationId: 'app-1',
        type: TimelineEventType.statusChange,
        description: 'Status changed to Applied',
        timestamp: now,
        previousStatus: 'wishlist',
        newStatus: 'applied',
      );
      final restored = TimelineEvent.fromJson(event.toJson());
      expect(restored.id, event.id);
      expect(restored.type, event.type);
      expect(restored.description, event.description);
      expect(restored.previousStatus, 'wishlist');
      expect(restored.newStatus, 'applied');
    });
  });

  group('ApplicationStatus enum helpers', () {
    test('label is non-empty for all values', () {
      for (final s in ApplicationStatus.values) {
        expect(s.label, isNotEmpty);
      }
    });

    test('pipelineOrder is unique for active statuses', () {
      final activeStatuses = ApplicationStatus.values
          .where((s) => s.isActive)
          .toList();
      final orders = activeStatuses.map((s) => s.pipelineOrder).toSet();
      expect(orders.length, activeStatuses.length,
          reason: 'pipelineOrder must be unique for active statuses');
    });
  });

  group('WorkType / JobSource / InterviewType labels', () {
    test('all WorkType values have labels', () {
      for (final w in WorkType.values) {
        expect(w.label, isNotEmpty);
      }
    });

    test('all JobSource values have labels', () {
      for (final s in JobSource.values) {
        expect(s.label, isNotEmpty);
      }
    });

    test('all InterviewType values have labels', () {
      for (final t in InterviewType.values) {
        expect(t.label, isNotEmpty);
      }
    });
  });
}
