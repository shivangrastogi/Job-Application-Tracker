import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../models/goal.dart';
import '../../providers/goals_provider.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(goalProgressProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Goal'),
      ),
      body: progress.isEmpty
          ? _EmptyState(onAdd: () => _showGoalSheet(context, ref))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Text(
                  'Stay on grind. Track your daily and weekly targets.',
                  style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 16),
                ...progress.map((p) => _GoalCard(
                      progress: p,
                      onEdit: () => _showGoalSheet(context, ref, existing: p.goal),
                      onToggle: () => ref
                          .read(goalsNotifierProvider.notifier)
                          .toggleActive(p.goal),
                      onDelete: () => ref
                          .read(goalsNotifierProvider.notifier)
                          .delete(p.goal.id),
                    )),
              ],
            ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalProgress progress;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.progress,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final goal = progress.goal;
    final active = goal.active;
    final color = progress.achieved ? const Color(0xFF22C55E) : cs.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: active ? 1 : 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${goal.target} ${goal.metric.shortLabel} ${goal.period.unit}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (progress.achieved && active)
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF22C55E), size: 22),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'toggle') onToggle();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                          value: 'toggle',
                          child: Text(active ? 'Pause' : 'Resume')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              Text(
                '${goal.period.label} • ${goal.metric.label}',
                style: TextStyle(
                    fontSize: 12.5,
                    color: cs.onSurface.withValues(alpha: 0.55)),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${progress.current}',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -1),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 4),
                    child: Text(
                      '/ ${goal.target}',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      progress.achieved
                          ? 'Done 🎉'
                          : '${progress.remaining} to go',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: progress.achieved
                              ? const Color(0xFF22C55E)
                              : cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.fraction,
                  minHeight: 10,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.06, end: 0);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined,
                size: 64, color: cs.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: 16),
            const Text('No goals yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Set a target like "100 applications a day" and track your progress.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create your first goal'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showGoalSheet(BuildContext context, WidgetRef ref,
    {Goal? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: _GoalSheet(existing: existing),
    ),
  );
}

class _GoalSheet extends ConsumerStatefulWidget {
  final Goal? existing;
  const _GoalSheet({this.existing});

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late GoalMetric _metric;
  late GoalPeriod _period;
  late final TextEditingController _targetCtrl;

  @override
  void initState() {
    super.initState();
    _metric = widget.existing?.metric ?? GoalMetric.applicationsApplied;
    _period = widget.existing?.period ?? GoalPeriod.daily;
    _targetCtrl =
        TextEditingController(text: widget.existing?.target.toString() ?? '');
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final target = int.tryParse(_targetCtrl.text.trim()) ?? 0;
    if (target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a target greater than 0')),
      );
      return;
    }
    final notifier = ref.read(goalsNotifierProvider.notifier);
    if (widget.existing != null) {
      notifier.update(widget.existing!
          .copyWith(metric: _metric, period: _period, target: target));
    } else {
      notifier.add(metric: _metric, period: _period, target: target);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existing == null ? 'New Goal' : 'Edit Goal',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          const Text('I want to track',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: GoalMetric.values
                .map((m) => ChoiceChip(
                      label: Text(m.label),
                      selected: _metric == m,
                      onSelected: (_) => setState(() => _metric = m),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text('Per', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: GoalPeriod.values
                .map((p) => ChoiceChip(
                      label: Text(p.label),
                      selected: _period == p,
                      onSelected: (_) => setState(() => _period = p),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _targetCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target',
              hintText: 'e.g. 100',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Text(widget.existing == null ? 'Create Goal' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}
