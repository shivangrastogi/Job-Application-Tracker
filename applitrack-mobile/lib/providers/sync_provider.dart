import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../services/cloud_sync_service.dart';
import 'applications_provider.dart';

// ── Auth state stream ──────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>(
  (_) => FirebaseService.authStateChanges,
);

// ── Sync state ─────────────────────────────────────────────────────
enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final String? message;
  const SyncState({this.status = SyncStatus.idle, this.message});
}

class SyncNotifier extends StateNotifier<SyncState> {
  final Ref _ref;
  SyncNotifier(this._ref) : super(const SyncState());

  Future<void> signIn() async {
    state = const SyncState(status: SyncStatus.syncing, message: 'Signing in…');
    final result = await FirebaseService.signInWithGoogle();
    if (result == null) {
      state = const SyncState(
          status: SyncStatus.error, message: 'Sign-in cancelled');
    } else {
      state = const SyncState(
          status: SyncStatus.success, message: 'Signed in');
    }
  }

  Future<void> signOut() async {
    state = const SyncState(
        status: SyncStatus.syncing, message: 'Backing up to cloud…');
    // Back up local data to Firestore BEFORE it gets cleared on sign-out, so
    // nothing that hasn't synced yet is lost. If the backup fails (blocked by
    // security rules, offline, …) keep the local copy on this device instead
    // of wiping it.
    final result = await FirebaseService.pushAll();
    await CloudSyncService.stop(clearLocal: result.ok);
    await FirebaseService.signOut();
    state = result.ok
        ? const SyncState()
        : const SyncState(
            status: SyncStatus.error,
            message:
                'Signed out, but cloud backup failed — your data is kept on this device.');
  }

  Future<void> push() async {
    state = const SyncState(
        status: SyncStatus.syncing, message: 'Uploading to cloud…');
    final result = await FirebaseService.pushAll();
    state = SyncState(
        status: result.ok ? SyncStatus.success : SyncStatus.error,
        message: result.message);
  }

  Future<void> pull() async {
    state = const SyncState(
        status: SyncStatus.syncing, message: 'Downloading from cloud…');
    final result = await FirebaseService.pullAll();
    if (result.ok) {
      // Reload local provider state from Hive so UI reflects pulled data
      _ref.invalidate(applicationsNotifierProvider);
    }
    state = SyncState(
        status: result.ok ? SyncStatus.success : SyncStatus.error,
        message: result.message);
  }
}

final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) => SyncNotifier(ref));
