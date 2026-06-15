import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../providers/interviews_provider.dart';
import '../../providers/applications_provider.dart';
import '../../core/constants/enums.dart';
import '../../models/timeline_event.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';

const _uuid = Uuid();

class AddInterviewScreen extends ConsumerStatefulWidget {
  final String applicationId;
  const AddInterviewScreen({super.key, required this.applicationId});

  @override
  ConsumerState<AddInterviewScreen> createState() => _AddInterviewScreenState();
}

class _AddInterviewScreenState extends ConsumerState<AddInterviewScreen> {
  final _platformCtrl = TextEditingController();
  final _interviewerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  InterviewType _type = InterviewType.phone;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  int _duration = 60;
  bool _loading = false;

  static const _durations = [30, 45, 60, 90, 120];

  @override
  void dispose() {
    _platformCtrl.dispose();
    _interviewerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  DateTime get _scheduledAt => DateTime(
        _date.year, _date.month, _date.day,
        _time.hour, _time.minute,
      );

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    // Capture context-dependent values before async gap
    final timeLabel = _time.format(context);
    try {
      final interview = await ref.read(interviewsNotifierProvider.notifier).add(
            applicationId: widget.applicationId,
            type: _type,
            scheduledAt: _scheduledAt,
            durationMinutes: _duration,
            platform: _platformCtrl.text.trim().isEmpty ? null : _platformCtrl.text.trim(),
            interviewerName: _interviewerCtrl.text.trim().isEmpty ? null : _interviewerCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );

      // Auto timeline event
      final event = TimelineEvent(
        id: _uuid.v4(),
        applicationId: widget.applicationId,
        type: TimelineEventType.interviewScheduled,
        description:
            '${_type.label} interview scheduled for ${_formatDate(_scheduledAt)} at $timeLabel',
        timestamp: DateTime.now(),
      );
      await HiveService.timelineBox.put(event.id, event.toJson());

      // Bump application updatedAt + get title for notification
      final app = ref.read(applicationsNotifierProvider.notifier).getById(widget.applicationId);
      if (app != null) {
        await ref.read(applicationsNotifierProvider.notifier)
            .update(app.copyWith(updatedAt: DateTime.now()));

        // Schedule interview reminders
        await NotificationService.scheduleInterviewReminders(
          interviewId: interview.id,
          applicationTitle: '${app.company} – ${app.role}',
          interviewType: _type.label,
          scheduledAt: _scheduledAt,
        );
      }

      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Interview'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Label('Interview Type'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: InterviewType.values.map((t) {
              final sel = _type == t;
              return ChoiceChip(
                label: Text(t.label),
                selected: sel,
                onSelected: (_) => setState(() => _type = t),
                selectedColor: cs.primaryContainer,
                labelStyle: TextStyle(fontWeight: sel ? FontWeight.w700 : FontWeight.normal),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          _Label('Date & Time'),
          Row(
            children: [
              Expanded(
                child: _PickerTile(
                  icon: Icons.calendar_today_outlined,
                  label: _formatDate(_date),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickerTile(
                  icon: Icons.access_time_outlined,
                  label: _time.format(context),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _Label('Duration'),
          Wrap(
            spacing: 8,
            children: _durations.map((d) {
              final sel = _duration == d;
              return ChoiceChip(
                label: Text('${d}min'),
                selected: sel,
                onSelected: (_) => setState(() => _duration = d),
                selectedColor: cs.primaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _platformCtrl,
            decoration: const InputDecoration(
              labelText: 'Platform (Zoom, Meet, Phone…)',
              prefixIcon: Icon(Icons.video_call_outlined),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _interviewerCtrl,
            decoration: const InputDecoration(
              labelText: 'Interviewer Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
              labelText: 'Notes / Prep',
              prefixIcon: Icon(Icons.notes_outlined),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            minLines: 2,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _save,
              child: const Text('Save Interview'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            )),
      );
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
            ),
          ],
        ),
      ),
    );
  }
}
