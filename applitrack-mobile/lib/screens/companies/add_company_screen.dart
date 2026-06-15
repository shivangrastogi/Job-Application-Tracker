import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/enums.dart';
import '../../models/company.dart';
import '../../providers/companies_provider.dart';
import '../../services/job_board_service.dart';

class AddCompanyScreen extends ConsumerStatefulWidget {
  /// When non-null, the screen edits an existing company instead of creating one.
  final String? companyId;
  const AddCompanyScreen({super.key, this.companyId});

  @override
  ConsumerState<AddCompanyScreen> createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends ConsumerState<AddCompanyScreen> {
  final _nameCtrl = TextEditingController();
  final _pasteCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  // Amazon
  final _azLocCtrl = TextEditingController(text: 'India');
  final _azCountryCtrl = TextEditingController(text: 'IND');
  final _azQueryCtrl = TextEditingController();
  // Workday
  final _wdTenantCtrl = TextEditingController();
  final _wdDcCtrl = TextEditingController();
  final _wdSiteCtrl = TextEditingController();
  final _wdQueryCtrl = TextEditingController();

  AtsProvider _provider = AtsProvider.greenhouse;
  CompanyCategory _category = CompanyCategory.other;
  Company? _existing;
  String? _detectMessage;

  @override
  void initState() {
    super.initState();
    final id = widget.companyId;
    if (id != null) {
      final c = ref.read(companiesNotifierProvider.notifier).getById(id);
      if (c != null) {
        _existing = c;
        _nameCtrl.text = c.name;
        _slugCtrl.text = c.slug ?? '';
        _urlCtrl.text = c.careerUrl ?? '';
        _locationCtrl.text = c.location ?? '';
        _tagsCtrl.text = c.tags.join(', ');
        _provider = c.provider;
        _category = c.category;
        _azLocCtrl.text = c.config['loc_query'] ?? 'India';
        _azCountryCtrl.text = c.config['country'] ?? 'IND';
        _azQueryCtrl.text = c.config['query'] ?? '';
        _wdTenantCtrl.text = c.config['tenant'] ?? '';
        _wdDcCtrl.text = c.config['dc'] ?? '';
        _wdSiteCtrl.text = c.config['site'] ?? '';
        _wdQueryCtrl.text = c.config['query'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _pasteCtrl, _slugCtrl, _urlCtrl, _locationCtrl, _tagsCtrl,
      _azLocCtrl, _azCountryCtrl, _azQueryCtrl,
      _wdTenantCtrl, _wdDcCtrl, _wdSiteCtrl, _wdQueryCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _detect() {
    final raw = _pasteCtrl.text.trim();
    if (raw.isEmpty) return;
    final result = JobBoardService.detectFromUrl(raw);
    if (result == null) {
      setState(() {
        _provider = AtsProvider.custom;
        _urlCtrl.text = raw;
        _detectMessage =
            "Couldn't recognise that platform — saved as an open-in-browser link.";
      });
      return;
    }
    setState(() {
      _provider = result.provider;
      if (result.slug != null) _slugCtrl.text = result.slug!;
      final cfg = result.config;
      if (cfg.containsKey('loc_query')) _azLocCtrl.text = cfg['loc_query']!;
      if (cfg.containsKey('country')) _azCountryCtrl.text = cfg['country']!;
      if (cfg.containsKey('query')) _azQueryCtrl.text = cfg['query']!;
      if (cfg.containsKey('tenant')) _wdTenantCtrl.text = cfg['tenant']!;
      if (cfg.containsKey('dc')) _wdDcCtrl.text = cfg['dc']!;
      if (cfg.containsKey('site')) _wdSiteCtrl.text = cfg['site']!;
      _urlCtrl.text = raw;
      _detectMessage = 'Detected ${result.provider.label} — live sync enabled.';
    });
  }

  Map<String, String> _buildConfig() {
    switch (_provider) {
      case AtsProvider.amazon:
        return {
          'loc_query': _azLocCtrl.text.trim().isEmpty ? 'India' : _azLocCtrl.text.trim(),
          'country': _azCountryCtrl.text.trim().isEmpty ? 'IND' : _azCountryCtrl.text.trim(),
          if (_azQueryCtrl.text.trim().isNotEmpty) 'query': _azQueryCtrl.text.trim(),
        };
      case AtsProvider.workday:
        return {
          'tenant': _wdTenantCtrl.text.trim(),
          'dc': _wdDcCtrl.text.trim(),
          'site': _wdSiteCtrl.text.trim(),
          if (_wdQueryCtrl.text.trim().isNotEmpty) 'query': _wdQueryCtrl.text.trim(),
        };
      default:
        return const {};
    }
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Company name is required');
      return;
    }
    final slug = _slugCtrl.text.trim();
    final needsSlug = _provider.fetchable &&
        _provider != AtsProvider.amazon &&
        _provider != AtsProvider.workday;
    if (needsSlug && slug.isEmpty) {
      _snack('${_provider.label} needs a slug to fetch jobs');
      return;
    }
    if (_provider == AtsProvider.workday &&
        (_wdTenantCtrl.text.trim().isEmpty ||
            _wdDcCtrl.text.trim().isEmpty ||
            _wdSiteCtrl.text.trim().isEmpty)) {
      _snack('Workday needs tenant, data-center and site');
      return;
    }
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final config = _buildConfig();
    final url = _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim();
    final loc = _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim();
    final notifier = ref.read(companiesNotifierProvider.notifier);
    if (_existing != null) {
      notifier.update(_existing!.copyWith(
        name: name,
        provider: _provider,
        slug: slug.isEmpty ? null : slug,
        careerUrl: url,
        location: loc,
        category: _category,
        tags: tags,
        config: config,
      ));
    } else {
      notifier.add(
        name: name,
        provider: _provider,
        slug: slug.isEmpty ? null : slug,
        careerUrl: url,
        location: loc,
        category: _category,
        tags: tags,
        config: config,
      );
    }
    context.pop();
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final editing = _existing != null;
    final needsSlug = _provider.fetchable &&
        _provider != AtsProvider.amazon &&
        _provider != AtsProvider.workday;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Company' : 'Add MNC')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Paste / correct URL --------------------------------------
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_fix_high_rounded, size: 18, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(editing ? 'Fix / paste careers URL' : 'Paste careers URL',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _pasteCtrl,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  onSubmitted: (_) => _detect(),
                  decoration: InputDecoration(
                    hintText: 'https://boards.greenhouse.io/stripe',
                    isDense: true,
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: TextButton(
                      onPressed: _detect,
                      child: const Text('Detect'),
                    ),
                  ),
                ),
                if (_detectMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_detectMessage!,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: cs.onSurface.withValues(alpha: 0.75))),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Company name *',
              hintText: 'e.g. Stripe',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // --- Category --------------------------------------------------
          _SectionLabel('Category'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CompanyCategory.values
                .map((c) => ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // --- Provider --------------------------------------------------
          _SectionLabel('Careers source'),
          const SizedBox(height: 4),
          Text(
            'Auto-set when you paste a URL, or pick manually.',
            style: TextStyle(
                fontSize: 12.5, color: cs.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AtsProvider.values
                .map((p) => ChoiceChip(
                      label: Text(p.label),
                      selected: _provider == p,
                      onSelected: (_) => setState(() => _provider = p),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // --- Provider-specific fields ----------------------------------
          if (needsSlug)
            TextField(
              controller: _slugCtrl,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: '${_provider.label} slug *',
                helperText: _provider.slugHint,
                helperMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
            ),
          if (_provider == AtsProvider.amazon) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _azLocCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Location', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _azCountryCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Country', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _azQueryCtrl,
              decoration: const InputDecoration(
                labelText: 'Keyword (optional)',
                hintText: 'e.g. software development engineer',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          if (_provider == AtsProvider.workday) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wdTenantCtrl,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        labelText: 'Tenant *',
                        hintText: 'nvidia',
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _wdDcCtrl,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        labelText: 'DC *',
                        hintText: 'wd5',
                        border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wdSiteCtrl,
              autocorrect: false,
              decoration: const InputDecoration(
                  labelText: 'Site *',
                  hintText: 'NVIDIAExternalCareerSite',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wdQueryCtrl,
              decoration: const InputDecoration(
                  labelText: 'Keyword (optional)',
                  hintText: 'e.g. engineer',
                  border: OutlineInputBorder()),
            ),
          ],
          if (_provider == AtsProvider.custom)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This page can\'t be auto-synced. We\'ll open the careers URL below in the browser.',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: cs.onSurface.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          TextField(
            controller: _urlCtrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText:
                  _provider.fetchable ? 'Careers URL (optional)' : 'Careers URL',
              hintText: 'https://company.com/careers',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(
              labelText: 'HQ / Location (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tagsCtrl,
            decoration: const InputDecoration(
              labelText: 'Tags (comma separated)',
              hintText: 'India, Remote, Dream',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Text(editing ? 'Save Changes' : 'Add Company'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700));
  }
}
