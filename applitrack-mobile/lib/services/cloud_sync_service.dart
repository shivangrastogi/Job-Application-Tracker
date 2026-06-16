import 'dart:async';
import 'package:flutter/foundation.dart';
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

  /// Last cloud-write failure (e.g. permission denied), exposed as a listenable
  /// so the UI can show a banner. Null when sync is healthy / dismissed.
  static final ValueNotifier<String?> syncError = ValueNotifier<String?>(null);

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
        final op = event.deleted
            ? FirebaseService.deleteDoc(collection, id)
            : (event.value is Map
                ? FirebaseService.upsert(collection, id,
                    Map<String, dynamic>.from(event.value as Map))
                : Future<void>.value());
        // Don't let a failed cloud write vanish silently — surface it so a
        // rules/permissions problem is diagnosable instead of looking like
        // data that "didn't save".
        op.then((_) {
          if (syncError.value != null) syncError.value = null; // recovered
        }).catchError((Object e) {
          final permission = e.toString().toLowerCase().contains('permission');
          syncError.value = permission
              ? "Cloud sync blocked — check your Firestore security rules. Recent changes are saved on this device but aren't backed up."
              : 'Cloud sync failed: $e';
          debugPrint('[AppliTrack] cloud sync failed for $collection/$id: $e');
        });
      }));
    }
  }

  static Future<void> stop({bool clearLocal = true}) async {
    // Already stopped — ignore. (The auth listener fires stop() on sign-out too,
    // after signOut() has already stopped with its own clearLocal decision; this
    // guard stops that second call from wiping data we chose to preserve.)
    if (!_running && _subs.isEmpty) return;
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
