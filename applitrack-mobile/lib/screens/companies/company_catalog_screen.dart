import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/data/company_catalog.dart';
import '../../providers/companies_provider.dart';

/// Browse the built-in catalog of top MNCs, grouped by category, and add them
/// to your tracked companies with one tap.
class CompanyCatalogScreen extends ConsumerStatefulWidget {
  const CompanyCatalogScreen({super.key});

  @override
  ConsumerState<CompanyCatalogScreen> createState() =>
      _CompanyCatalogScreenState();
}

class _CompanyCatalogScreenState extends ConsumerState<CompanyCatalogScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final companies = ref.watch(companiesNotifierProvider);
    final added = {for (final c in companies) c.name.trim().toLowerCase()};
    final cs = Theme.of(context).colorScheme;

    final filtered = _query.isEmpty
        ? kCompanyCatalog
        : kCompanyCatalog
            .where((s) =>
                s.name.toLowerCase().contains(_query.toLowerCase()) ||
                s.tags.any((t) => t.toLowerCase().contains(_query.toLowerCase())))
            .toList();

    // Group by category, preserving enum order.
    final byCat = <CompanyCategory, List<SeedCompany>>{};
    for (final s in filtered) {
      byCat.putIfAbsent(s.category, () => []).add(s);
    }
    final cats = CompanyCategory.values.where(byCat.containsKey).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Catalog'),
        actions: [
          TextButton(
            onPressed: () => _addAll(filtered, added),
            child: const Text('Add all'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search 40+ companies',
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final cat in cats) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 12, 0, 8),
                    child: Text(
                      cat.label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: cs.primary),
                    ),
                  ),
                  ...byCat[cat]!.map((s) => _CatalogTile(
                        seed: s,
                        added: added.contains(s.name.trim().toLowerCase()),
                        onAdd: () async {
                          await ref
                              .read(companiesNotifierProvider.notifier)
                              .addSeed(s);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Added ${s.name}'),
                                  duration: const Duration(seconds: 1)),
                            );
                          }
                        },
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addAll(List<SeedCompany> seeds, Set<String> added) async {
    final notifier = ref.read(companiesNotifierProvider.notifier);
    var count = 0;
    for (final s in seeds) {
      if (!added.contains(s.name.trim().toLowerCase())) {
        await notifier.addSeed(s);
        count++;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $count companies')),
      );
    }
  }
}

class _CatalogTile extends StatelessWidget {
  final SeedCompany seed;
  final bool added;
  final VoidCallback onAdd;

  const _CatalogTile({
    required this.seed,
    required this.added,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fetchable = seed.provider.fetchable;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Text(
                seed.name.isNotEmpty ? seed.name[0].toUpperCase() : '?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: cs.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seed.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        fetchable
                            ? Icons.sync_rounded
                            : Icons.open_in_new_rounded,
                        size: 12,
                        color: fetchable
                            ? const Color(0xFF22C55E)
                            : cs.onSurface.withValues(alpha: 0.45),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fetchable ? 'Live sync' : 'Opens in browser',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            added
                ? const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF22C55E))
                : IconButton.filledTonal(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
          ],
        ),
      ),
    );
  }
}
