import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/enums.dart';
import '../../models/referral.dart';
import '../../models/referral_source.dart';
import '../../providers/applications_provider.dart';
import '../../providers/referrals_provider.dart';
import '../../providers/settings_provider.dart';
import 'referral_sheets.dart';

class ReferralsScreen extends ConsumerWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Referrals'),
          actions: [
            IconButton(
              tooltip: 'My referral details',
              icon: const Icon(Icons.badge_outlined),
              onPressed: () => showReferralProfileSheet(context),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'Groups & Forms'),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tab = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: tab,
              builder: (_, _) => FloatingActionButton.extended(
                onPressed: () {
                  if (tab.index == 0) {
                    showAddReferralSheet(context);
                  } else {
                    showAddSourceSheet(context);
                  }
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(tab.index == 0 ? 'New Request' : 'New Group'),
              ),
            );
          },
        ),
        body: const TabBarView(
          children: [_RequestsTab(), _SourcesTab()],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referrals = ref.watch(referralsNotifierProvider);
    final counts = ref.watch(referralCountsProvider);

    if (referrals.isEmpty) {
      return _Empty(
        icon: Icons.handshake_outlined,
        title: 'No referral requests yet',
        message:
            'Log a referral you asked for via a form or group, track its status, and convert it to an application.',
        action: 'Log a request',
        onAction: () => showAddReferralSheet(context),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        // Status summary chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ReferralStatus.values.map((s) {
              final c = counts[s] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text('${s.label}  $c'),
                  backgroundColor: _statusColor(s).withValues(alpha: 0.12),
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(s)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        ...referrals.map((r) => _ReferralCard(referral: r)),
      ],
    );
  }
}

class _ReferralCard extends ConsumerWidget {
  final Referral referral;
  const _ReferralCard({required this.referral});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final source = ref
        .read(referralSourcesNotifierProvider.notifier)
        .getById(referral.sourceId);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    referral.role == null || referral.role!.isEmpty
                        ? referral.company
                        : '${referral.company} · ${referral.role}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') {
                      showAddReferralSheet(context, existing: referral);
                    } else if (v == 'delete') {
                      ref
                          .read(referralsNotifierProvider.notifier)
                          .delete(referral.id);
                    } else if (v == 'convert') {
                      await _convert(context, ref, source);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (referral.linkedApplicationId == null)
                      const PopupMenuItem(
                          value: 'convert',
                          child: Text('Convert to application')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (source != null)
              Text('via ${source.name}',
                  style: TextStyle(
                      fontSize: 12.5,
                      color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 12),
            Row(
              children: [
                // Status dropdown
                _StatusPill(
                  status: referral.status,
                  onChanged: (s) => ref
                      .read(referralsNotifierProvider.notifier)
                      .setStatus(referral, s),
                ),
                const Spacer(),
                if (referral.linkedApplicationId != null)
                  Icon(Icons.link_rounded, size: 18, color: cs.primary),
                if (source != null && (source.url != null || source.formTemplate != null))
                  IconButton(
                    tooltip: source.type.isForm ? 'Open form' : 'Open',
                    icon: Icon(source.type.isForm
                        ? Icons.assignment_outlined
                        : Icons.open_in_new_rounded),
                    onPressed: () => _openSource(ref, source, referral),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _convert(
      BuildContext context, WidgetRef ref, ReferralSource? source) async {
    final app = await ref.read(applicationsNotifierProvider.notifier).add(
          company: referral.company,
          role: referral.role ?? 'Role via referral',
          jobUrl: referral.jobUrl,
          source: JobSource.referral,
          sourceName: source?.name,
        );
    await ref
        .read(referralsNotifierProvider.notifier)
        .linkApplication(referral, app.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to your applications')),
      );
    }
  }
}

// ---------------------------------------------------------------------------
class _SourcesTab extends ConsumerWidget {
  const _SourcesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(referralSourcesNotifierProvider);
    if (sources.isEmpty) {
      return _Empty(
        icon: Icons.groups_outlined,
        title: 'No referral groups yet',
        message:
            'Save the Google Forms, WhatsApp/Telegram groups and contacts you get referrals through, for one-tap access.',
        action: 'Add a group / form',
        onAction: () => showAddSourceSheet(context),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: sources.map((s) => _SourceCard(source: s)).toList(),
    );
  }
}

class _SourceCard extends ConsumerWidget {
  final ReferralSource source;
  const _SourceCard({required this.source});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final hasLink = (source.url != null && source.url!.isNotEmpty) ||
        (source.formTemplate != null && source.formTemplate!.isNotEmpty);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primary.withValues(alpha: 0.12),
          child: Icon(_sourceIcon(source.type), color: cs.primary, size: 20),
        ),
        title: Text(source.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          source.type.label + (source.type.isForm && source.formTemplate != null ? ' · prefill on' : ''),
          style: TextStyle(fontSize: 12.5, color: cs.onSurface.withValues(alpha: 0.6)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasLink)
              IconButton(
                tooltip: source.type.isForm ? 'Open form' : 'Open',
                icon: Icon(source.type.isForm
                    ? Icons.assignment_outlined
                    : Icons.open_in_new_rounded),
                onPressed: () => _openSource(ref, source, null),
              ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') {
                  showAddSourceSheet(context, existing: source);
                } else if (v == 'delete') {
                  ref
                      .read(referralSourcesNotifierProvider.notifier)
                      .delete(source.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- shared helpers --------------------------------------------------------
Future<void> _openSource(
    WidgetRef ref, ReferralSource source, Referral? referral) async {
  final s = ref.read(settingsNotifierProvider);
  final url = buildReferralOpenUrl(
    source: source,
    referral: referral,
    name: s.referralName,
    email: s.referralEmail,
    phone: s.referralPhone,
    linkedin: s.referralLinkedin,
    resumeUrl: s.referralResumeUrl,
  );
  if (url == null || url.isEmpty) return;
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

Color _statusColor(ReferralStatus s) {
  switch (s) {
    case ReferralStatus.requested:
      return const Color(0xFF3B82F6);
    case ReferralStatus.referred:
      return const Color(0xFF8B5CF6);
    case ReferralStatus.applied:
      return const Color(0xFF22C55E);
    case ReferralStatus.rejected:
      return const Color(0xFFEF4444);
    case ReferralStatus.noResponse:
      return const Color(0xFF9E9E9E);
  }
}

IconData _sourceIcon(ReferralSourceType t) {
  switch (t) {
    case ReferralSourceType.googleForm:
      return Icons.assignment_outlined;
    case ReferralSourceType.group:
      return Icons.groups_outlined;
    case ReferralSourceType.linkedin:
      return Icons.person_search_outlined;
    case ReferralSourceType.person:
      return Icons.badge_outlined;
  }
}

class _StatusPill extends StatelessWidget {
  final ReferralStatus status;
  final ValueChanged<ReferralStatus> onChanged;
  const _StatusPill({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return PopupMenuButton<ReferralStatus>(
      onSelected: onChanged,
      itemBuilder: (_) => ReferralStatus.values
          .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status.label,
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String action;
  final VoidCallback onAction;
  const _Empty({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: cs.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
