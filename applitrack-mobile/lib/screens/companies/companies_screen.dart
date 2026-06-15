import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/enums.dart';
import '../../models/company.dart';
import '../../providers/companies_provider.dart';
import '../../services/job_alerts_service.dart';

class CompaniesScreen extends ConsumerStatefulWidget {
  const CompaniesScreen({super.key});

  @override
  ConsumerState<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends ConsumerState<CompaniesScreen> {
  String _query = '';
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Best-effort, throttled new-jobs check when the tab opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final companies = ref.read(companiesNotifierProvider);
      if (companies.isNotEmpty) {
        JobAlertsService.maybeCheckOnLaunch(companies);
      }
    });
  }

  Future<void> _checkNow() async {
    final companies = ref.read(companiesNotifierProvider);
    final fetchable = companies.where((c) => c.provider.fetchable).toList();
    if (fetchable.isEmpty) {
      _snack('No sync-enabled companies to check yet');
      return;
    }
    setState(() => _checking = true);
    final results = await JobAlertsService.checkAll(fetchable, notify: true);
    // Refresh stored job counts in the list.
    ref.invalidate(companiesNotifierProvider);
    if (!mounted) return;
    setState(() => _checking = false);
    final totalNew = results.fold<int>(0, (a, r) => a + r.newCount);
    _snack(totalNew == 0
        ? 'No new jobs since last check'
        : '$totalNew new job${totalNew == 1 ? '' : 's'} found!');
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final companies = ref.watch(companiesNotifierProvider);
    final filtered = _query.isEmpty
        ? companies
        : companies
            .where((c) =>
                c.name.toLowerCase().contains(_query.toLowerCase()) ||
                c.tags.any((t) => t.toLowerCase().contains(_query.toLowerCase())))
            .toList();

    // Group by category.
    final byCat = <CompanyCategory, List<Company>>{};
    for (final c in filtered) {
      byCat.putIfAbsent(c.category, () => []).add(c);
    }
    final cats = CompanyCategory.values.where(byCat.containsKey).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Companies (${companies.length})'),
        actions: [
          if (companies.any((c) => c.provider.fetchable))
            IconButton(
              tooltip: 'Check for new jobs',
              onPressed: _checking ? null : _checkNow,
              icon: _checking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4))
                  : const Icon(Icons.notifications_active_outlined),
            ),
          IconButton(
            tooltip: 'Catalog',
            onPressed: () => context.push('/companies/catalog'),
            icon: const Icon(Icons.auto_awesome_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/companies/add'),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Add MNC'),
      ),
      body: companies.isEmpty
          ? _EmptyState(
              onAdd: () => context.push('/companies/add'),
              onCatalog: () => context.push('/companies/catalog'),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search companies or tags',
                      prefixIcon: const Icon(Icons.search_rounded),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      for (final cat in cats) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 12, 0, 8),
                          child: Text(
                            '${cat.label}  ·  ${byCat[cat]!.length}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        ...byCat[cat]!.asMap().entries.map((e) =>
                            _CompanyCard(company: e.value)
                                .animate()
                                .fadeIn(duration: 180.ms, delay: (e.key * 20).ms)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;
  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials =
        company.name.isNotEmpty ? company.name.trim()[0].toUpperCase() : '?';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/companies/${company.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: cs.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _ProviderBadge(provider: company.provider),
                        if (company.lastJobCount > 0) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${company.lastJobCount} jobs',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.55)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderBadge extends StatelessWidget {
  final AtsProvider provider;
  const _ProviderBadge({required this.provider});

  @override
  Widget build(BuildContext context) {
    final fetchable = provider.fetchable;
    final color = fetchable ? const Color(0xFF22C55E) : const Color(0xFF9E9E9E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        fetchable ? provider.label : 'Link',
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onCatalog;
  const _EmptyState({required this.onAdd, required this.onCatalog});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment_rounded,
                size: 64, color: cs.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: 16),
            const Text('No companies yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Add MNCs and pull their latest openings right here — or start from our catalog of 40+ top companies.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCatalog,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Browse catalog'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_business_rounded),
              label: const Text('Add manually'),
            ),
          ],
        ),
      ),
    );
  }
}
