import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/applications_provider.dart';
import '../../providers/documents_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/url_company.dart';

/// Paste many job links at once → one Wishlist application per link, with the
/// company guessed from the URL, the default resume attached, and duplicates
/// (already tracked or repeated in the batch) skipped.
class BulkAddScreen extends ConsumerStatefulWidget {
  const BulkAddScreen({super.key});

  @override
  ConsumerState<BulkAddScreen> createState() => _BulkAddScreenState();
}

class _BulkAddScreenState extends ConsumerState<BulkAddScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final lines = _ctrl.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (lines.isEmpty) return;
    setState(() => _loading = true);

    final apps = ref.read(applicationsNotifierProvider);
    final existing = <String>{
      for (final a in apps)
        if (a.jobUrl != null) normalizeUrl(a.jobUrl),
    };
    var defaultResume = ref.read(settingsNotifierProvider).defaultResumeId;
    if (defaultResume != null &&
        ref.read(documentsNotifierProvider.notifier).getById(defaultResume) ==
            null) {
      defaultResume = null;
    }

    final notifier = ref.read(applicationsNotifierProvider.notifier);
    final seen = <String>{};
    var added = 0, skipped = 0, invalid = 0;
    for (final line in lines) {
      final norm = normalizeUrl(line);
      if (norm.isEmpty) {
        invalid++;
        continue;
      }
      if (existing.contains(norm) || seen.contains(norm)) {
        skipped++;
        continue;
      }
      seen.add(norm);
      await notifier.add(
        company: guessCompanyFromUrl(line),
        role: '',
        jobUrl: line,
        status: ApplicationStatus.wishlist,
        resumeVersionId: defaultResume,
      );
      added++;
    }

    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Added $added'
          '${skipped > 0 ? ' · skipped $skipped already tracked' : ''}'
          '${invalid > 0 ? ' · $invalid not valid' : ''}'),
    ));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk add jobs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Paste one job link per line. We create a Wishlist application for '
              'each, guess the company, attach your default resume, and skip '
              'links you already track.',
              style: TextStyle(
                  fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'https://boards.greenhouse.io/stripe/jobs/123\n'
                      'https://jobs.lever.co/cred/abc\n'
                      'https://www.linkedin.com/jobs/view/456',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _loading ? null : _run,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Add all'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
