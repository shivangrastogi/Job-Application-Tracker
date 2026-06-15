import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:uuid/uuid.dart';
import '../models/captured_notification.dart';
import '../services/hive_service.dart';
import 'notification_parser.dart';

class NotificationCaptureService {
  static const _uuid = Uuid();

  static Future<bool> hasPermission() async {
    return await NotificationListenerService.isPermissionGranted();
  }

  static Future<void> requestPermission() async {
    try {
      await NotificationListenerService.requestPermission();
    } catch (_) {}
  }

  static Future<void> startListening() async {
    final granted = await hasPermission();
    if (!granted) return;

    // Stream starts automatically when listened to; no startService() needed
    NotificationListenerService.notificationsStream.listen((event) {
      _onNotification(event);
    });
  }

  static void _onNotification(ServiceNotificationEvent event) {
    // Skip removed/dismissed notifications
    if (event.hasRemoved == true) return;

    final pkg = event.packageName ?? '';
    if (!NotificationParser.isJobApp(pkg)) return;

    final n = CapturedNotification(
      id: _uuid.v4(),
      packageName: pkg,
      appName: NotificationParser.appNameFor(pkg) ?? pkg,
      title: event.title,
      body: event.content,
      receivedAt: DateTime.now(),
      imported: false,
    );

    final parsed = NotificationParser.parse(n);
    if (!parsed.isJobRelated) return;

    // Deduplicate: skip if same title+body received within last 60 seconds
    final box = HiveService.notificationsBox;
    final recent = box.values
        .map((m) =>
            CapturedNotification.fromJson(Map<String, dynamic>.from(m)))
        .where((c) =>
            c.title == n.title &&
            c.body == n.body &&
            DateTime.now().difference(c.receivedAt).inSeconds < 60);
    if (recent.isNotEmpty) return;

    box.put(n.id, n.toJson());
  }

  // ── Read / manage stored notifications ────────────────────────

  static List<CapturedNotification> getAll() {
    return HiveService.notificationsBox.values
        .map((m) => CapturedNotification.fromJson(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
  }

  static List<CapturedNotification> getPending() =>
      getAll().where((n) => !n.imported).toList();

  static Future<void> markImported(String id) async {
    final box = HiveService.notificationsBox;
    final raw = box.get(id);
    if (raw == null) return;
    final n = CapturedNotification.fromJson(Map<String, dynamic>.from(raw))
        .copyWith(imported: true);
    await box.put(id, n.toJson());
  }

  static Future<void> delete(String id) async {
    await HiveService.notificationsBox.delete(id);
  }

  static Future<void> clearImported() async {
    final box = HiveService.notificationsBox;
    final toDelete = box.keys
        .where((k) {
          final raw = box.get(k);
          if (raw == null) return false;
          final n = CapturedNotification.fromJson(
              Map<String, dynamic>.from(raw));
          return n.imported;
        })
        .toList();
    for (final k in toDelete) {
      await box.delete(k);
    }
  }
}
