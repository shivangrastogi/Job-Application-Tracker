import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/enums.dart';
import '../../models/captured_email.dart';
import '../../models/job_application.dart';
import '../../models/timeline_event.dart';
import '../../providers/applications_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/gmail_service.dart';

enum _Phase { setup, fetching, results, error }

class GmailSyncScreen extends ConsumerStatefulWidget {
  const GmailSyncScreen({super.key});

  @override
  ConsumerState<GmailSyncScreen> createState() => _GmailSyncScreenState();
}

class _GmailSyncScreenState extends ConsumerState<GmailSyncScreen> {
  GmailSyncRange _range = GmailSyncRange.month;
  DateTime? _customStart;
  DateTime? _customEnd;
  _Phase _phase = _Phase.setup;
  String? _error;
  int _progress = 0;
  int _total = 0;
  List<CapturedEmail> _emails = [];
  final Set<String> _selected = {};
  final Map<String, String?> _matchedAppId = {};
  bool _importing = false;

  bool get _canFetch =>
      !_range.isCustom || (_customStart != null && _customEnd != null);

  Future<void> _startFetch() async {
    if (!FirebaseService.isSignedIn) {
      setState(() {
        _phase = _Phase.error;
        _error = 'Sign in with your Google account first (Profile tab).';
      });
      return;
    }

    setState(() {
      _phase = _Phase.fetching;
      _error = null;
      _progress = 0;
      _total = 0;
      _emails = [];
      _selected.clear();
      _matchedAppId.clear();
    });

    // Check / request Gmail scope
    final hasAccess = await GmailService.hasAccess();
    if (!hasAccess) {
      if (mounted) {
        final granted = await _showGrantAccessDialog();
        if (!granted) {
          if (mounted) {
            setState(() {
              _phase = _Phase.error;
              _error =
                  'Gmail access was not granted.\nTap "Grant Access" to allow AppliTrack to read your inbox.';
            });
          }
          return;
        }
      }
    }

    try {
      final since =
          _range.isCustom ? _customStart : _range.defaultSince;
      final until = _range.isCustom ? _customEnd : null;

      final all = await GmailService.fetchEmails(
        since: since,
        until: until,
        onProgress: (f, t) {
          if (mounted) setState(() {
            _progress = f;
            _total = t;
          });
        },
      );

      if (!mounted) return;

      final jobEmails = all
          .where((e) => GmailService.parse(e).isJobRelated)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      _selected.addAll(jobEmails.map((e) => e.id));
      setState(() {
        _emails = jobEmails;
        _phase = _Phase.results;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _phase = _Phase.error;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<bool> _showGrantAccessDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Grant Gmail Access'),
        content: const Text(
          'AppliTrack needs read-only access to your Gmail to find job-related emails.\n\n'
          'It only reads emails — it cannot send, delete, or modify anything.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton.icon(
            onPressed: () async {
              final granted = await GmailService.requestAccess();
              if (ctx.mounted) Navigator.pop(ctx, granted);
            },
            icon: const Icon(Icons.key_rounded, size: 16),
            label: const Text('Grant Access'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _pickCustomRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      initialDateRange: _customStart != null && _customEnd != null
          ? DateTimeRange(start: _customStart!, end: _customEnd!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 90)),
              end: DateTime.now(),
            ),
      helpText: 'Select sync date range',
    );
    if (result != null && mounted) {
      setState(() {
        _customStart = result.start;
        _customEnd = result.end;
      });
    }
  }

  Future<void> _importSelected() async {
    setState(() => _importing = true);
    const uuid = Uuid();
    int updatesAdded = 0;
    int appsCreated = 0;

    for (final email in _emails.where((e) => _selected.contains(e.id))) {
      final parsed = GmailService.parse(email);
      final matchedId = _matchedAppId[email.id];

      String appId;
      if (matchedId != null) {
        appId = matchedId;
      } else {
        // Create a new application from the email
        final company = parsed.company?.isNotEmpty == true
            ? parsed.company!
            : email.displaySender;
        final newApp = await ref
            .read(applicationsNotifierProvider.notifier)
            .add(
              company: company,
              role: _extractRole(email.subject) ?? 'Position from ${parsed.sourceLabel}',
              status: parsed.suggestedStatus ?? ApplicationStatus.wishlist,
              appliedDate: email.date,
              source: _mapSource(parsed.sourceLabel),
              notes: 'Imported from Gmail sync.\nSubject: ${email.subject ?? ''}\n${email.snippet}',
            );
        appId = newApp.id;
        appsCreated++;
      }

      final event = TimelineEvent(
        id: uuid.v4(),
        applicationId: appId,
        type: TimelineEventType.emailDetected,
        description: parsed.description,
        timestamp: email.date,
        source: 'Gmail (${parsed.sourceLabel})',
        sourceUrl: email.gmailUrl,
      );
      await ref
          .read(applicationsNotifierProvider.notifier)
          .addTimelineEvent(event);

      if (parsed.suggestedStatus != null && matchedId != null) {
        final apps = ref.read(applicationsNotifierProvider);
        final idx = apps.indexWhere((a) => a.id == appId);
        if (idx != -1) {
          await ref
              .read(applicationsNotifierProvider.notifier)
              .updateStatus(apps[idx], parsed.suggestedStatus!);
        }
      }
      updatesAdded++;
    }

    if (mounted) {
      setState(() => _importing = false);
      final parts = [
        if (appsCreated > 0) '$appsCreated new app${appsCreated == 1 ? '' : 's'} created',
        if (updatesAdded - appsCreated > 0)
          '${updatesAdded - appsCreated} update${updatesAdded - appsCreated == 1 ? '' : 's'} added',
      ];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(parts.isEmpty
              ? 'Nothing imported'
              : parts.join(', ')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  String? _extractRole(String? subject) {
    if (subject == null) return null;
    // Strip common prefixes like "Job |", "Hiring:", etc.
    final cleaned = subject
        .replaceAll(RegExp(r'^(job\s*[\|:]\s*|hiring:\s*|opening:\s*)', caseSensitive: false), '')
        .trim();
    // Truncate at " at ", " in ", " |", " -" to isolate role
    final match = RegExp(r'^(.*?)(?:\s+at\s+|\s+in\s+|\s*\||\s*-)').firstMatch(cleaned);
    final role = match?.group(1)?.trim() ?? cleaned;
    return role.length > 3 && role.length < 120 ? role : null;
  }

  JobSource _mapSource(String label) => switch (label) {
        'LinkedIn' => JobSource.linkedin,
        'Naukri' || 'NaukriGulf' => JobSource.naukri,
        'Indeed' => JobSource.indeed,
        _ => JobSource.other,
      };

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gmail Sync'),
        actions: [
          if (_phase == _Phase.results)
            TextButton(
              onPressed: () => setState(() {
                _phase = _Phase.setup;
                _emails = [];
                _selected.clear();
              }),
              child: const Text('Change Range'),
            ),
        ],
      ),
      body: switch (_phase) {
        _Phase.setup => _SetupView(
            range: _range,
            customStart: _customStart,
            customEnd: _customEnd,
            canFetch: _canFetch,
            onRangeChanged: (r) => setState(() => _range = r),
            onPickDates: _pickCustomRange,
            onFetch: _startFetch,
          ),
        _Phase.fetching => _FetchingView(
            progress: _progress,
            total: _total,
          ),
        _Phase.results => _ResultsView(
            emails: _emails,
            selected: _selected,
            matchedAppId: _matchedAppId,
            apps: ref.watch(applicationsNotifierProvider),
            onToggle: (id, v) => setState(() {
              if (v) _selected.add(id);
              else _selected.remove(id);
            }),
            onToggleAll: () => setState(() {
              if (_selected.length == _emails.length) {
                _selected.clear();
              } else {
                _selected.addAll(_emails.map((e) => e.id));
              }
            }),
            onMatchApp: (id, appId) =>
                setState(() => _matchedAppId[id] = appId),
            onDelete: (i) => setState(() {
              _selected.remove(_emails[i].id);
              _emails.removeAt(i);
            }),
          ),
        _Phase.error => _ErrorView(
            message: _error,
            onGrantAccess: () async {
              final granted = await GmailService.requestAccess();
              if (granted && mounted) _startFetch();
            },
            onBack: () => setState(() {
              _phase = _Phase.setup;
              _error = null;
            }),
          ),
      },
      bottomNavigationBar: _phase == _Phase.results
          ? _ImportBar(
              selected: _selected,
              matchedAppId: _matchedAppId,
              importing: _importing,
              onImport: _importSelected,
            )
          : null,
    );
  }
}

// ─────────────────────── Setup view ─────────────────────────────────

class _SetupView extends StatelessWidget {
  final GmailSyncRange range;
  final DateTime? customStart;
  final DateTime? customEnd;
  final bool canFetch;
  final ValueChanged<GmailSyncRange> onRangeChanged;
  final VoidCallback onPickDates;
  final VoidCallback onFetch;

  const _SetupView({
    required this.range,
    required this.customStart,
    required this.customEnd,
    required this.canFetch,
    required this.onRangeChanged,
    required this.onPickDates,
    required this.onFetch,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM d, yyyy');
    final hasCustomDates = customStart != null && customEnd != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
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
                    child: Icon(Icons.mark_email_unread_outlined,
                        color: cs.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Find job emails',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          'Scans Naukri, LinkedIn, Indeed & HR emails',
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 24),

          // Range label
          Text(
            'SYNC RANGE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 8),

          // Range card
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                children: [
                  DropdownButtonFormField<GmailSyncRange>(
                    value: range,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Select range',
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    items: GmailSyncRange.values
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.label),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onRangeChanged(v);
                    },
                  ),
                  if (range.isCustom) ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: onPickDates,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.date_range_rounded,
                                size: 18, color: cs.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                hasCustomDates
                                    ? '${fmt.format(customStart!)}  →  ${fmt.format(customEnd!)}'
                                    : 'Tap to choose date range',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: hasCustomDates
                                      ? cs.onSurface
                                      : cs.onSurface.withValues(alpha: 0.5),
                                  fontWeight: hasCustomDates
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                size: 18,
                                color: cs.onSurface.withValues(alpha: 0.4)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ).animate().fadeIn(delay: 60.ms),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canFetch ? onFetch : null,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Search Emails'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // What it searches
          Card(
            color: cs.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What AppliTrack searches for:',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface.withValues(alpha: 0.7))),
                  const SizedBox(height: 8),
                  for (final item in [
                    '📧  Emails from Naukri, LinkedIn, Indeed, Internshala & more',
                    '🔔  Shortlisted / interview / offer / rejection notifications',
                    '👁️  Resume viewed & profile activity alerts',
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(item,
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  cs.onSurface.withValues(alpha: 0.65))),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.lock_outline, size: 12,
                          color: cs.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Read-only access. AppliTrack never stores your emails.',
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.45)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 140.ms),
        ],
      ),
    );
  }
}

// ─────────────────────── Fetching view ───────────────────────────────

class _FetchingView extends StatelessWidget {
  final int progress;
  final int total;

  const _FetchingView({required this.progress, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = total > 0 ? progress / total : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_search_rounded,
                    size: 72,
                    color: cs.primary.withValues(alpha: 0.35))
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1500.ms, color: cs.primary),
            const SizedBox(height: 28),
            Text(
              total > 0 ? 'Scanning your inbox…' : 'Connecting to Gmail…',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (total > 0) ...[
              Text(
                '$progress of $total emails processed',
                style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── Results view ────────────────────────────────

class _ResultsView extends StatelessWidget {
  final List<CapturedEmail> emails;
  final Set<String> selected;
  final Map<String, String?> matchedAppId;
  final List<JobApplication> apps;
  final void Function(String id, bool v) onToggle;
  final VoidCallback onToggleAll;
  final void Function(String id, String? appId) onMatchApp;
  final void Function(int index) onDelete;

  const _ResultsView({
    required this.emails,
    required this.selected,
    required this.matchedAppId,
    required this.apps,
    required this.onToggle,
    required this.onToggleAll,
    required this.onMatchApp,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (emails.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined,
                  size: 72, color: cs.onSurface.withValues(alpha: 0.15)),
              const SizedBox(height: 20),
              Text('No job emails found',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(
                'Try a wider date range, or check that Gmail access is granted.',
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

    return Column(
      children: [
        // Banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.mark_email_read_rounded,
                  color: cs.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${emails.length} job email${emails.length == 1 ? '' : 's'} found. '
                  'Match each to an application, then import.',
                  style: TextStyle(
                      fontSize: 13, color: cs.onPrimaryContainer),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6)),
                onPressed: onToggleAll,
                child: Text(
                  selected.length == emails.length
                      ? 'Deselect all'
                      : 'Select all',
                  style: TextStyle(fontSize: 12, color: cs.primary),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            itemCount: emails.length,
            itemBuilder: (context, i) {
              final email = emails[i];
              return _EmailCard(
                email: email,
                parsed: GmailService.parse(email),
                isSelected: selected.contains(email.id),
                matchedAppId: matchedAppId[email.id],
                apps: apps,
                onToggle: (v) => onToggle(email.id, v),
                onMatchApp: (id) => onMatchApp(email.id, id),
                onDelete: () => onDelete(i),
              ).animate()
                .slideY(
                  begin: 0.18,
                  end: 0,
                  duration: 220.ms,
                  curve: Curves.easeOutCubic,
                )
                .scaleXY(
                  begin: 0.94,
                  end: 1.0,
                  duration: 220.ms,
                  curve: Curves.easeOutCubic,
                );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────── Email card ──────────────────────────────────

class _EmailCard extends StatelessWidget {
  final CapturedEmail email;
  final EmailParseResult parsed;
  final bool isSelected;
  final String? matchedAppId;
  final List<JobApplication> apps;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String?> onMatchApp;
  final VoidCallback onDelete;

  const _EmailCard({
    required this.email,
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
    final srcColor = _sourceColor(parsed.sourceLabel, cs);
    final fmt = DateFormat('MMM d');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (v) => onToggle(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 2),
                // Source chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: srcColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    parsed.sourceLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: srcColor),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    fmt.format(email.date),
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.45)),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.close,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.35)),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            // Subject & snippet
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (email.subject != null)
                    Text(
                      email.subject!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (email.snippet.isNotEmpty)
                    Text(
                      email.snippet,
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.65)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),

                  // Parse result card
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
                                  color:
                                      cs.onSurface.withValues(alpha: 0.45)),
                              const SizedBox(width: 5),
                              Text('Suggest: ',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurface
                                          .withValues(alpha: 0.6))),
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
                    value: matchedAppId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      hintText: parsed.company != null
                          ? 'Match to app (try: ${parsed.company})'
                          : 'Match to application…',
                      hintStyle: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: 0.4)),
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
                  const SizedBox(height: 8),

                  // Open in Gmail button
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(email.gmailUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text('Open in Gmail',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _sourceColor(String src, ColorScheme cs) => switch (src) {
        'Naukri' => const Color(0xFF06ABD5),
        'LinkedIn' => const Color(0xFF0A66C2),
        'Indeed' => const Color(0xFF2164F3),
        'Internshala' => const Color(0xFF009B77),
        'Unstop' => const Color(0xFF7C3AED),
        'Glassdoor' => const Color(0xFF0CAA41),
        'Cutshort' => const Color(0xFFE63946),
        'Wellfound' => const Color(0xFF121212),
        _ => cs.primary,
      };
}

// ─────────────────────── Error view ──────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onGrantAccess;
  final VoidCallback onBack;

  const _ErrorView({
    required this.message,
    required this.onGrantAccess,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showGrantButton = message?.toLowerCase().contains('access') == true ||
        message?.toLowerCase().contains('denied') == true ||
        message?.toLowerCase().contains('grant') == true;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: cs.error),
            const SizedBox(height: 16),
            Text('Could not fetch emails',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              message ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.6),
                  height: 1.5),
            ),
            const SizedBox(height: 24),
            if (showGrantButton) ...[
              FilledButton.icon(
                onPressed: onGrantAccess,
                icon: const Icon(Icons.key_rounded),
                label: const Text('Grant Gmail Access'),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── Import bar ──────────────────────────────────

class _ImportBar extends StatelessWidget {
  final Set<String> selected;
  final Map<String, String?> matchedAppId;
  final bool importing;
  final VoidCallback onImport;

  const _ImportBar({
    required this.selected,
    required this.matchedAppId,
    required this.importing,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final matchedCount =
        selected.where((id) => matchedAppId[id] != null).length;
    final unmatched = selected.length - matchedCount;

    String buttonLabel;
    if (importing) {
      buttonLabel = 'Importing…';
    } else if (selected.isEmpty) {
      buttonLabel = 'Select emails to import';
    } else if (matchedCount == 0) {
      buttonLabel = 'Create ${selected.length} new application${selected.length == 1 ? '' : 's'}';
    } else if (unmatched == 0) {
      buttonLabel = 'Import $matchedCount update${matchedCount == 1 ? '' : 's'}';
    } else {
      buttonLabel = 'Import $matchedCount + create $unmatched new app${unmatched == 1 ? '' : 's'}';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (unmatched > 0 && selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '$unmatched email${unmatched == 1 ? '' : 's'} not matched — will be added as new applications.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ),
            FilledButton.icon(
              onPressed: selected.isEmpty || importing ? null : onImport,
              icon: importing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download_done_rounded),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
