import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/applications_provider.dart';
import '../../providers/notification_capture_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sync_provider.dart';
import 'package:flutter/services.dart';
import '../../services/notification_capture_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      body: auth.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) => user == null ? const _SignedOutView() : _SignedInView(user: user),
      ),
    );
  }
}

// ─────────────────────── Signed-out view ────────────────────────

class _SignedOutView extends ConsumerWidget {
  const _SignedOutView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final sync = ref.watch(syncNotifierProvider);
    final isBusy = sync.status == SyncStatus.syncing;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 0,
          title: const Text('Profile'),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primaryContainer,
                  ),
                  child: Icon(Icons.person_outline,
                      size: 52, color: cs.primary),
                ).animate().scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 400.ms,
                    curve: Curves.elasticOut),
                const SizedBox(height: 28),
                Text(
                  'Sign in to AppliTrack',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 12),
                Text(
                  'Back up your applications, sync across devices, and keep your job search safe in the cloud.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      height: 1.5,
                      fontSize: 14),
                ).animate().fadeIn(delay: 180.ms),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isBusy
                        ? null
                        : () => ref.read(syncNotifierProvider.notifier).signIn(),
                    icon: isBusy
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.onPrimary))
                        : const Icon(Icons.login_rounded),
                    label: Text(isBusy ? 'Signing in…' : 'Sign in with Google'),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.15, end: 0),
                if (sync.message != null && sync.status == SyncStatus.error) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 16, color: cs.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(sync.message!,
                              style: TextStyle(color: cs.error, fontSize: 13)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14,
                        color: cs.onSurface.withValues(alpha: 0.35)),
                    const SizedBox(width: 6),
                    Text(
                      'Data stored privately under your Google account',
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.4)),
                    ),
                  ],
                ).animate().fadeIn(delay: 350.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────── Signed-in view ─────────────────────────

class _SignedInView extends ConsumerWidget {
  final User user;
  const _SignedInView({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sync = ref.watch(syncNotifierProvider);
    final totalApps = ref.watch(applicationsNotifierProvider).length;
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final isBusy = sync.status == SyncStatus.syncing;

    return CustomScrollView(
      slivers: [
        // ── Collapsing header ──
        SliverAppBar(
          pinned: true,
          expandedHeight: 240,
          backgroundColor: isDark ? cs.surfaceContainerHighest : cs.primary,
          foregroundColor: isDark ? cs.onSurface : Colors.white,
          title: Text(
            'Profile',
            style: TextStyle(
              color: isDark ? cs.onSurface : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: _ProfileHeader(user: user, isDark: isDark),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Stats row ──
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.work_outline,
                      label: 'Applications',
                      value: '$totalApps',
                      color: cs.primary,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.cloud_done_outlined,
                      label: 'Sync Status',
                      value: _syncLabel(sync.status),
                      color: _syncColor(sync.status, cs),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 8),

                // ── Status message ──
                if (sync.message != null)
                  _StatusBanner(sync: sync).animate().fadeIn(),

                const SizedBox(height: 24),

                // ── Cloud Sync section ──
                _SectionLabel('Cloud Sync'),
                const SizedBox(height: 10),
                _ActionTile(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Back Up to Cloud',
                  subtitle: 'Upload all local data to Firestore',
                  iconColor: cs.primary,
                  loading: isBusy,
                  onTap: () => ref.read(syncNotifierProvider.notifier).push(),
                ).animate().fadeIn(delay: 60.ms),
                const SizedBox(height: 8),
                _ActionTile(
                  icon: Icons.cloud_download_outlined,
                  title: 'Restore from Cloud',
                  subtitle: 'Download and merge cloud data',
                  iconColor: const Color(0xFF8B5CF6),
                  loading: isBusy,
                  onTap: () => _confirmRestore(context, ref),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 24),

                // ── Notification Sync section ──
                _SectionLabel('App Notifications'),
                const SizedBox(height: 10),
                _NotificationSyncCard().animate().fadeIn(delay: 120.ms),

                const SizedBox(height: 24),

                // ── Gmail Sync section ──
                _SectionLabel('Gmail Sync'),
                const SizedBox(height: 10),
                _GmailSyncCard().animate().fadeIn(delay: 140.ms),

                const SizedBox(height: 24),

                // ── Preferences section ──
                _SectionLabel('Preferences'),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          settings.themeModeName == 'dark'
                              ? Icons.dark_mode_outlined
                              : settings.themeModeName == 'light'
                                  ? Icons.light_mode_outlined
                                  : Icons.settings_suggest_outlined,
                          color: cs.primary,
                        ),
                        title: const Text('Theme',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          settings.themeModeName == 'system'
                              ? 'System default'
                              : settings.themeModeName[0].toUpperCase() +
                                settings.themeModeName.substring(1),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showThemePicker(context, settingsNotifier,
                            settings.themeModeName),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Icon(Icons.settings_outlined, color: cs.primary),
                        title: const Text('Settings',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Notifications, data & more'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 140.ms),

                const SizedBox(height: 24),

                // ── Account section ──
                _SectionLabel('Account'),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.logout_rounded,
                          color: cs.error, size: 20),
                    ),
                    title: Text('Sign Out',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: cs.error)),
                    subtitle: Text(user.email ?? '',
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.5))),
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                ).animate().fadeIn(delay: 180.ms),

                const SizedBox(height: 16),

                // ── App info ──
                Center(
                  child: Text(
                    'AppliTrack v1.0.0',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.35)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _confirmRestore(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from Cloud?'),
        content: const Text(
            'Cloud data will be merged into this device. Existing local entries are kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(syncNotifierProvider.notifier).pull();
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'Your local data stays on this device. Sign in again anytime to sync.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(syncNotifierProvider.notifier).signOut();
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showThemePicker(
      BuildContext context, SettingsNotifier notifier, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  )),
            ),
            const SizedBox(height: 16),
            const Text('Choose Theme',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            ...['system', 'light', 'dark'].map((mode) => ListTile(
                  title: Text(mode == 'system'
                      ? 'System default'
                      : mode[0].toUpperCase() + mode.substring(1)),
                  leading: Icon(mode == 'system'
                      ? Icons.settings_suggest_outlined
                      : mode == 'light'
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined),
                  trailing: current == mode
                      ? Icon(Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    notifier.setThemeMode(mode);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _syncLabel(SyncStatus s) => switch (s) {
        SyncStatus.idle => 'Not synced',
        SyncStatus.syncing => 'Syncing…',
        SyncStatus.success => 'Up to date',
        SyncStatus.error => 'Error',
      };

  Color _syncColor(SyncStatus s, ColorScheme cs) => switch (s) {
        SyncStatus.idle => cs.onSurface.withValues(alpha: 0.45),
        SyncStatus.syncing => const Color(0xFF3B82F6),
        SyncStatus.success => const Color(0xFF22C55E),
        SyncStatus.error => cs.error,
      };
}

// ─────────────────────── Sub-widgets ─────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final User user;
  final bool isDark;
  const _ProfileHeader({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [cs.surfaceContainerHighest, cs.surface]
              : [cs.primary, cs.primaryContainer],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // Avatar with ring
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? cs.primaryContainer
                    : Colors.white.withValues(alpha: 0.3),
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: cs.primaryContainer,
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user.photoURL == null
                    ? Text(
                        (user.displayName ?? user.email ?? '?')[0]
                            .toUpperCase(),
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: cs.primary),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.displayName ?? 'Google User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? cs.onSurface : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email ?? '',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? cs.onSurface.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? cs.primaryContainer
                    : Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 13,
                      color: isDark ? cs.primary : Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    'Google Account',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? cs.primary : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: color)),
                    Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.55))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final SyncState sync;
  const _StatusBanner({required this.sync});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isError = sync.status == SyncStatus.error;
    final isSuccess = sync.status == SyncStatus.success;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isError
            ? cs.errorContainer
            : isSuccess
                ? cs.primaryContainer
                : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline
                : isSuccess
                    ? Icons.check_circle_outline
                    : Icons.sync,
            size: 17,
            color: isError
                ? cs.error
                : isSuccess
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sync.message!,
              style: TextStyle(
                  fontSize: 13,
                  color: isError ? cs.error : cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _NotificationSyncCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NotificationSyncCard> createState() =>
      _NotificationSyncCardState();
}

class _NotificationSyncCardState extends ConsumerState<_NotificationSyncCard>
    with WidgetsBindingObserver {
  static const _settingsChannel = MethodChannel('applitrack/settings');
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await NotificationCaptureService.hasPermission();
    if (mounted) setState(() => _hasPermission = granted);
  }

  Future<void> _openNotificationSettings() async {
    try {
      await _settingsChannel.invokeMethod('openNotificationListenerSettings');
    } catch (_) {
      if (mounted) _showManualInstructions();
    }
  }

  void _showManualInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enable Notification Access'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To capture job updates automatically, enable notification access for AppliTrack:'),
            SizedBox(height: 12),
            _InstructionStep(step: '1', text: 'Open Android Settings'),
            _InstructionStep(step: '2', text: 'Apps → Special app access'),
            _InstructionStep(step: '3', text: 'Notification access'),
            _InstructionStep(step: '4', text: 'Enable AppliTrack'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pending = ref.watch(pendingNotificationCountProvider);

    return Card(
      child: Column(
        children: [
          // Permission tile
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _hasPermission
                    ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                    : cs.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _hasPermission
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_outlined,
                color: _hasPermission
                    ? const Color(0xFF22C55E)
                    : cs.error,
                size: 20,
              ),
            ),
            title: Text(
              _hasPermission ? 'Notification Access' : 'Grant Notification Access',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _hasPermission
                  ? 'Capturing job updates from Naukri, LinkedIn & more'
                  : 'Required to auto-capture Naukri, LinkedIn updates',
              style: TextStyle(fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.55)),
            ),
            trailing: _hasPermission
                ? Icon(Icons.check_circle_rounded,
                    color: const Color(0xFF22C55E), size: 20)
                : FilledButton.tonal(
                    onPressed: _openNotificationSettings,
                    child: const Text('Allow'),
                  ),
          ),
          if (_hasPermission) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            // Pending updates tile
            ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: pending > 0
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.inbox_rounded,
                        color: pending > 0 ? cs.primary : cs.onSurface.withValues(alpha: 0.4),
                        size: 20),
                    if (pending > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: cs.error,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              pending > 9 ? '9+' : '$pending',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onError),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              title: Text(
                pending > 0
                    ? '$pending pending update${pending == 1 ? '' : 's'}'
                    : 'No pending updates',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                pending > 0
                    ? 'Tap to review and import into your applications'
                    : 'New job notifications will appear here',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.55)),
              ),
              trailing: pending > 0
                  ? const Icon(Icons.chevron_right)
                  : null,
              onTap: pending > 0
                  ? () => context.push('/notifications/import')
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _GmailSyncCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEA4335).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.mark_email_unread_outlined,
              color: Color(0xFFEA4335), size: 20),
        ),
        title: const Text('Sync Gmail Emails',
            style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Import job updates from Naukri, LinkedIn & HR emails',
          style: TextStyle(
              fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/gmail/sync'),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String step;
  final String text;
  const _InstructionStep({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(step,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cs.primary)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final bool loading;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: loading
                    ? Padding(
                        padding: const EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: iconColor))
                    : Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
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
