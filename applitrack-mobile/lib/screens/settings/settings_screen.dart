import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/enums.dart';
import '../../providers/applications_provider.dart';
import '../../providers/documents_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/crypto_provider.dart';
import '../../services/notification_service.dart';
import '../../services/export_service.dart';
import '../../services/crypto_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    final auth = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Account banner
          auth.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
            data: (user) => user != null
                ? _AccountBanner(user: user)
                : _SignInBanner(),
          ),

          _SectionHeader('Appearance'),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(settings.themeModeName == 'system' ? 'System default' : settings.themeModeName),
            leading: const Icon(Icons.palette_outlined),
            onTap: () => _showThemePicker(context, notifier, settings.themeModeName),
          ),
          const Divider(height: 1, indent: 16),

          _SectionHeader('Notifications'),
          ListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Grant permission to receive reminders'),
            leading: const Icon(Icons.notifications_active_outlined),
            trailing: FilledButton.tonal(
              onPressed: () async {
                await NotificationService.requestPermission();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification permission requested')),
                  );
                }
              },
              child: const Text('Allow'),
            ),
          ),
          SwitchListTile(
            title: const Text('Interview reminders'),
            subtitle: const Text('1 day & 1 hour before each interview'),
            secondary: const Icon(Icons.event_outlined),
            value: settings.notifyInterview,
            onChanged: notifier.toggleNotifyInterview,
          ),
          SwitchListTile(
            title: const Text('Follow-up nudges'),
            subtitle: Text('If no update after ${settings.followUpDays} days'),
            secondary: const Icon(Icons.notifications_outlined),
            value: settings.notifyFollowUp,
            onChanged: notifier.toggleNotifyFollowUp,
          ),
          SwitchListTile(
            title: const Text('Stale application alerts'),
            subtitle: const Text('Applications with no activity'),
            secondary: const Icon(Icons.timer_outlined),
            value: settings.notifyStale,
            onChanged: notifier.toggleNotifyStale,
          ),
          SwitchListTile(
            title: const Text('Weekly digest'),
            subtitle: const Text('Every Sunday morning'),
            secondary: const Icon(Icons.summarize_outlined),
            value: settings.notifyWeekly,
            onChanged: notifier.toggleNotifyWeekly,
          ),
          const Divider(height: 1, indent: 16),

          _SectionHeader('Documents'),
          ListTile(
            title: const Text('Document Vault'),
            subtitle: const Text('Upload & manage resumes and cover letters'),
            leading: const Icon(Icons.folder_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/documents'),
          ),
          Builder(builder: (context) {
            final docs = ref.watch(documentsNotifierProvider);
            final defaultResume = docs
                .where((d) => d.id == settings.defaultResumeId)
                .firstOrNull;
            return ListTile(
              title: const Text('Default Resume'),
              subtitle: Text(
                defaultResume?.name ?? 'Not set — used when adding a job',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: const Icon(Icons.description_outlined),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDefaultResumePicker(context, ref),
            );
          }),
          const Divider(height: 1, indent: 16),

          _SectionHeader('Data'),
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Export as CSV or PDF report'),
            leading: const Icon(Icons.download_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportSheet(context, ref),
          ),
          ListTile(
            title: const Text('Cloud Sync'),
            subtitle: const Text('Back up & sync with Firebase'),
            leading: const Icon(Icons.cloud_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/sync'),
          ),
          Builder(builder: (context) {
            final enabled = CryptoService.isEnabled;
            final unlocked = CryptoService.isUnlocked;
            return ListTile(
              leading: Icon(enabled ? Icons.lock_outline : Icons.lock_open_outlined),
              title: const Text('Encryption'),
              subtitle: Text(!enabled
                  ? 'Off — enable end-to-end encryption from the web app'
                  : unlocked
                      ? 'On · unlocked on this device'
                      : 'On · locked'),
              trailing: enabled && unlocked
                  ? TextButton(
                      onPressed: () async {
                        await ref.read(cryptoProvider.notifier).lock();
                        if (context.mounted) context.go('/unlock');
                      },
                      child: const Text('Lock'),
                    )
                  : null,
            );
          }),
          const Divider(height: 1, indent: 16),

          _SectionHeader('About'),
          ListTile(
            title: const Text('AppliTrack'),
            subtitle: const Text('v1.0.0 — Job Application Tracker'),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }

  void _showDefaultResumePicker(BuildContext context, WidgetRef ref) {
    final resumes = ref
        .read(documentsNotifierProvider)
        .where((d) => d.type == DocumentType.resume)
        .toList();
    final current = ref.read(settingsNotifierProvider).defaultResumeId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Default Resume',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Preselected whenever you add a new job.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5))),
              const SizedBox(height: 8),
              if (resumes.isEmpty)
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: const Text('No resumes uploaded yet'),
                  subtitle: const Text('Add one in the Document Vault'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/documents');
                  },
                )
              else ...[
                ListTile(
                  leading: const Icon(Icons.block_outlined),
                  title: const Text('None'),
                  trailing: current == null ? const Icon(Icons.check) : null,
                  onTap: () {
                    ref
                        .read(settingsNotifierProvider.notifier)
                        .setDefaultResumeId(null);
                    Navigator.pop(ctx);
                  },
                ),
                ...resumes.map((d) => ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(d.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle:
                          d.version != null ? Text('v${d.version}') : null,
                      trailing:
                          current == d.id ? const Icon(Icons.check) : null,
                      onTap: () {
                        ref
                            .read(settingsNotifierProvider.notifier)
                            .setDefaultResumeId(d.id);
                        Navigator.pop(ctx);
                      },
                    )),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportSheet(BuildContext context, WidgetRef ref) {
    final apps = ref.read(applicationsNotifierProvider);
    bool exporting = false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Export Data',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              Text('${apps.length} application${apps.length == 1 ? '' : 's'} will be exported',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: exporting
                          ? null
                          : () async {
                              setState(() => exporting = true);
                              try {
                                await ExportService.exportCsv(apps);
                              } finally {
                                if (ctx.mounted) {
                                  setState(() => exporting = false);
                                  Navigator.pop(ctx);
                                }
                              }
                            },
                      icon: const Icon(Icons.table_chart_outlined),
                      label: const Text('Export CSV'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: exporting
                          ? null
                          : () async {
                              setState(() => exporting = true);
                              try {
                                await ExportService.exportPdf(apps);
                              } finally {
                                if (ctx.mounted) {
                                  setState(() => exporting = false);
                                  Navigator.pop(ctx);
                                }
                              }
                            },
                      icon: exporting
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Export PDF'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, SettingsNotifier notifier, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Theme',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            ...['system', 'light', 'dark'].map((mode) => ListTile(
                  title: Text(mode == 'system' ? 'System default' : mode[0].toUpperCase() + mode.substring(1)),
                  leading: Icon(mode == 'system'
                      ? Icons.settings_suggest_outlined
                      : mode == 'light'
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined),
                  trailing: current == mode ? const Icon(Icons.check) : null,
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
}

class _AccountBanner extends StatelessWidget {
  final dynamic user;
  const _AccountBanner({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Card(
        child: InkWell(
          onTap: () => context.go('/profile'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
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
                              fontSize: 16),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Google User',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        user.email ?? '',
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Manage',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cs.primary)),
                      const SizedBox(width: 3),
                      Icon(Icons.chevron_right, size: 16, color: cs.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_outline_rounded, color: cs.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Not signed in',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('Sign in to sync & back up',
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.55))),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () => context.go('/profile'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
