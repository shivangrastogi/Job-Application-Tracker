import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/status_colors.dart';

String _fmtMoney(double v, String cur) {
  final n = (v * 10).round() / 10;
  final s = n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
  return cur == 'INR' ? '₹$s LPA' : '$s $cur';
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(analyticsSummaryProvider);
    final overTime = ref.watch(applicationsOverTimeProvider);
    final cs = Theme.of(context).colorScheme;

    if (summary.total == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined,
                  size: 64, color: cs.onSurface.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text('No data yet',
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.4), fontSize: 16)),
              const SizedBox(height: 8),
              Text('Add some applications to see your analytics',
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.3), fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Key metrics row
          Row(
            children: [
              _MetricCard(
                  label: 'Response Rate',
                  value: '${(summary.responseRate * 100).toStringAsFixed(1)}%',
                  color: const Color(0xFF3B82F6)),
              const SizedBox(width: 12),
              _MetricCard(
                  label: 'Offer Rate',
                  value: '${(summary.offerRate * 100).toStringAsFixed(1)}%',
                  color: const Color(0xFF22C55E)),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetricCard(
                  label: 'Total Applied',
                  value: summary.total.toString(),
                  color: cs.primary),
              const SizedBox(width: 12),
              _MetricCard(
                  label: 'Active',
                  value: summary.active.toString(),
                  color: const Color(0xFFF97316)),
            ],
          ),
          const SizedBox(height: 24),

          // Applications over time — LineChart
          if (overTime.length >= 2) ...[
            _SectionTitle('Applications Over Time'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 24, 12),
                child: SizedBox(
                  height: 160,
                  child: _TimelineChart(entries: overTime),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Status breakdown — horizontal BarChart
          _SectionTitle('By Status'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _StatusBarChart(byStatus: summary.byStatus, total: summary.total),
            ),
          ),
          const SizedBox(height: 24),

          // Source breakdown — PieChart
          _SectionTitle('By Source'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _SourcePieChart(bySource: summary.bySource),
            ),
          ),
          const SizedBox(height: 24),

          // Resume performance — which resume is converting best
          if (summary.byResume.isNotEmpty) ...[
            _SectionTitle('Resume Performance'),
            const SizedBox(height: 12),
            _ResumeRecommendation(resumes: summary.byResume),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _ResumePerformance(resumes: summary.byResume),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Cover letter impact — does sending one lift the interview rate?
          if (summary.byCoverLetter.isNotEmpty) ...[
            _SectionTitle('Cover Letter Impact'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _ResumePerformance(
                    resumes: summary.byCoverLetter,
                    showLowDataNote: false,
                    firstColLabel: 'COVER LETTER'),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Channel performance — which source converts best
          if (summary.bySourcePerf.isNotEmpty) ...[
            _SectionTitle('Channel Performance'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _ResumePerformance(
                  resumes: summary.bySourcePerf,
                  firstColLabel: 'SOURCE',
                  noteText:
                      'Where your applications convert best. Pair with resume performance to see which resume works on each channel.',
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Salary insights
          if (summary.salary != null) ...[
            _SectionTitle('Salary Insights'),
            const SizedBox(height: 12),
            Builder(builder: (context) {
              final s = summary.salary!;
              String m(double v) => _fmtMoney(v, s.currency);
              return Column(
                children: [
                  Row(children: [
                    _MetricCard(label: 'Median', value: m(s.median), color: const Color(0xFF3B82F6)),
                    const SizedBox(width: 12),
                    _MetricCard(label: 'Average', value: m(s.average), color: const Color(0xFF8B5CF6)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    _MetricCard(label: 'Lowest', value: m(s.lo), color: const Color(0xFF6B7280)),
                    const SizedBox(width: 12),
                    _MetricCard(
                        label: s.offeredAvg != null ? 'Avg of offers' : 'Highest',
                        value: s.offeredAvg != null ? m(s.offeredAvg!) : m(s.hi),
                        color: const Color(0xFF22C55E)),
                  ]),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'From ${s.count} application${s.count == 1 ? '' : 's'} with salary data'
                      '${s.offeredCount > 0 ? ' · ${s.offeredCount} offer${s.offeredCount == 1 ? '' : 's'}' : ''}.',
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
          ],

          // Work type grid
          _SectionTitle('By Work Type'),
          const SizedBox(height: 12),
          Row(
            children: WorkType.values.map((w) {
              final count = summary.byWorkType[w] ?? 0;
              return Expanded(
                child: Card(
                  margin: const EdgeInsets.only(right: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(count.toString(),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(w.label,
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.55)),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Metric card ───────────────────────────

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55))),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────── Section title ─────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700));
  }
}

// ──────────────────────── Applications over time ────────────────────

class _TimelineChart extends StatelessWidget {
  final List<MapEntry<DateTime, int>> entries;
  const _TimelineChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value.toDouble());
    }).toList();

    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: cs.onSurface.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: TextStyle(
                    fontSize: 10,
                    color: cs.onSurface.withValues(alpha: 0.4)),
              ),
              interval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: entries.length <= 10,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= entries.length) return const SizedBox();
                final dt = entries[idx].key;
                const m = ['Jan','Feb','Mar','Apr','May','Jun',
                  'Jul','Aug','Sep','Oct','Nov','Dec'];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${m[dt.month - 1]} ${dt.day}',
                      style: TextStyle(
                          fontSize: 9,
                          color: cs.onSurface.withValues(alpha: 0.4))),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: cs.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: entries.length <= 14,
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                radius: 3,
                color: cs.primary,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.primary.withValues(alpha: 0.18),
                  cs.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        minY: 0,
        maxY: maxY + 1,
      ),
    );
  }
}

// ─────────────────────────── Status BarChart ────────────────────────

class _StatusBarChart extends StatelessWidget {
  final Map<ApplicationStatus, int> byStatus;
  final int total;
  const _StatusBarChart({required this.byStatus, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statuses = ApplicationStatus.values
        .where((s) => (byStatus[s] ?? 0) > 0)
        .toList();
    if (statuses.isEmpty) return const SizedBox();

    final maxVal = statuses
        .map((s) => byStatus[s] ?? 0)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Column(
      children: [
        SizedBox(
          height: statuses.length * 38.0,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => cs.surfaceContainerHighest,
                  getTooltipItem: (group, _, rod, _) {
                    final s = statuses[group.x.toInt()];
                    return BarTooltipItem(
                      '${s.label}: ${rod.toY.toInt()}',
                      TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= statuses.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          statuses[idx].label,
                          style: TextStyle(
                              fontSize: 9,
                              color: cs.onSurface.withValues(alpha: 0.5)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: false,
                drawVerticalLine: true,
                getDrawingVerticalLine: (_) => FlLine(
                  color: cs.onSurface.withValues(alpha: 0.06),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: statuses.asMap().entries.map((e) {
                final s = e.value;
                final count = byStatus[s] ?? 0;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: statusColor(s),
                      width: 18,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
              maxY: maxVal + 1,
              minY: 0,
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────── Source PieChart ────────────────────────

class _SourcePieChart extends StatefulWidget {
  final Map<JobSource, int> bySource;
  const _SourcePieChart({required this.bySource});

  @override
  State<_SourcePieChart> createState() => _SourcePieChartState();
}

class _SourcePieChartState extends State<_SourcePieChart> {
  int? _touched;

  static const _palette = [
    Color(0xFF4F46E5),
    Color(0xFF06B6D4),
    Color(0xFF22C55E),
    Color(0xFFF97316),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFFEAB308),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sources = JobSource.values
        .where((s) => (widget.bySource[s] ?? 0) > 0)
        .toList();
    if (sources.isEmpty) return const SizedBox();
    final total = sources.fold(0, (sum, s) => sum + (widget.bySource[s] ?? 0));

    return Row(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, resp) {
                  if (!event.isInterestedForInteractions ||
                      resp == null ||
                      resp.touchedSection == null) {
                    setState(() => _touched = null);
                    return;
                  }
                  setState(() =>
                      _touched = resp.touchedSection!.touchedSectionIndex);
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: sources.asMap().entries.map((e) {
                final s = e.value;
                final count = widget.bySource[s] ?? 0;
                final isTouched = _touched == e.key;
                return PieChartSectionData(
                  value: count.toDouble(),
                  color: _palette[e.key % _palette.length],
                  radius: isTouched ? 48 : 40,
                  title: isTouched ? count.toString() : '',
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sources.asMap().entries.map((e) {
              final s = e.value;
              final count = widget.bySource[s] ?? 0;
              final pct = total == 0 ? 0.0 : count / total * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _palette[e.key % _palette.length],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(s.label,
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.8))),
                    ),
                    Text('$count',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Text('(${pct.toStringAsFixed(0)}%)',
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.4))),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Resume performance ───────────────────────

class _ResumePerformance extends StatelessWidget {
  final List<ResumeStat> resumes;
  final bool showLowDataNote;
  final String firstColLabel;
  final String? noteText;
  const _ResumePerformance({
    required this.resumes,
    this.showLowDataNote = true,
    this.firstColLabel = 'RESUME',
    this.noteText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final headStyle = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: cs.onSurface.withValues(alpha: 0.5));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(flex: 4, child: Text(firstColLabel, style: headStyle)),
            Expanded(child: Text('SENT', style: headStyle, textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('RESP', style: headStyle, textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('INTV', style: headStyle, textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('OFFER', style: headStyle, textAlign: TextAlign.center)),
          ],
        ),
        const Divider(height: 16),
        ...resumes.map((r) => Opacity(
              opacity: (showLowDataNote && r.lowData) ? 0.55 : 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(r.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                          if (showLowDataNote && r.lowData) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: cs.onSurface.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text('LOW DATA',
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          cs.onSurface.withValues(alpha: 0.5))),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text('${r.sent}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13)),
                    ),
                    Expanded(flex: 2, child: _RateChip(rate: r.responseRate)),
                    Expanded(flex: 2, child: _RateChip(rate: r.interviewRate)),
                    Expanded(flex: 2, child: _RateChip(rate: r.offerRate)),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 2),
        Text(
          noteText ??
              (showLowDataNote
                  ? 'Share of sent applications (excludes wishlist). Resumes under '
                      '$kMinResumeSample applications are marked low data.'
                  : 'Share of sent applications (excludes wishlist).'),
          style: TextStyle(
              fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4)),
        ),
      ],
    );
  }
}

/// Actionable nudge: when the best resume beats the worst on interview rate by
/// a meaningful margin, suggest leading with it and offer to set it as default.
class _ResumeRecommendation extends ConsumerWidget {
  final List<ResumeStat> resumes;
  const _ResumeRecommendation({required this.resumes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eligible = resumes
        .where((r) => !r.lowData && r.id != '__none__')
        .toList()
      ..sort((a, b) => b.interviewRate.compareTo(a.interviewRate));
    if (eligible.length < 2) return const SizedBox.shrink();
    final best = eligible.first;
    final worst = eligible.last;
    if (best.interviewRate - worst.interviewRate < 0.10) {
      return const SizedBox.shrink();
    }
    final factor = worst.interviewRate > 0
        ? '${(best.interviewRate / worst.interviewRate).toStringAsFixed(1)}×'
        : null;
    final defaultId = ref.watch(settingsNotifierProvider).defaultResumeId;
    final isDefault = best.id == defaultId;
    const green = Color(0xFF22C55E);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡 ', style: TextStyle(fontSize: 15)),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: best.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(
                        text:
                            ' lands interviews at ${(best.interviewRate * 100).round()}%'
                            '${factor != null ? ', $factor better than ' : ', vs '}'),
                    TextSpan(
                        text: worst.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(
                        text:
                            ' (${(worst.interviewRate * 100).round()}%). Lead with it.'),
                  ]),
                  style: const TextStyle(fontSize: 13, height: 1.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: isDefault
                ? const Text('Default ✓',
                    style: TextStyle(
                        color: green,
                        fontWeight: FontWeight.w700,
                        fontSize: 12))
                : TextButton(
                    onPressed: () => ref
                        .read(settingsNotifierProvider.notifier)
                        .setDefaultResumeId(best.id),
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact),
                    child: const Text('Set as default'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RateChip extends StatelessWidget {
  final double rate; // 0..1
  const _RateChip({required this.rate});

  @override
  Widget build(BuildContext context) {
    final pct = (rate * 100).round();
    final color = pct >= 50
        ? const Color(0xFF22C55E)
        : pct >= 25
            ? const Color(0xFFF59E0B)
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45);
    return Text('$pct%',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: color));
  }
}
