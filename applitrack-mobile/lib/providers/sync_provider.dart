import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
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
    await FirebaseService.signOut();
    state = const SyncState();
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
