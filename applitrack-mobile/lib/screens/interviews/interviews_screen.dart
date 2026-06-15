import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/interviews_provider.dart';
import '../../models/interview.dart';
import '../../core/constants/enums.dart';

class InterviewsScreen extends ConsumerStatefulWidget {
  const InterviewsScreen({super.key});

  @override
  ConsumerState<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends ConsumerState<InterviewsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(interviewsNotifierProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    final selectedDayInterviews = _selectedDay != null
        ? notifier.forDate(_selectedDay!)
        : <Interview>[];

    final upcoming = ref.watch(upcomingInterviewsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Interviews')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) => notifier.forDate(day),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: cs.tertiary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _selectedDay != null && selectedDayInterviews.isNotEmpty
                ? _InterviewList(
                    interviews: selectedDayInterviews,
                    title: 'Selected Day',
                  )
                : upcoming.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_available_outlined,
                                size: 56,
                                color: cs.onSurface.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text(
                              'No upcoming interviews',
                              style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.4)),
                            ),
                          ],
                        ),
                      )
                    : _InterviewList(
                        interviews: upcoming,
                        title: 'Upcoming',
                      ),
          ),
        ],
      ),
    );
  }
}

class _InterviewList extends StatelessWidget {
  final List<Interview> interviews;
  final String title;

  const _InterviewList({required this.interviews, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 10),
        ...interviews.map((i) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.video_call_outlined,
                      color: Color(0xFF8B5CF6)),
                ),
                title: Text(i.type.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatDt(i.scheduledAt),
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.6))),
                    if (i.platform != null)
                      Text(i.platform!,
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _outcomeColor(i.outcome).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _outcomeLabel(i.outcome),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _outcomeColor(i.outcome)),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  String _formatDt(DateTime dt) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} • '
        '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  String _outcomeLabel(InterviewOutcome o) {
    switch (o) {
      case InterviewOutcome.passed: return 'Passed';
      case InterviewOutcome.failed: return 'Failed';
      case InterviewOutcome.pending: return 'Pending';
      case InterviewOutcome.noFeedback: return 'No Feedback';
    }
  }

  Color _outcomeColor(InterviewOutcome o) {
    switch (o) {
      case InterviewOutcome.passed: return const Color(0xFF22C55E);
      case InterviewOutcome.failed: return const Color(0xFFEF4444);
      case InterviewOutcome.pending: return const Color(0xFF3B82F6);
      case InterviewOutcome.noFeedback: return const Color(0xFF9CA3AF);
    }
  }
}
