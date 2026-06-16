import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/crypto_service.dart';

/// Gate state for the router: `ready` = no encryption or unlocked; `locked` =
/// encryption is on but this device needs the passphrase.
enum CryptoGateStatus { unknown, ready, locked }

class CryptoNotifier extends StateNotifier<CryptoGateStatus> {
  CryptoNotifier() : super(CryptoGateStatus.unknown);

  /// Recompute from CryptoService after sign-in / sync / unlock.
  void refresh() {
    state = (CryptoService.isEnabled && !CryptoService.isUnlocked)
        ? CryptoGateStatus.locked
        : CryptoGateStatus.ready;
  }

  Future<bool> unlock(String passphrase) async {
    final ok = await CryptoService.unlock(passphrase);
    if (ok) state = CryptoGateStatus.ready;
    return ok;
  }

  Future<void> lock() async {
    await CryptoService.lock();
    state = CryptoGateStatus.locked;
  }
}

final cryptoProvider =
    StateNotifierProvider<CryptoNotifier, CryptoGateStatus>(
        (ref) => CryptoNotifier());
