import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/crypto_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/applications_provider.dart';
import '../../providers/interviews_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/companies_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/referrals_provider.dart';
import '../../providers/documents_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/cloud_sync_service.dart';

/// Shown when the account is encrypted but this device is locked.
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _ctrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_ctrl.text.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await ref.read(cryptoProvider.notifier).unlock(_ctrl.text);
    if (!ok) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Wrong passphrase.';
        });
      }
      return;
    }
    // Now that the key is available, pull & decrypt and refresh providers.
    await CloudSyncService.start();
    for (final p in [
      applicationsNotifierProvider,
      interviewsNotifierProvider,
      contactsNotifierProvider,
      companiesNotifierProvider,
      goalsNotifierProvider,
      referralsNotifierProvider,
      referralSourcesNotifierProvider,
      documentsNotifierProvider,
      settingsNotifierProvider,
    ]) {
      ref.invalidate(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: cs.primary),
              const SizedBox(height: 16),
              Text('Unlock your data',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Your data is end-to-end encrypted. Enter your passphrase to '
                'decrypt it on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ctrl,
                obscureText: true,
                autofocus: true,
                onSubmitted: (_) => _unlock(),
                decoration: const InputDecoration(
                  labelText: 'Encryption passphrase',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(color: Color(0xFFEF4444))),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _busy ? null : _unlock,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Unlock'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(syncNotifierProvider.notifier).signOut(),
                child: const Text('Sign out'),
              ),
              Text(
                'There is no recovery — a forgotten passphrase means the data '
                "can't be read.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
