import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/enums.dart';
import '../../models/career_job.dart';
import '../../providers/applications_provider.dart';
import '../../providers/career_jobs_provider.dart';
import '../../providers/companies_provider.dart';
import '../../services/job_board_service.dart';

class CompanyJobsScreen extends ConsumerStatefulWidget {
  final String companyId;
  const CompanyJobsScreen({super.key, required this.companyId});

  @override
  ConsumerState<CompanyJobsScreen> createState() => _CompanyJobsScreenState();
}

class _CompanyJobsScreenState extends ConsumerState<CompanyJobsScreen> {
  String _search = '';
  String? _location;
  String? _department;
  CareerWorkType? _workType;

  bool _matches(CareerJob j) {
    if (_search.isNotEmpty &&
        !j.title.toLowerCase().contains(_search.toLowerCase())) {
      return false;
    }
    if (_location != null && j.location != _location) return false;
    if (_department != null && j.department != _department) return false;
    if (_workType != null && j.workType != _workType) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final company =
        ref.watch(companiesNotifierProvider.notifier).getById(widget.companyId);
    final jobsAsync = ref.watch(careerJobsProvider(widget.companyId));

    if (company == null) {
      return const Scaffold(body: Center(child: Text('Company not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(company.name, overflow: TextOverflow.ellipsis),
        actions: [
          if (company.careerUrl != null && company.careerUrl!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: 'Open careers page',
              onPressed: () => launchUrl(Uri.parse(company.careerUrl!),
                  mode: LaunchMode.externalApplication),
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/companies/${company.id}/edit'),
          ),
        ],
      ),
      body: !company.provider.fetchable
          ? _CustomFallback(careerUrl: company.careerUrl)
          : jobsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                message: e is JobBoardException
                    ? e.message
                    : 'Could not load jobs.',
                onRetry: () => ref.invalidate(careerJobsProvider(widget.companyId)),
                careerUrl: company.careerUrl,
              ),
              data: (jobs) {
                final filtered = jobs.where(_matches).toList();
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(careerJobsProvider(widget.companyId));
                    await ref.read(careerJobsProvider(widget.companyId).future);
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _FilterBar(
                          jobs: jobs,
                          search: _search,
                          location: _location,
                          department: _department,
                          workType: _workType,
                          resultCount: filtered.length,
                          onSearch: (v) => setState(() => _search = v),
                          onLocation: (v) => setState(() => _location = v),
                          onDepartment: (v) => setState(() => _department = v),
                          onWorkType: (v) => setState(() => _workType = v),
                          onClear: () => setState(() {
                            _search = '';
                            _location = null;
                            _department = null;
                            _workType = null;
                          }),
                        ),
                      ),
                      if (filtered.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No jobs match your filters.'),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          sliver: SliverList.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => _JobCard(
                              job: filtered[i],
                              onAdd: () => _addToApplications(filtered[i]),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _addToApplications(CareerJob job) async {
    final workType = switch (job.workType) {
      CareerWorkType.remote => WorkType.remote,
      CareerWorkType.hybrid => WorkType.hybrid,
      _ => WorkType.onsite,
    };
    await ref.read(applicationsNotifierProvider.notifier).add(
          company: job.companyName,
          role: job.title,
          jobUrl: job.url,
          location: job.location,
          workType: workType,
          source: JobSource.company,
          sourceName: job.companyName,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "${job.title}" to your applications')),
      );
    }
  }
}

class _FilterBar extends StatelessWidget {
  final List<CareerJob> jobs;
  final String search;
  final String? location;
  final String? department;
  final CareerWorkType? workType;
  final int resultCount;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onLocation;
  final ValueChanged<String?> onDepartment;
  final ValueChanged<CareerWorkType?> onWorkType;
  final VoidCallback onClear;

  const _FilterBar({
    required this.jobs,
    required this.search,
    required this.location,
    required this.department,
    required this.workType,
    required this.resultCount,
    required this.onSearch,
    required this.onLocation,
    required this.onDepartment,
    required this.onWorkType,
    required this.onClear,
  });

  List<String> _facet(String? Function(CareerJob) sel) {
    final set = <String>{};
    for (final j in jobs) {
      final v = sel(j);
      if (v != null && v.trim().isNotEmpty) set.add(v.trim());
    }
    final list = set.toList()..sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locations = _facet((j) => j.location);
    final departments = _facet((j) => j.department);
    final workTypes = jobs.map((j) => j.workType).toSet()
      ..remove(CareerWorkType.unknown);
    final hasFilters = search.isNotEmpty ||
        location != null ||
        department != null ||
        workType != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Search roles',
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          // Work type chips
          if (workTypes.isNotEmpty)
            Wrap(
              spacing: 8,
              children: workTypes
                  .map((w) => FilterChip(
                        label: Text(w.label),
                        selected: workType == w,
                        onSelected: (sel) => onWorkType(sel ? w : null),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (departments.isNotEmpty)
                Expanded(
                  child: _FacetDropdown(
                    hint: 'Department',
                    value: department,
                    options: departments,
                    onChanged: onDepartment,
                  ),
                ),
              if (departments.isNotEmpty && locations.isNotEmpty)
                const SizedBox(width: 10),
              if (locations.isNotEmpty)
                Expanded(
                  child: _FacetDropdown(
                    hint: 'Location',
                    value: location,
                    options: locations,
                    onChanged: onLocation,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$resultCount result${resultCount == 1 ? '' : 's'}',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.6)),
              ),
              const Spacer(),
              if (hasFilters)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FacetDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _FacetDropdown({
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      hint: Text(hint, overflow: TextOverflow.ellipsis),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text('All $hint')),
        ...options.map((o) => DropdownMenuItem<String?>(
              value: o,
              child: Text(o, overflow: TextOverflow.ellipsis),
            )),
      ],
      onChanged: onChanged,
    );
  }
}

class _JobCard extends StatelessWidget {
  final CareerJob job;
  final VoidCallback onAdd;
  const _JobCard({required this.job, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (job.location != null && job.location!.isNotEmpty)
                  _Pill(icon: Icons.place_outlined, text: job.location!),
                if (job.department != null && job.department!.isNotEmpty)
                  _Pill(icon: Icons.category_outlined, text: job.department!),
                if (job.workType != CareerWorkType.unknown)
                  _Pill(icon: Icons.laptop_mac_outlined, text: job.workType.label),
                if (job.employmentType != null && job.employmentType!.isNotEmpty)
                  _Pill(icon: Icons.schedule_outlined, text: job.employmentType!),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (job.url != null && job.url!.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(job.url!),
                          mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('View'),
                    ),
                  ),
                if (job.url != null && job.url!.isNotEmpty)
                  const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Track'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: cs.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String? careerUrl;
  const _ErrorView(
      {required this.message, required this.onRetry, this.careerUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
            if (careerUrl != null && careerUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => launchUrl(Uri.parse(careerUrl!),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Open careers page'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomFallback extends StatelessWidget {
  final String? careerUrl;
  const _CustomFallback({this.careerUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public_rounded,
                size: 56, color: cs.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('Custom careers page',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'This company isn\'t on a supported job board, so jobs can\'t be pulled automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 20),
            if (careerUrl != null && careerUrl!.isNotEmpty)
              FilledButton.icon(
                onPressed: () => launchUrl(Uri.parse(careerUrl!),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open careers page'),
              ),
          ],
        ),
      ),
    );
  }
}
