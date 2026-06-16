import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end encryption — MUST match the web format exactly so both apps can
/// decrypt each other (see applitrack-web/src/lib/crypto.js):
///   key    = PBKDF2-HMAC-SHA256(passphrase, salt, 210000 iters) -> 256-bit
///   cipher = AES-256-GCM, 12-byte nonce, blob = base64(nonce || ct || mac)
///   doc    = { id, _enc: base64(JSON of everything-except-id), _v: 1 }
class AppCrypto {
  static const int pbkdf2Iterations = 210000;
  static const int cryptoVersion = 1;
  static const String _verifierText = 'applitrack-encryption-ok';
  static final AesGcm _aes = AesGcm.with256bits();

  final SecretKey _key;
  AppCrypto._(this._key);

  static Future<AppCrypto> derive(String passphrase, List<int> salt,
      {int iterations = pbkdf2Iterations}) async {
    final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256);
    final key = await pbkdf2.deriveKey(
        secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);
    return AppCrypto._(key);
  }

  static Future<AppCrypto> fromRawKey(List<int> bytes) async =>
      AppCrypto._(SecretKey(bytes));

  Future<List<int>> rawKeyBytes() => _key.extractBytes();

  Future<String> _encryptString(String plaintext) async {
    final nonce = _aes.newNonce(); // 12 bytes
    final box = await _aes.encrypt(utf8.encode(plaintext),
        secretKey: _key, nonce: nonce);
    return base64.encode(box.concatenation()); // nonce + cipherText + mac
  }

  Future<String> _decryptString(String blob) async {
    final box = SecretBox.fromConcatenation(base64.decode(blob),
        nonceLength: 12, macLength: 16);
    return utf8.decode(await _aes.decrypt(box, secretKey: _key));
  }

  /// Plaintext Firestore map -> encrypted doc (id stays plaintext as the key).
  Future<Map<String, dynamic>> encryptDoc(
      String id, Map<String, dynamic> data) async {
    final rest = Map<String, dynamic>.from(data)..remove('id');
    return {
      'id': id,
      '_enc': await _encryptString(jsonEncode(rest)),
      '_v': cryptoVersion,
    };
  }

  /// Encrypted (or legacy-plaintext) doc -> plaintext map.
  Future<Map<String, dynamic>> decryptDoc(
      String id, Map<String, dynamic> doc) async {
    if (doc['_enc'] == null) {
      return Map<String, dynamic>.from(doc)..['id'] = id; // legacy plaintext
    }
    final rest =
        jsonDecode(await _decryptString(doc['_enc'] as String)) as Map<String, dynamic>;
    return {...rest, 'id': id};
  }

  Future<String> makeVerifier() => _encryptString(_verifierText);
  Future<bool> checkVerifier(String verifier) async {
    try {
      return (await _decryptString(verifier)) == _verifierText;
    } catch (_) {
      return false;
    }
  }
}

/// Holds the unlocked key for the session and the (synced) crypto meta.
/// While encryption is OFF (no meta doc) everything is a pass-through, so
/// existing non-encrypted accounts are completely unaffected.
class CryptoService {
  static AppCrypto? _crypto;
  static Map<String, dynamic>? meta; // { salt, verifier, iterations } or null

  static bool get isEnabled => meta != null;
  static bool get isUnlocked => _crypto != null;

  static DocumentReference<Map<String, dynamic>>? _metaDoc() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('meta')
        .doc('crypto');
  }

  static String _cacheKey(String uid) => 'enc_key_$uid';

  /// Loads the crypto meta and tries the device-cached key. Returns true if
  /// encryption is enabled and now unlocked.
  static Future<void> loadMeta() async {
    _crypto = null;
    meta = null;
    final ref = _metaDoc();
    if (ref == null) return;
    final snap = await ref.get();
    if (!snap.exists) return;
    meta = snap.data();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey(uid));
      if (cached != null) {
        final c = await AppCrypto.fromRawKey(base64.decode(cached));
        if (await c.checkVerifier(meta!['verifier'] as String)) _crypto = c;
      }
    } catch (_) {/* stays locked */}
  }

  static Future<bool> unlock(String passphrase) async {
    final m = meta;
    if (m == null) return false;
    final c = await AppCrypto.derive(
      passphrase,
      base64.decode(m['salt'] as String),
      iterations: (m['iterations'] as num?)?.toInt() ?? AppCrypto.pbkdf2Iterations,
    );
    if (!await c.checkVerifier(m['verifier'] as String)) return false;
    _crypto = c;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey(uid), base64.encode(await c.rawKeyBytes()));
    return true;
  }

  static Future<void> lock() async {
    _crypto = null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey(uid));
    }
  }

  static void clear() {
    _crypto = null;
    meta = null;
  }

  /// Encrypt a map before it goes to Firestore (pass-through when off/locked).
  static Future<Map<String, dynamic>> maybeEncrypt(
      String id, Map<String, dynamic> data) async {
    final c = _crypto;
    if (c == null) return data;
    return c.encryptDoc(id, data);
  }

  /// Decrypt a Firestore map after reading it (pass-through when off/locked).
  static Future<Map<String, dynamic>> maybeDecrypt(
      String id, Map<String, dynamic> doc) async {
    if (doc['_enc'] == null) return doc; // plaintext
    final c = _crypto;
    if (c == null) return doc; // can't decrypt yet — caller should not be pulling
    return c.decryptDoc(id, doc);
  }
}
