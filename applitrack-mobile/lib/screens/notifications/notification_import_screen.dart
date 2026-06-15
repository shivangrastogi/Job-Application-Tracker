import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/enums.dart';
import '../../models/captured_notification.dart';
import '../../models/job_application.dart';
import '../../models/timeline_event.dart';
import '../../providers/applications_provider.dart';
import '../../providers/notification_capture_provider.dart';
import '../../services/notification_parser.dart';

class NotificationImportScreen extends ConsumerStatefulWidget {
  const NotificationImportScreen({super.key});

  @override
  ConsumerState<NotificationImportScreen> createState() =>
      _NotificationImportScreenState();
}

class _NotificationImportScreenState
    extends ConsumerState<NotificationImportScreen> {
  final Set<String> _selected = {};
  final Map<String, String?> _matchedAppId = {};
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(capturedNotificationsProvider.notifier).refresh();
      final notifications = ref.read(capturedNotificationsProvider);
      for (final n in notifications) {
        _selected.add(n.id);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final notifications = ref.watch(capturedNotificationsProvider);
    final apps = ref.watch(applicationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Updates'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selected.length == notifications.length) {
                    _selected.clear();
                  } else {
                    _selected.addAll(notifications.map((n) => n.id));
                  }
                });
              },
              child: Text(
                  _selected.length == notifications.length
                      ? 'Deselect all'
                      : 'Select all'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _EmptyState()
          : Column(
              children: [
                // Info banner
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active_outlined,
                          color: cs.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${notifications.length} job update${notifications.length == 1 ? '' : 's'} captured from your apps. Select which to import.',
                          style: TextStyle(
                              fontSize: 13,
                              color: cs.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                // Notification list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: notifications.length,
                    itemBuilder: (context, i) {
                      final n = notifications[i];
                      final parsed = NotificationParser.parse(n);
                      final isSelected = _selected.contains(n.id);

                      return _NotificationCard(
                        notification: n,
                        parsed: parsed,
                        isSelected: isSelected,
                        matchedAppId: _matchedAppId[n.id],
                        apps: apps,
                        onToggle: (v) => setState(() {
                          if (v) {
                            _selected.add(n.id);
                          } else {
                            _selected.remove(n.id);
                          }
                        }),
                        onMatchApp: (appId) => setState(() {
                          _matchedAppId[n.id] = appId;
                        }),
                        onDelete: () => ref
                            .read(capturedNotificationsProvider.notifier)
                            .delete(n.id),
                      ).animate().fadeIn(delay: (i * 40).ms);
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: notifications.isNotEmpty && _selected.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _importing ? null : () => _importSelected(notifications),
                  icon: _importing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.download_done_rounded),
                  label: Text(_importing
                      ? 'Importing…'
                      : 'Import ${_selected.length} update${_selected.length == 1 ? '' : 's'}'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50)),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _importSelected(List<CapturedNotification> notifications) async {
    setState(() => _importing = true);
    const uuid = Uuid();

    for (final n in notifications.where((n) => _selected.contains(n.id))) {
      final parsed = NotificationParser.parse(n);
      final matchedId = _matchedAppId[n.id];

      if (matchedId != null) {
        // Add a notification-detected timeline event
        final event = TimelineEvent(
          id: uuid.v4(),
          applicationId: matchedId,
          type: TimelineEventType.notificationDetected,
          description: parsed.description,
          timestamp: n.receivedAt,
          source: parsed.sourceLabel,
          sourceUrl: n.packageName,
        );
        await ref
            .read(applicationsNotifierProvider.notifier)
            .addTimelineEvent(event);

        // Optionally update status
        if (parsed.suggestedStatus != null) {
          final appList = ref.read(applicationsNotifierProvider);
          final idx = appList.indexWhere((a) => a.id == matchedId);
          if (idx != -1) {
            await ref
                .read(applicationsNotifierProvider.notifier)
                .updateStatus(appList[idx], parsed.suggestedStatus!);
          }
        }
      }

      await ref
          .read(capturedNotificationsProvider.notifier)
          .markImported(n.id);
    }

    if (mounted) {
      setState(() => _importing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported ${_selected.length} update${_selected.length == 1 ? '' : 's'}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}

// ─────────────────────── Notification Card ────────────────────────

class _NotificationCard extends StatelessWidget {
  final CapturedNotification notification;
  final NotificationParseResult parsed;
  final bool isSelected;
  final String? matchedAppId;
  final List<JobApplication> apps;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String?> onMatchApp;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.parsed,
    required this.isSelected,
    required this.matchedAppId,
    required this.apps,
    required this.onToggle,
    required this.onMatchApp,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sourceColor = _sourceColor(notification.packageName, cs);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (v) => onToggle(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 4),
                // Source chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sourceColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    parsed.sourceLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sourceColor),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _timeAgo(notification.receivedAt),
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.45)),
                    textAlign: TextAlign.right,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 16,
                      color: cs.onSurface.withValues(alpha: 0.4)),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original notification text
                  if (notification.title != null)
                    Text(notification.title!,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (notification.body != null)
                    Text(
                      notification.body!,
                      style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: 0.7)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // Parsed result
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                size: 13, color: cs.primary),
                            const SizedBox(width: 5),
                            Text('Detected: ',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary)),
                            Expanded(
                              child: Text(
                                parsed.description,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (parsed.suggestedStatus != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.arrow_forward_rounded,
                                  size: 12,
                                  color: cs.onSurface.withValues(alpha: 0.5)),
                              const SizedBox(width: 5),
                              Text('Suggest status: ',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurface.withValues(alpha: 0.6))),
                              Text(
                                parsed.suggestedStatus!.label,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Match to application dropdown
                  DropdownButtonFormField<String>(
                    initialValue: matchedAppId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      hintText: parsed.company != null
                          ? 'Match to app (company: ${parsed.company})'
                          : 'Match to application…',
                      hintStyle: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: 0.45)),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('— Skip / no match —',
                            style: TextStyle(fontSize: 13)),
                      ),
                      ...apps.map((app) => DropdownMenuItem<String>(
                            value: app.id,
                            child: Text(
                              '${app.company} — ${app.role}',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                    onChanged: onMatchApp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _sourceColor(String pkg, ColorScheme cs) {
    return switch (pkg) {
      'com.naukri.android' => const Color(0xFF06ABD5),
      'com.linkedin.android' => const Color(0xFF0A66C2),
      'com.indeed.android.jobsearch' => const Color(0xFF2164F3),
      _ => cs.primary,
    };
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 72, color: cs.onSurface.withValues(alpha: 0.15)),
            const SizedBox(height: 20),
            Text('No pending updates',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(
              'Job updates from Naukri, LinkedIn and other apps will appear here automatically once Notification Access is granted.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
