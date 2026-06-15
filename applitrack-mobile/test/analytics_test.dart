import 'package:flutter_test/flutter_test.dart';
import 'package:applitrack/models/job_application.dart';
import 'package:applitrack/core/constants/enums.dart';

// Pure analytics logic extracted for testing — mirrors providers/analytics_provider.dart
Map<String, double> computeRates(List<JobApplication> apps) {
  final applied =
      apps.where((a) => a.status != ApplicationStatus.wishlist).length;
  final anyResponse = apps.where((a) {
    return a.status.pipelineOrder >=
        ApplicationStatus.phoneScreen.pipelineOrder;
  }).length;
  final offers = apps
          .where((a) => a.status == ApplicationStatus.offerReceived)
          .length +
      apps.where((a) => a.status == ApplicationStatus.accepted).length;

  return {
    'responseRate': applied == 0 ? 0 : anyResponse / applied,
    'offerRate': applied == 0 ? 0 : offers / applied,
  };
}

JobApplication _makeApp(String id, ApplicationStatus status) {
  final now = DateTime(2025, 1, 1);
  return JobApplication(
    id: id,
    company: 'C$id',
    role: 'Dev',
    status: status,
    workType: WorkType.remote,
    source: JobSource.linkedin,
    priority: 3,
    tags: const [],
    salaryCurrency: 'INR',
    coverLetterUsed: false,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('Analytics rate calculations', () {
    test('empty list gives 0 rates', () {
      final rates = computeRates([]);
      expect(rates['responseRate'], 0.0);
      expect(rates['offerRate'], 0.0);
    });

    test('only wishlist apps give 0 rates', () {
      final apps = [
        _makeApp('1', ApplicationStatus.wishlist),
        _makeApp('2', ApplicationStatus.wishlist),
      ];
      final rates = computeRates(apps);
      expect(rates['responseRate'], 0.0);
      expect(rates['offerRate'], 0.0);
    });

    test('100% response rate when all applied apps have responses', () {
      final apps = [
        _makeApp('1', ApplicationStatus.phoneScreen),
        _makeApp('2', ApplicationStatus.technicalRound),
      ];
      final rates = computeRates(apps);
      expect(rates['responseRate'], 1.0);
    });

    test('50% response rate when half have responses', () {
      final apps = [
        _makeApp('1', ApplicationStatus.applied),
        _makeApp('2', ApplicationStatus.phoneScreen),
      ];
      final rates = computeRates(apps);
      expect(rates['responseRate'], 0.5);
    });

    test('offer rate counts both offerReceived and accepted', () {
      final apps = [
        _makeApp('1', ApplicationStatus.applied),
        _makeApp('2', ApplicationStatus.offerReceived),
        _makeApp('3', ApplicationStatus.accepted),
        _makeApp('4', ApplicationStatus.rejected),
      ];
      final rates = computeRates(apps);
      // 4 applied (none wishlist), 2 offers → 50%
      expect(rates['offerRate'], 0.5);
    });

    test('wishlist apps are excluded from denominator', () {
      final apps = [
        _makeApp('1', ApplicationStatus.wishlist),
        _makeApp('2', ApplicationStatus.applied),
        _makeApp('3', ApplicationStatus.phoneScreen),
      ];
      final rates = computeRates(apps);
      // applied = 2 (not wishlist), responses = 1 (phoneScreen) → 50%
      expect(rates['responseRate'], 0.5);
    });
  });

  group('Status grouping', () {
    test('byStatus counts correctly', () {
      final apps = [
        _makeApp('1', ApplicationStatus.applied),
        _makeApp('2', ApplicationStatus.applied),
        _makeApp('3', ApplicationStatus.offerReceived),
        _makeApp('4', ApplicationStatus.rejected),
      ];
      final byStatus = <ApplicationStatus, int>{};
      for (final s in ApplicationStatus.values) {
        byStatus[s] = apps.where((a) => a.status == s).length;
      }
      expect(byStatus[ApplicationStatus.applied], 2);
      expect(byStatus[ApplicationStatus.offerReceived], 1);
      expect(byStatus[ApplicationStatus.rejected], 1);
      expect(byStatus[ApplicationStatus.wishlist], 0);
    });
  });

  group('Applications over time', () {
    test('groups apps by creation day', () {
      final d1 = DateTime(2025, 1, 1);
      final d2 = DateTime(2025, 1, 2);
      JobApplication makeApp(String id, DateTime date) => JobApplication(
            id: id,
            company: 'C',
            role: 'R',
            status: ApplicationStatus.applied,
            workType: WorkType.remote,
            source: JobSource.other,
            priority: 3,
            tags: const [],
            salaryCurrency: 'INR',
            coverLetterUsed: false,
            createdAt: date,
            updatedAt: date,
          );

      final apps = [
        makeApp('a', d1),
        makeApp('b', d1),
        makeApp('c', d2),
      ];

      final map = <DateTime, int>{};
      for (final a in apps) {
        final day = DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day);
        map[day] = (map[day] ?? 0) + 1;
      }
      expect(map[d1], 2);
      expect(map[d2], 1);
    });
  });
}
