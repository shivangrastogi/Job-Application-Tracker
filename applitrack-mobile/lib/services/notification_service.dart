import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final _plugin = FlutterLocalNotificationsPlugin();

const _channelInterview = 'applitrack_interviews';
const _channelFollowUp = 'applitrack_followup';
const _channelGeneral = 'applitrack_general';
const _channelJobs = 'applitrack_jobs';
const _channelGoals = 'applitrack_goals';

class NotificationService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    await _createChannels();
  }

  static Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(const AndroidNotificationChannel(
      _channelInterview,
      'Interview Reminders',
      description: 'Reminders for upcoming interviews',
      importance: Importance.high,
      enableVibration: true,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      _channelFollowUp,
      'Follow-up Nudges',
      description: 'Reminders to follow up on stale applications',
      importance: Importance.defaultImportance,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      _channelGeneral,
      'General',
      description: 'General AppliTrack notifications',
      importance: Importance.low,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      _channelJobs,
      'New Job Alerts',
      description: 'New openings at the companies you track',
      importance: Importance.defaultImportance,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      _channelGoals,
      'Goal Reminders',
      description: 'Daily nudges to hit your application goals',
      importance: Importance.defaultImportance,
    ));
  }

  static Future<void> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  static Future<void> scheduleInterviewReminders({
    required String interviewId,
    required String applicationTitle,
    required String interviewType,
    required DateTime scheduledAt,
  }) async {
    await cancelInterviewReminders(interviewId);

    final idBase = interviewId.hashCode.abs() % 100000;

    final oneHourBefore = scheduledAt.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: idBase,
        title: 'Interview in 1 hour',
        body: '$interviewType · $applicationTitle',
        scheduledAt: oneHourBefore,
        channelId: _channelInterview,
        highPriority: true,
      );
    }

    final oneDayBefore = scheduledAt.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: idBase + 1,
        title: 'Interview tomorrow',
        body: '$interviewType · $applicationTitle',
        scheduledAt: oneDayBefore,
        channelId: _channelInterview,
        highPriority: true,
      );
    }
  }

  static Future<void> cancelInterviewReminders(String interviewId) async {
    final idBase = interviewId.hashCode.abs() % 100000;
    await _plugin.cancel(idBase);
    await _plugin.cancel(idBase + 1);
  }

  static Future<void> scheduleFollowUpNudge({
    required String applicationId,
    required String company,
    required String role,
    required DateTime nudgeAt,
  }) async {
    if (nudgeAt.isBefore(DateTime.now())) return;
    await _scheduleNotification(
      id: 200000 + (applicationId.hashCode.abs() % 100000),
      title: 'Follow up with $company?',
      body: '$role · No update in a while',
      scheduledAt: nudgeAt,
      channelId: _channelFollowUp,
      highPriority: false,
    );
  }

  static Future<void> cancelFollowUpNudge(String applicationId) async {
    await _plugin.cancel(200000 + (applicationId.hashCode.abs() % 100000));
  }

  static Future<void> showImmediate({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelGeneral,
          'General',
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
    );
  }

  /// Immediate alert when new jobs appear at a tracked company.
  static Future<void> showNewJobs({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      300000 + (id % 50000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelJobs,
          'New Job Alerts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  /// A repeating daily reminder to log applications toward your goals.
  static Future<void> scheduleDailyGoalReminder({
    int hour = 20,
    int minute = 0,
    String body = 'Keep the streak alive — log your applications for today.',
  }) async {
    const id = 400001;
    await _plugin.cancel(id);
    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (first.isBefore(now)) first = first.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id,
      'Your daily goal',
      body,
      first,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelGoals,
          'Goal Reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDailyGoalReminder() => _plugin.cancel(400001);

  static Future<void> cancelAll() async => _plugin.cancelAll();

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required String channelId,
    required bool highPriority,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledAt, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == _channelInterview
              ? 'Interview Reminders'
              : 'Follow-up Nudges',
          importance:
              highPriority ? Importance.high : Importance.defaultImportance,
          priority: highPriority ? Priority.high : Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
