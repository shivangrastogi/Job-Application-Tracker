import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'hive_service.dart';

/// Hive box → Firestore collection map. Every box here is mirrored to the
/// cloud (under users/{uid}/{collection}) on sign-in and on every change.
final Map<String, Box<Map>> kSyncedBoxes = {
  'applications': HiveService.applicationsBox,
  'interviews': HiveService.interviewsBox,
  'contacts': HiveService.contactsBox,
  'timeline': HiveService.timelineBox,
  'companies': HiveService.companiesBox,
  'goals': HiveService.goalsBox,
  'referral_sources': HiveService.referralSourcesBox,
  'referrals': HiveService.referralsBox,
  'documents': HiveService.documentsBox,
  'preferences': HiveService.preferencesBox,
};

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;
  static final _gsi = GoogleSignIn();

  // ──────────────────── Auth ────────────────────

  static User? get currentUser => _auth.currentUser;
  static bool get isSignedIn => _auth.currentUser != null;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static GoogleSignIn get googleSignIn => _gsi;

  static Future<String?> getGmailAccessToken() async {
    try {
      var account = _gsi.currentUser;
      // After requestScopes on Android, currentUser can be stale — re-establish silently
      account ??= await _gsi.signInSilently();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.accessToken;
    } catch (_) {
      return null;
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final account = await _gsi.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (_) {
      return null;
    }
  }

  // Email/password (throws FirebaseAuthException so the UI can show a reason).
  static Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  static Future<UserCredential> signUpWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  static Future<void> signOut() async {
    await _gsi.signOut();
    await _auth.signOut();
  }

  // ──────────────────── Firestore paths ────────────────────

  static CollectionReference<Map<String, dynamic>> _col(String name) {
    final uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).collection(name);
  }

  // ──────────────────── Generic single-doc ops (used by CloudSync) ─────────

  static Future<void> upsert(
      String collection, String id, Map<String, dynamic> data) async {
    if (!isSignedIn) return;
    await _col(collection).doc(id).set(data);
  }

  static Future<void> deleteDoc(String collection, String id) async {
    if (!isSignedIn) return;
    await _col(collection).doc(id).delete();
  }

  // ──────────────────── Upload (local → cloud) ────────────────────

  static Future<SyncResult> pushAll() async {
    if (!isSignedIn) return SyncResult.notSignedIn;
    try {
      var batch = _db.batch();
      var ops = 0;
      Future<void> flush() async {
        if (ops == 0) return;
        await batch.commit();
        batch = _db.batch();
        ops = 0;
      }

      for (final entry in kSyncedBoxes.entries) {
        for (final e in entry.value.toMap().entries) {
          batch.set(_col(entry.key).doc(e.key.toString()),
              Map<String, dynamic>.from(e.value));
          ops++;
          if (ops >= 400) await flush(); // Firestore batch limit is 500
        }
      }
      await flush();
      return SyncResult.success(HiveService.applicationsBox.length);
    } catch (e) {
      return SyncResult.error(e.toString());
    }
  }

  // ──────────────────── Download (cloud → local) ────────────────────

  static Future<SyncResult> pullAll() async {
    if (!isSignedIn) return SyncResult.notSignedIn;
    try {
      for (final entry in kSyncedBoxes.entries) {
        final docs = await _col(entry.key).get();
        for (final doc in docs.docs) {
          await entry.value.put(doc.id, doc.data());
        }
      }
      return SyncResult.success(HiveService.applicationsBox.length);
    } catch (e) {
      return SyncResult.error(e.toString());
    }
  }
}

class SyncResult {
  final bool ok;
  final String message;
  final int count;

  const SyncResult._({required this.ok, required this.message, this.count = 0});

  static const notSignedIn = SyncResult._(ok: false, message: 'Not signed in');
  static SyncResult success(int n) =>
      SyncResult._(ok: true, message: 'Synced $n applications', count: n);
  static SyncResult error(String msg) =>
      SyncResult._(ok: false, message: msg);
}
