import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/applications_provider.dart';
import '../../models/job_application.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/status_colors.dart';

enum _SortBy { dateAdded, dateUpdated, company, priority }

class _FilterState {
  final Set<ApplicationStatus> statuses;
  final Set<WorkType> workTypes;
  final Set<JobSource> sources;
  final int? minPriority;
  final _SortBy sortBy;
  final bool sortAsc;

  const _FilterState({
    this.statuses = const {},
    this.workTypes = const {},
    this.sources = const {},
    this.minPriority,
    this.sortBy = _SortBy.dateAdded,
    this.sortAsc = false,
  });

  int get activeCount =>
      statuses.length + workTypes.length + sources.length + (minPriority != null ? 1 : 0);

  bool get hasFilters => activeCount > 0;

  _FilterState copyWith({
    Set<ApplicationStatus>? statuses,
    Set<WorkType>? workTypes,
    Set<JobSource>? sources,
    Object? minPriority = _sentinel,
    _SortBy? sortBy,
    bool? sortAsc,
  }) {
    return _FilterState(
      statuses: statuses ?? this.statuses,
      workTypes: workTypes ?? this.workTypes,
      sources: sources ?? this.sources,
      minPriority: minPriority == _sentinel
          ? this.minPriority
          : minPriority as int?,
      sortBy: sortBy ?? this.sortBy,
      sortAsc: sortAsc ?? this.sortAsc,
    );
  }

  static const _sentinel = Object();
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  _FilterState _filters = const _FilterState();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<JobApplication> _applyFilters(List<JobApplication> all) {
    var results = all.where((a) {
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        final match = a.company.toLowerCase().contains(q) ||
            a.role.toLowerCase().contains(q) ||
            (a.notes?.toLowerCase().contains(q) ?? false) ||
            a.tags.any((t) => t.toLowerCase().contains(q)) ||
            (a.location?.toLowerCase().contains(q) ?? false);
        if (!match) return false;
      }
      if (_filters.statuses.isNotEmpty &&
          !_filters.statuses.contains(a.status)) { return false; }
      if (_filters.workTypes.isNotEmpty &&
          !_filters.workTypes.contains(a.workType)) { return false; }
      if (_filters.sources.isNotEmpty &&
          !_filters.sources.contains(a.source)) { return false; }
      if (_filters.minPriority != null && a.priority < _filters.minPriority!) {
        return false;
      }
      return true;
    }).toList();

    results.sort((a, b) {
      int cmp;
      switch (_filters.sortBy) {
        case _SortBy.dateAdded:
          cmp = a.createdAt.compareTo(b.createdAt);
        case _SortBy.dateUpdated:
          cmp = a.updatedAt.compareTo(b.updatedAt);
        case _SortBy.company:
          cmp = a.company.toLowerCase().compareTo(b.company.toLowerCase());
        case _SortBy.priority:
          cmp = a.priority.compareTo(b.priority);
      }
      return _filters.sortAsc ? cmp : -cmp;
    });

    return results;
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterPanel(
        initial: _filters,
        onApply: (f) => setState(() => _filters = f),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(applicationsNotifierProvider);
    final results = _applyFilters(all);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search company, role, notes...',
            border: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _ctrl.clear();
                setState(() => _query = '');
              },
            ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_outlined),
                onPressed: _showFilterPanel,
                tooltip: 'Filters & Sort',
              ),
              if (_filters.activeCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _filters.activeCount.toString(),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_filters.hasFilters || _query.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: cs.surfaceContainerHighest,
              child: Row(
                children: [
                  Text(
                    '${results.length} result${results.length == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                  const Spacer(),
                  if (_filters.hasFilters)
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _filters = const _FilterState()),
                      icon: const Icon(Icons.clear, size: 14),
                      label: const Text('Clear filters',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8)),
                    ),
                ],
              ),
            ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 56,
                            color: cs.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty && !_filters.hasFilters
                              ? 'Start typing to search'
                              : 'No results found',
                          style: TextStyle(
                              color:
                                  cs.onSurface.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final app = results[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          onTap: () =>
                              context.push('/applications/${app.id}'),
                          title: Text(app.company,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(app.role),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(app.source.label,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: cs.onSurface
                                              .withValues(alpha: 0.5))),
                                  if (app.location != null) ...[
                                    Text(' · ',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: cs.onSurface
                                                .withValues(alpha: 0.4))),
                                    Text(app.location!,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: cs.onSurface
                                                .withValues(alpha: 0.5))),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
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
                              const SizedBox(height: 4),
                              Text(
                                '★' * app.priority,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber[700]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Filter panel ───────────────────────────

class _FilterPanel extends StatefulWidget {
  final _FilterState initial;
  final void Function(_FilterState) onApply;
  const _FilterPanel({required this.initial, required this.onApply});

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late _FilterState _local;

  @override
  void initState() {
    super.initState();
    _local = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                const Text('Filter & Sort',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (_local.hasFilters)
                  TextButton(
                    onPressed: () =>
                        setState(() => _local = const _FilterState()),
                    child: const Text('Reset'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                // Sort
                _PanelSection(
                  title: 'Sort By',
                  child: Column(
                    children: [
                      Row(
                        children: _SortBy.values.map((s) {
                          final sel = _local.sortBy == s;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _local = _local.copyWith(sortBy: s)),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? cs.primaryContainer
                                      : cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _sortLabel(s),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                      color: sel ? cs.primary : cs.onSurface),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _OrderButton(
                            label: 'Newest first',
                            selected: !_local.sortAsc,
                            onTap: () => setState(
                                () => _local = _local.copyWith(sortAsc: false)),
                          ),
                          const SizedBox(width: 8),
                          _OrderButton(
                            label: 'Oldest first',
                            selected: _local.sortAsc,
                            onTap: () => setState(
                                () => _local = _local.copyWith(sortAsc: true)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Status
                _PanelSection(
                  title: 'Status',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ApplicationStatus.values.map((s) {
                      final sel = _local.statuses.contains(s);
                      return GestureDetector(
                        onTap: () {
                          final next = Set<ApplicationStatus>.from(
                              _local.statuses);
                          sel ? next.remove(s) : next.add(s);
                          setState(
                              () => _local = _local.copyWith(statuses: next));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? statusColor(s)
                                : statusBgColor(s),
                            borderRadius: BorderRadius.circular(20),
                            border: sel
                                ? null
                                : Border.all(
                                    color: statusColor(s).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            s.label,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : statusColor(s)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Work type
                _PanelSection(
                  title: 'Work Type',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: WorkType.values.map((w) {
                      final sel = _local.workTypes.contains(w);
                      return FilterChip(
                        label: Text(w.label),
                        selected: sel,
                        onSelected: (_) {
                          final next =
                              Set<WorkType>.from(_local.workTypes);
                          sel ? next.remove(w) : next.add(w);
                          setState(() =>
                              _local = _local.copyWith(workTypes: next));
                        },
                        selectedColor: cs.primaryContainer,
                        labelStyle: TextStyle(
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.normal),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Source
                _PanelSection(
                  title: 'Source',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: JobSource.values.map((s) {
                      final sel = _local.sources.contains(s);
                      return FilterChip(
                        label: Text(s.label),
                        selected: sel,
                        onSelected: (_) {
                          final next =
                              Set<JobSource>.from(_local.sources);
                          sel ? next.remove(s) : next.add(s);
                          setState(() =>
                              _local = _local.copyWith(sources: next));
                        },
                        selectedColor: cs.primaryContainer,
                        labelStyle: TextStyle(
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.normal),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Min priority
                _PanelSection(
                  title: 'Minimum Priority',
                  child: Row(
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      final sel = _local.minPriority == star;
                      return GestureDetector(
                        onTap: () => setState(() => _local = _local.copyWith(
                            minPriority: sel ? null : star)),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.star,
                            size: 28,
                            color: ((_local.minPriority ?? 0) >= star)
                                ? Colors.amber[600]
                                : cs.onSurface.withValues(alpha: 0.2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_local);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(_SortBy s) {
    switch (s) {
      case _SortBy.dateAdded: return 'Added';
      case _SortBy.dateUpdated: return 'Updated';
      case _SortBy.company: return 'Company';
      case _SortBy.priority: return 'Priority';
    }
  }
}

class _PanelSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _PanelSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6))),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _OrderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OrderButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.normal,
                  color: selected ? cs.primary : cs.onSurface)),
        ),
      ),
    );
  }
}
