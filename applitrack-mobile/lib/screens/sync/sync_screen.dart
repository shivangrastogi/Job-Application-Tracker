import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sync_provider.dart';
import '../../providers/applications_provider.dart';

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final sync = ref.watch(syncNotifierProvider);
    final totalApps = ref.watch(applicationsNotifierProvider).length;
    final isSyncing = sync.status == SyncStatus.syncing;

    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Sync')),
      body: auth.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) => user == null
            ? _SignedOutView(isSyncing: isSyncing)
            : _SignedInView(
                user: user,
                sync: sync,
                totalApps: totalApps,
                isSyncing: isSyncing,
              ),
      ),
    );
  }
}

// ─────────────────────── Signed-out view ────────────────────────

class _SignedOutView extends ConsumerWidget {
  final bool isSyncing;
  const _SignedOutView({required this.isSyncing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_outlined,
                    size: 80, color: cs.onSurface.withValues(alpha: 0.2))
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),
            Text('Sync across devices',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(
              'Sign in with Google to back up your applications and access them on any device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6), height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSyncing
                    ? null
                    : () => ref.read(syncNotifierProvider.notifier).signIn(),
                icon: isSyncing
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.login),
                label: Text(isSyncing ? 'Signing in…' : 'Sign in with Google'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your data is stored securely in Firestore and\nonly accessible by your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.4)),
            ),
          ].animate(interval: 60.ms).fadeIn(duration: 300.ms),
        ),
      ),
    );
  }
}

// ─────────────────────── Signed-in view ─────────────────────────

class _SignedInView extends ConsumerWidget {
  final dynamic user;
  final SyncState sync;
  final int totalApps;
  final bool isSyncing;

  const _SignedInView({
    required this.user,
    required this.sync,
    required this.totalApps,
    required this.isSyncing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Account card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(
                          (user.displayName ?? user.email ?? '?')[0]
                              .toUpperCase(),
                          style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName ?? 'Google User',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(user.email ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: isSyncing
                      ? null
                      : () => ref.read(syncNotifierProvider.notifier).signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 20),

        // Stats
        Row(
          children: [
            _StatTile(label: 'Local applications', value: '$totalApps'),
            const SizedBox(width: 12),
            _StatTile(
              label: 'Sync status',
              value: _statusLabel(sync.status),
              color: _statusColor(sync.status, cs),
            ),
          ],
        ).animate(delay: 60.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: 24),

        // Status message
        if (sync.message != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: sync.status == SyncStatus.error
                  ? cs.errorContainer
                  : sync.status == SyncStatus.success
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  sync.status == SyncStatus.error
                      ? Icons.error_outline
                      : sync.status == SyncStatus.syncing
                          ? Icons.sync
                          : Icons.check_circle_outline,
                  size: 18,
                  color: sync.status == SyncStatus.error
                      ? cs.error
                      : sync.status == SyncStatus.success
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(sync.message!,
                      style: TextStyle(
                          fontSize: 13,
                          color: sync.status == SyncStatus.error
                              ? cs.error
                              : cs.onSurface)),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 200.ms),

        if (sync.message != null) const SizedBox(height: 20),

        // Action buttons
        _ActionCard(
          icon: Icons.cloud_upload_outlined,
          title: 'Back up to Cloud',
          subtitle: 'Upload all local data to Firestore',
          color: cs.primary,
          loading: isSyncing,
          onTap: () => ref.read(syncNotifierProvider.notifier).push(),
        ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: 12),

        _ActionCard(
          icon: Icons.cloud_download_outlined,
          title: 'Restore from Cloud',
          subtitle: 'Download cloud data to this device',
          color: const Color(0xFF8B5CF6),
          loading: isSyncing,
          onTap: () => _confirmRestore(context, ref),
        ).animate(delay: 120.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: 28),

        // Info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How sync works',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.8))),
              const SizedBox(height: 8),
              ...[
                'Back up uploads all applications, interviews, contacts and timeline events to your private Firestore.',
                'Restore downloads cloud data and merges it with what\'s on this device.',
                'Data is stored under your UID — no other user can access it.',
              ].map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ',
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.5))),
                        Expanded(
                          child: Text(t,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.55),
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ).animate(delay: 160.ms).fadeIn(duration: 300.ms),
      ],
    );
  }

  void _confirmRestore(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore from Cloud?'),
        content: const Text(
            'Cloud data will be merged into this device. Existing local entries are kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(syncNotifierProvider.notifier).pull();
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  String _statusLabel(SyncStatus s) {
    return switch (s) {
      SyncStatus.idle => 'Not synced',
      SyncStatus.syncing => 'Syncing…',
      SyncStatus.success => 'Up to date',
      SyncStatus.error => 'Error',
    };
  }

  Color _statusColor(SyncStatus s, ColorScheme cs) {
    return switch (s) {
      SyncStatus.idle => cs.onSurface.withValues(alpha: 0.4),
      SyncStatus.syncing => const Color(0xFF3B82F6),
      SyncStatus.success => const Color(0xFF22C55E),
      SyncStatus.error => cs.error,
    };
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatTile({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color ?? cs.onSurface)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.55))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: loading
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: color))
                    : Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.55))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: cs.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
