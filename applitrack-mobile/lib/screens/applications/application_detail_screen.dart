import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/applications_provider.dart';
import '../../providers/documents_provider.dart';
import '../../providers/interviews_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../models/job_application.dart';
import '../../core/utils/app_display.dart';
import '../../models/interview.dart';
import '../../models/contact.dart';
import '../../models/timeline_event.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/status_colors.dart';
import '../../services/hive_service.dart';

class ApplicationDetailScreen extends ConsumerWidget {
  final String id;
  const ApplicationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state (not the notifier) so status changes rebuild instantly
    final app = ref
        .watch(applicationsNotifierProvider)
        .where((a) => a.id == id)
        .firstOrNull;
    if (app == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Application not found')),
      );
    }
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(app.displayCompany),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/applications/${app.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app.displayRole,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(app.displayCompany,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: cs.onSurface.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showStatusSheet(context, ref, app.status),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusBgColor(app.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(app.status.label,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: statusColor(app.status))),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down,
                                  size: 18, color: statusColor(app.status)),
                            ],
                          ),
                        ).animate(key: ValueKey(app.status)).scale(
                            begin: const Offset(0.88, 0.88),
                            end: const Offset(1, 1),
                            duration: 220.ms,
                            curve: Curves.elasticOut),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      _Chip(Icons.laptop_outlined, app.workType.label),
                      _Chip(
                          Icons.source_outlined,
                          app.sourceName?.isNotEmpty == true
                              ? app.sourceName!
                              : app.source.label),
                      if (app.location != null)
                        _Chip(Icons.location_on_outlined, app.location!),
                    ],
                  ),
                ],
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Timeline'),
                Tab(text: 'Interviews'),
                Tab(text: 'Contacts'),
              ],
              isScrollable: false,
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(app: app),
                  _TimelineTab(applicationId: id),
                  _InterviewsTab(applicationId: id),
                  _ContactsTab(applicationId: id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSheet(BuildContext context, WidgetRef ref, ApplicationStatus current) {
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
            const Text('Change Status',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ApplicationStatus.values.map((s) {
                final sel = current == s;
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final app = ref.read(applicationsNotifierProvider.notifier).getById(id);
                    if (app != null && app.status != s) {
                      await ref.read(applicationsNotifierProvider.notifier)
                          .update(app.copyWith(status: s));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? statusColor(s) : statusBgColor(s),
                      borderRadius: BorderRadius.circular(20),
                      border: sel ? null : Border.all(
                          color: statusColor(s).withValues(alpha: 0.3)),
                    ),
                    child: Text(s.label,
                        style: TextStyle(
                            color: sel ? Colors.white : statusColor(s),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
            'This will permanently delete this application and all related data.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(applicationsNotifierProvider.notifier).delete(id);
              if (context.mounted) context.go('/applications');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Shared chip ────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

// ─────────────────────────── Overview tab ───────────────────────────

class _OverviewTab extends ConsumerWidget {
  final JobApplication app;
  const _OverviewTab({required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final resume = app.resumeVersionId == null
        ? null
        : ref
            .watch(documentsNotifierProvider)
            .where((d) => d.id == app.resumeVersionId)
            .firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (app.salaryMin != null || app.salaryMax != null)
          _InfoRow(Icons.payments_outlined, 'Salary',
              '${app.salaryCurrency} ${app.salaryMin?.toStringAsFixed(0) ?? '?'} – ${app.salaryMax?.toStringAsFixed(0) ?? '?'} LPA'),
        if (app.jobUrl != null)
          _InfoRow(Icons.link_outlined, 'Job URL', app.jobUrl!,
              onTap: () => launchUrl(Uri.parse(app.jobUrl!))),
        _InfoRow(Icons.calendar_today_outlined, 'Applied',
            app.appliedDate != null ? _fmt(app.appliedDate!) : 'Not set'),
        _InfoRow(Icons.priority_high_outlined, 'Priority',
            '${'★' * app.priority}${'☆' * (5 - app.priority)}'),
        _InfoRow(Icons.update_outlined, 'Last updated', _fmt(app.updatedAt)),
        if (resume != null) ...[
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              onTap: resume.filePath != null
                  ? () => _openResume(context, resume.filePath!)
                  : null,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_outlined,
                    color: Color(0xFF3B82F6), size: 20),
              ),
              title: Text(
                resume.version != null
                    ? '${resume.name} · v${resume.version}'
                    : resume.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: const Text('Resume used', style: TextStyle(fontSize: 12)),
              trailing: resume.filePath == null
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 20),
                          tooltip: 'Open',
                          onPressed: () =>
                              _openResume(context, resume.filePath!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.ios_share, size: 20),
                          tooltip: 'Share / Download',
                          onPressed: () async {
                            if (File(resume.filePath!).existsSync()) {
                              await Share.shareXFiles(
                                  [XFile(resume.filePath!)],
                                  text: resume.name);
                            }
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ],
        if (app.notes != null && app.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Notes',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(app.notes!, style: const TextStyle(height: 1.5)),
          ),
        ],
      ],
    );
  }

  Future<void> _openResume(BuildContext context, String path) async {
    if (!File(path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume file not found on this device.')),
      );
      return;
    }
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  }

  String _fmt(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _InfoRow(this.icon, this.label, this.value, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 12),
            SizedBox(
              width: 90,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13, color: cs.onSurface.withValues(alpha: 0.55))),
            ),
            Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: onTap != null ? cs.primary : cs.onSurface)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Timeline tab ───────────────────────────

class _TimelineTab extends ConsumerStatefulWidget {
  final String applicationId;
  const _TimelineTab({required this.applicationId});

  @override
  ConsumerState<_TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<_TimelineTab> {
  List<TimelineEvent> _events() {
    return HiveService.timelineBox.values
        .map((raw) => TimelineEvent.fromJson(Map<String, dynamic>.from(raw)))
        .where((e) => e.applicationId == widget.applicationId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _showAddNote() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Note',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                hintText: 'Write a note…',
                alignLabelWithHint: true,
              ),
              autofocus: true,
              maxLines: 4,
              minLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  await ref
                      .read(applicationsNotifierProvider.notifier)
                      .addNote(widget.applicationId, ctrl.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                  setState(() {});
                },
                child: const Text('Save Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _events();

    return Stack(
      children: [
        events.isEmpty
            ? Center(
                child: Text('No activity yet',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4))),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: events.length,
                itemBuilder: (context, i) {
                  final e = events[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _color(e.type).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_icon(e.type), size: 14, color: _color(e.type)),
                          ),
                          if (i < events.length - 1)
                            Container(width: 1, height: 32, color: Colors.grey[200]),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.description,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(_fmtDt(e.timestamp),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.4))),
                                  if (e.source != null) ...[
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: e.sourceUrl != null &&
                                              e.sourceUrl!.contains(
                                                  'mail.google.com')
                                          ? () => launchUrl(
                                                Uri.parse(e.sourceUrl!),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              )
                                          : null,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _color(e.type)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'via ${e.source}',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: _color(e.type)),
                                            ),
                                            if (e.sourceUrl != null &&
                                                e.sourceUrl!.contains(
                                                    'mail.google.com')) ...[
                                              const SizedBox(width: 3),
                                              Icon(
                                                Icons.open_in_new_rounded,
                                                size: 9,
                                                color: _color(e.type),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'timeline_add',
            onPressed: _showAddNote,
            icon: const Icon(Icons.add),
            label: const Text('Add Note'),
          ),
        ),
      ],
    );
  }

  Color _color(TimelineEventType t) {
    switch (t) {
      case TimelineEventType.statusChange: return const Color(0xFF3B82F6);
      case TimelineEventType.note: return const Color(0xFF8B5CF6);
      case TimelineEventType.interviewScheduled: return const Color(0xFFF97316);
      case TimelineEventType.offerReceived: return const Color(0xFF22C55E);
      case TimelineEventType.rejection: return const Color(0xFFEF4444);
      case TimelineEventType.emailDetected: return const Color(0xFF06B6D4);
      case TimelineEventType.notificationDetected: return const Color(0xFFF59E0B);
      case TimelineEventType.manual: return const Color(0xFF9CA3AF);
    }
  }

  IconData _icon(TimelineEventType t) {
    switch (t) {
      case TimelineEventType.statusChange: return Icons.swap_horiz;
      case TimelineEventType.note: return Icons.notes;
      case TimelineEventType.interviewScheduled: return Icons.event;
      case TimelineEventType.offerReceived: return Icons.celebration;
      case TimelineEventType.rejection: return Icons.close;
      case TimelineEventType.emailDetected: return Icons.email;
      case TimelineEventType.notificationDetected: return Icons.notifications_active_rounded;
      case TimelineEventType.manual: return Icons.edit;
    }
  }

  String _fmtDt(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} · '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────── Interviews tab ─────────────────────────

class _InterviewsTab extends ConsumerWidget {
  final String applicationId;
  const _InterviewsTab({required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interviews = ref
        .watch(interviewsNotifierProvider)
        .where((i) => i.applicationId == applicationId)
        .toList();

    return Stack(
      children: [
        interviews.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_outlined,
                        size: 56,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Text('No interviews yet',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4))),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: interviews.length,
                itemBuilder: (context, i) =>
                    _InterviewCard(interview: interviews[i]),
              ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'interview_add',
            onPressed: () =>
                context.push('/applications/$applicationId/interview/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Interview'),
          ),
        ),
      ],
    );
  }
}

class _InterviewCard extends ConsumerWidget {
  final Interview interview;
  const _InterviewCard({required this.interview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isPast = interview.scheduledAt.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPast
                    ? cs.surfaceContainerHighest
                    : const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.video_call_outlined,
                color: isPast ? cs.onSurface.withValues(alpha: 0.4) : const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(interview.type.label,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(_fmtDt(interview.scheduledAt),
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.6))),
                  if (interview.platform != null)
                    Text(interview.platform!,
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${interview.durationMinutes}min',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5))),
                const SizedBox(height: 4),
                _OutcomeChip(interview.outcome),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDt(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} · '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _OutcomeChip extends StatelessWidget {
  final InterviewOutcome outcome;
  const _OutcomeChip(this.outcome);

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (outcome) {
      InterviewOutcome.passed => ('Passed', const Color(0xFF22C55E)),
      InterviewOutcome.failed => ('Failed', const Color(0xFFEF4444)),
      InterviewOutcome.pending => ('Pending', const Color(0xFF3B82F6)),
      InterviewOutcome.noFeedback => ('No feedback', const Color(0xFF9CA3AF)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ─────────────────────────── Contacts tab ───────────────────────────

class _ContactsTab extends ConsumerWidget {
  final String applicationId;
  const _ContactsTab({required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref
        .watch(contactsNotifierProvider)
        .where((c) => c.applicationId == applicationId)
        .toList();
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        contacts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.contacts_outlined,
                        size: 56,
                        color: cs.onSurface.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Text('No contacts yet',
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.4))),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: contacts.length,
                itemBuilder: (ctx, i) => _ContactCard(
                    contact: contacts[i],
                    onDelete: () => ref
                        .read(contactsNotifierProvider.notifier)
                        .delete(contacts[i].id)),
              ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'contact_add',
            onPressed: () =>
                context.push('/applications/$applicationId/contact/add'),
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Add Contact'),
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onDelete;
  const _ContactCard({required this.contact, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: cs.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (contact.title != null)
                        Text(contact.title!,
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
            if (contact.email != null ||
                contact.phone != null ||
                contact.linkedinUrl != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  if (contact.email != null)
                    _ActionChip(
                      icon: Icons.email_outlined,
                      label: contact.email!,
                      onTap: () =>
                          launchUrl(Uri.parse('mailto:${contact.email}')),
                    ),
                  if (contact.phone != null)
                    _ActionChip(
                      icon: Icons.phone_outlined,
                      label: contact.phone!,
                      onTap: () => launchUrl(Uri.parse('tel:${contact.phone}')),
                    ),
                  if (contact.linkedinUrl != null)
                    _ActionChip(
                      icon: Icons.link_outlined,
                      label: 'LinkedIn',
                      onTap: () => launchUrl(Uri.parse(contact.linkedinUrl!)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: cs.primary),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.primary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ],
        ),
      ),
    );
  }
}
