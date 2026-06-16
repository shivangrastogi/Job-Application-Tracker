import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/applications_provider.dart';
import '../../providers/interviews_provider.dart';
import '../../providers/goals_provider.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/status_colors.dart';
import '../../core/utils/staleness.dart';
import '../../core/utils/app_display.dart';
import '../../services/cloud_sync_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(analyticsSummaryProvider);
    final upcoming = ref.watch(upcomingInterviewsProvider);
    final goals = ref.watch(goalProgressProvider);
    final activeGoals = goals.where((g) => g.goal.active).toList();
    final cs = Theme.of(context).colorScheme;

    // Strongest resume with a trustworthy sample, for the spotlight card.
    final eligibleResumes = summary.byResume
        .where((r) => !r.lowData && r.id != '__none__' && r.interviewed > 0)
        .toList();
    final topResume = eligibleResumes.isEmpty
        ? null
        : eligibleResumes
            .reduce((a, b) => b.interviewRate > a.interviewRate ? b : a);

    final staleApps = ref.watch(applicationsNotifierProvider).where(isStaleApp).toList()
      ..sort((a, b) =>
          daysSinceUpdate(b.updatedAt).compareTo(daysSinceUpdate(a.updatedAt)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AppliTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sync health banner — only visible when a cloud write has failed
            const _SyncErrorBanner(),

            // Stat cards row
            Row(
              children: [
                _StatCard(
                  label: 'Total',
                  value: summary.total.toString(),
                  icon: Icons.work_outline,
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Active',
                  value: summary.active.toString(),
                  icon: Icons.pending_outlined,
                  color: const Color(0xFF3B82F6),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  label: 'Interviews This Week',
                  value: summary.interviewsThisWeek.toString(),
                  icon: Icons.calendar_today_outlined,
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Offers',
                  value: summary.offers.toString(),
                  icon: Icons.celebration_outlined,
                  color: const Color(0xFF22C55E),
                ),
              ],
            ).animate(delay: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: 16),

            // Follow-up nudge — active applications going stale
            if (staleApps.isNotEmpty) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              color: Color(0xFFF59E0B), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${staleApps.length} application${staleApps.length == 1 ? '' : 's'} need a follow-up',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('No movement in $staleDays+ days.',
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(height: 6),
                      ...staleApps.take(3).map((a) => InkWell(
                            onTap: () => context.push('/applications/${a.id}'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${a.displayRole} · ${a.displayCompany}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Text('${daysSinceUpdate(a.updatedAt)}d',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFF59E0B))),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ).animate(delay: 70.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
              const SizedBox(height: 16),
            ],

            // Top resume spotlight
            if (topResume != null) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/analytics'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.star_rounded,
                              color: Color(0xFF22C55E)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top resume · ${topResume.sent} sent',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface.withValues(alpha: 0.55)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                topResume.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(topResume.interviewRate * 100).round()}%',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF22C55E)),
                            ),
                            Text('interview rate',
                                style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        cs.onSurface.withValues(alpha: 0.5))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate(delay: 75.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
              const SizedBox(height: 16),
            ],

            // Quick access: Companies & Goals
            Row(
              children: [
                _NavTile(
                  label: 'Companies',
                  subtitle: 'Browse MNC openings',
                  icon: Icons.apartment_rounded,
                  color: const Color(0xFF0EA5E9),
                  onTap: () => context.go('/companies'),
                ),
                const SizedBox(width: 12),
                _NavTile(
                  label: 'Goals',
                  subtitle: 'Daily targets',
                  icon: Icons.flag_rounded,
                  color: const Color(0xFFF59E0B),
                  onTap: () => context.push('/goals'),
                ),
                const SizedBox(width: 12),
                _NavTile(
                  label: 'Referrals',
                  subtitle: 'Forms & groups',
                  icon: Icons.handshake_rounded,
                  color: const Color(0xFF14B8A6),
                  onTap: () => context.push('/referrals'),
                ),
              ],
            ).animate(delay: 90.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: 24),

            // Goals progress preview
            if (activeGoals.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Goals",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => context.push('/goals'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...activeGoals.take(3).map((p) => _GoalMiniCard(progress: p)),
              const SizedBox(height: 24),
            ],

            // Pipeline funnel
            Text(
              'Your Pipeline',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _PipelineWidget(counts: summary.byStatus)
                .animate(delay: 120.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.06, end: 0),
            const SizedBox(height: 24),

            // Upcoming interviews
            if (upcoming.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Interviews',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => context.go('/interviews'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...upcoming.take(3).map((interview) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.event_outlined,
                            color: Color(0xFF8B5CF6)),
                      ),
                      title: Text(interview.type.label,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        _formatInterviewDate(interview.scheduledAt),
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.6),
                            fontSize: 13),
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
            ],

            // Response rate
            if (summary.total > 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Response Rate',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: summary.responseRate,
                        backgroundColor: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(summary.responseRate * 100).toStringAsFixed(1)}% of applications got a response',
                        style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatInterviewDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now).inDays;
    if (diff == 0) return 'Today ${_time(dt)}';
    if (diff == 1) return 'Tomorrow ${_time(dt)}';
    return 'In $diff days • ${_time(dt)}';
  }

  String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// Shows a dismissible warning when a cloud write has failed, so silent sync
/// problems (e.g. Firestore rules) are visible. Hidden when sync is healthy.
class _SyncErrorBanner extends StatelessWidget {
  const _SyncErrorBanner();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: CloudSyncService.syncError,
      builder: (context, error, _) {
        if (error == null) return const SizedBox.shrink();
        const amber = Color(0xFFF59E0B);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: amber.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.cloud_off_outlined, color: amber, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(error,
                    style: const TextStyle(fontSize: 12.5, height: 1.3)),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: () => CloudSyncService.syncError.value = null,
                tooltip: 'Dismiss',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // FittedBox keeps long labels ("Interviews This Week") on one line
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 10),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.55)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalMiniCard extends StatelessWidget {
  final GoalProgress progress;
  const _GoalMiniCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color =
        progress.achieved ? const Color(0xFF22C55E) : cs.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${progress.goal.target} ${progress.goal.metric.shortLabel} ${progress.goal.period.unit}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${progress.current}/${progress.goal.target}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.fraction,
                minHeight: 7,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Funnel showing how many applications sit at each pipeline stage,
/// with full stage names so it's clear what each row means.
class _PipelineWidget extends StatelessWidget {
  final Map<ApplicationStatus, int> counts;
  const _PipelineWidget({required this.counts});

  static const _stages = [
    ApplicationStatus.wishlist,
    ApplicationStatus.applied,
    ApplicationStatus.phoneScreen,
    ApplicationStatus.technicalRound,
    ApplicationStatus.onsiteInterview,
    ApplicationStatus.offerReceived,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxVal = _stages
        .map((s) => counts[s] ?? 0)
        .fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: _stages.map((s) {
            final count = counts[s] ?? 0;
            final fraction = maxVal == 0 ? 0.0 : count / maxVal;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor(s),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 96,
                    child: Text(
                      s.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.75)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            color: statusColor(s).withValues(alpha: 0.1),
                          ),
                          AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.centerLeft,
                            widthFactor: fraction,
                            child: Container(
                              height: 8,
                              color: statusColor(s),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
