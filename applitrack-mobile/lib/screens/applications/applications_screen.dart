import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/applications_provider.dart';
import '../../providers/documents_provider.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/status_colors.dart';
import '../../core/utils/app_display.dart';
import '../../models/job_application.dart';

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  bool _kanbanMode = false;
  ApplicationStatus? _filterStatus;
  String _filterResumeId = '__all__'; // '__all__' | '__none__' | document id

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(applicationsNotifierProvider);
    final resumes = ref
        .watch(documentsNotifierProvider)
        .where((d) => d.type == DocumentType.resume)
        .toList();

    var filtered = _filterStatus == null
        ? all
        : all.where((a) => a.status == _filterStatus).toList();
    if (_filterResumeId != '__all__') {
      filtered = filtered
          .where((a) => _filterResumeId == '__none__'
              ? a.resumeVersionId == null
              : a.resumeVersionId == _filterResumeId)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Applications (${all.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: Icon(
              _kanbanMode ? Icons.view_list_outlined : Icons.view_kanban_outlined,
            ),
            onPressed: () => setState(() => _kanbanMode = !_kanbanMode),
            tooltip: _kanbanMode ? 'List view' : 'Kanban view',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filterStatus == null,
                  onTap: () => setState(() => _filterStatus = null),
                  color: Theme.of(context).colorScheme.primary,
                ),
                ...ApplicationStatus.values.map((s) => _FilterChip(
                      label: s.label,
                      selected: _filterStatus == s,
                      onTap: () => setState(() =>
                          _filterStatus = _filterStatus == s ? null : s),
                      color: statusColor(s),
                    )),
              ],
            ),
          ),
          // Resume filter — only when there are resumes to filter by
          if (resumes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  Icon(Icons.description_outlined,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _filterResumeId,
                      isExpanded: true,
                      isDense: true,
                      underline: const SizedBox(),
                      onChanged: (v) =>
                          setState(() => _filterResumeId = v ?? '__all__'),
                      items: [
                        const DropdownMenuItem(
                            value: '__all__', child: Text('All resumes')),
                        const DropdownMenuItem(
                            value: '__none__', child: Text('No resume')),
                        ...resumes.map((d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(
                                d.version != null && d.version!.isNotEmpty
                                    ? '${d.name} · v${d.version}'
                                    : d.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(
                    isFiltered:
                        _filterStatus != null || _filterResumeId != '__all__')
                : _kanbanMode
                    ? _KanbanView(applications: filtered)
                    : _ListView(applications: filtered),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListView extends ConsumerWidget {
  final List applications;

  const _ListView({required this.applications});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: applications.length,
      itemBuilder: (context, i) {
        final app = applications[i];
        return _ApplicationCard(app: app)
            .animate(delay: Duration(milliseconds: i * 40))
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.06, end: 0, duration: 200.ms,
                curve: Curves.easeOut);
      },
    );
  }
}

class _KanbanView extends StatelessWidget {
  final List applications;

  const _KanbanView({required this.applications});

  @override
  Widget build(BuildContext context) {
    final activeStatuses = ApplicationStatus.values.where((s) => s.isActive).toList();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: activeStatuses.length,
      itemBuilder: (context, i) {
        final status = activeStatuses[i];
        final statusApps = applications
            .where((a) => a.status == status)
            .toList();

        return Container(
          width: 260,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusBgColor(status),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor(status),
                        )),
                    const SizedBox(width: 8),
                    Text(status.label,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: statusColor(status))),
                    const Spacer(),
                    Text('${statusApps.length}',
                        style: TextStyle(
                            fontSize: 13, color: statusColor(status))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: statusApps
                      .map((app) => _ApplicationCard(app: app, compact: true))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ApplicationCard extends ConsumerWidget {
  final JobApplication app;
  final bool compact;

  const _ApplicationCard({required this.app, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/applications/${app.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.displayCompany,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          app.displayRole,
                          style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurface.withValues(alpha: 0.65)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor(app.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      app.status.label,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor(app.status)),
                    ),
                  ),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (app.location != null)
                      _Meta(icon: Icons.location_on_outlined, text: app.location!),
                    const SizedBox(width: 12),
                    _Meta(
                        icon: Icons.source_outlined,
                        text: app.sourceName?.isNotEmpty == true
                            ? app.sourceName!
                            : app.source.label),
                    const Spacer(),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < app.priority ? Icons.circle : Icons.circle_outlined,
                          size: 8,
                          color: i < app.priority
                              ? cs.primary
                              : cs.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isFiltered;

  const _EmptyState({required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.filter_list_off : Icons.work_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No applications match this filter' : 'No applications yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
          ),
          if (!isFiltered) ...[
            const SizedBox(height: 8),
            Text(
              'Tap + Add Job to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
