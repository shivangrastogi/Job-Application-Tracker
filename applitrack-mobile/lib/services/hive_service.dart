import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const _applications = 'applications';
  static const _interviews = 'interviews';
  static const _contacts = 'contacts';
  static const _timeline = 'timeline';
  static const _documents = 'documents';
  static const _settings = 'settings';
  static const _notifications = 'notification_events';
  static const _companies = 'companies';
  static const _goals = 'goals';
  static const _seenJobs = 'company_seen_jobs';
  static const _referralSources = 'referral_sources';
  static const _referrals = 'referrals';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(_applications),
      Hive.openBox<Map>(_interviews),
      Hive.openBox<Map>(_contacts),
      Hive.openBox<Map>(_timeline),
      Hive.openBox<Map>(_documents),
      Hive.openBox<dynamic>(_settings),
      Hive.openBox<Map>(_notifications),
      Hive.openBox<Map>(_companies),
      Hive.openBox<Map>(_goals),
      Hive.openBox<dynamic>(_seenJobs),
      Hive.openBox<Map>(_referralSources),
      Hive.openBox<Map>(_referrals),
    ]);
  }

  static Box<Map> get applicationsBox => Hive.box<Map>(_applications);
  static Box<Map> get interviewsBox => Hive.box<Map>(_interviews);
  static Box<Map> get contactsBox => Hive.box<Map>(_contacts);
  static Box<Map> get timelineBox => Hive.box<Map>(_timeline);
  static Box<Map> get documentsBox => Hive.box<Map>(_documents);
  static Box<dynamic> get settingsBox => Hive.box<dynamic>(_settings);
  static Box<Map> get notificationsBox => Hive.box<Map>(_notifications);
  static Box<Map> get companiesBox => Hive.box<Map>(_companies);
  static Box<Map> get goalsBox => Hive.box<Map>(_goals);
  static Box<dynamic> get seenJobsBox => Hive.box<dynamic>(_seenJobs);
  static Box<Map> get referralSourcesBox => Hive.box<Map>(_referralSources);
  static Box<Map> get referralsBox => Hive.box<Map>(_referrals);
}
