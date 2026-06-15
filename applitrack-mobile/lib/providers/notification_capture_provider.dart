import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/captured_notification.dart';
import '../services/notification_capture_service.dart';

final capturedNotificationsProvider =
    StateNotifierProvider<CapturedNotificationsNotifier,
        List<CapturedNotification>>(
  (_) => CapturedNotificationsNotifier(),
);

class CapturedNotificationsNotifier
    extends StateNotifier<List<CapturedNotification>> {
  CapturedNotificationsNotifier()
      : super(NotificationCaptureService.getPending());

  void refresh() {
    state = NotificationCaptureService.getPending();
  }

  Future<void> delete(String id) async {
    await NotificationCaptureService.delete(id);
    state = state.where((n) => n.id != id).toList();
  }

  Future<void> markImported(String id) async {
    await NotificationCaptureService.markImported(id);
    state = state.where((n) => n.id != id).toList();
  }

  Future<void> clearAll() async {
    await NotificationCaptureService.clearImported();
    refresh();
  }
}

// Pending (unimported) count — used for badge on Profile tab
final pendingNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(capturedNotificationsProvider).length;
});
