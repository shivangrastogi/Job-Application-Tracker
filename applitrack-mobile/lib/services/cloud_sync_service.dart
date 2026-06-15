import 'dart:async';
import 'firebase_service.dart';

/// Keeps local Hive data and the user's Firestore in sync automatically.
///
/// On sign-in it pulls the cloud copy, pushes anything local that wasn't there,
/// then attaches `box.watch()` listeners so every later add/edit/delete is
/// mirrored to Firestore with no extra code in the providers.
///
/// On sign-out it stops mirroring and clears the local boxes, so the next
/// account starts clean (no cross-account data leakage).
class CloudSyncService {
  static final List<StreamSubscription> _subs = [];
  static bool _running = false;

  static bool get isRunning => _running;

  static Future<void> start() async {
    if (_running || !FirebaseService.isSignedIn) return;
    _running = true;

    // 1. Cloud → local (so this device shows the account's data).
    await FirebaseService.pullAll();
    // 2. Local → cloud (uploads anything created before/while offline).
    await FirebaseService.pushAll();

    // 3. Mirror every future change. Attached AFTER the pull so the initial
    //    download doesn't echo straight back up.
    for (final entry in kSyncedBoxes.entries) {
      final collection = entry.key;
      final box = entry.value;
      _subs.add(box.watch().listen((event) {
        if (!FirebaseService.isSignedIn) return;
        final id = event.key.toString();
        if (event.deleted) {
          FirebaseService.deleteDoc(collection, id);
        } else if (event.value is Map) {
          FirebaseService.upsert(
              collection, id, Map<String, dynamic>.from(event.value as Map));
        }
      }));
    }
  }

  static Future<void> stop({bool clearLocal = true}) async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _running = false;
    if (clearLocal) {
      // Watchers are already cancelled, so clearing won't trigger cloud deletes.
      for (final box in kSyncedBoxes.values) {
        await box.clear();
      }
    }
  }
}
