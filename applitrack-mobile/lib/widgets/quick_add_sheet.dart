import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/enums.dart';
import '../models/job_application.dart';
import '../providers/applications_provider.dart';
import '../providers/documents_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import 'resume_picker_field.dart';

Future<void> showQuickAddSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: const _QuickAddSheet(),
    ),
  );
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  final _companyCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _sourceNameCtrl = TextEditingController();
  final _companyFocus = FocusNode();
  ApplicationStatus _status = ApplicationStatus.applied;
  JobSource _source = JobSource.other;
  String? _resumeId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Preselect the default resume (if it still exists in the vault)
    final defaultId = ref.read(settingsNotifierProvider).defaultResumeId;
    if (defaultId != null &&
        ref.read(documentsNotifierProvider.notifier).getById(defaultId) !=
            null) {
      _resumeId = defaultId;
    }
    _tryPasteFromClipboard();
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _urlCtrl.dispose();
    _sourceNameCtrl.dispose();
    _companyFocus.dispose();
    super.dispose();
  }

  Future<void> _tryPasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.startsWith('http') && mounted) {
      setState(() => _urlCtrl.text = text);
      _autofillFromUrl(text);
      // Focus company field so user can type immediately
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _companyFocus.requestFocus();
      });
    }
  }

  void _autofillFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final host = uri.host.toLowerCase();

    // Detect source from domain
    JobSource? detectedSource;
    if (host.contains('linkedin')) {
      detectedSource = JobSource.linkedin;
    } else if (host.contains('naukri')) {
      detectedSource = JobSource.naukri;
    } else if (host.contains('indeed')) {
      detectedSource = JobSource.indeed;
    } else if (host.contains('careers') || uri.path.contains('careers')) {
      detectedSource = JobSource.company;
    }

    // Try to pull company from URL path segments (basic heuristic)
    if (host.contains('linkedin')) {
      // linkedin.com/jobs/view/TITLE-at-COMPANY-JOBID
      final seg = uri.pathSegments.lastWhere(
        (s) => s.contains('-'), orElse: () => '');
      if (seg.isNotEmpty) {
        final parts = seg.split('-');
        // "at" separates role from company in LinkedIn URLs
        final atIdx = parts.lastIndexOf('at');
        if (atIdx > 0 && atIdx < parts.length - 2) {
          final role = parts.sublist(0, atIdx)
              .map((p) => _cap(p)).join(' ');
          final company = parts.sublist(atIdx + 1, parts.length - 1)
              .map((p) => _cap(p)).join(' ');
          if (role.isNotEmpty && _roleCtrl.text.isEmpty) {
            _roleCtrl.text = role;
          }
          if (company.isNotEmpty && _companyCtrl.text.isEmpty) {
            _companyCtrl.text = company;
          }
        }
      }
    } else if (host.contains('naukri')) {
      // naukri.com/job-listings-ROLE-COMPANY-...
      final seg = uri.pathSegments.firstWhere(
        (s) => s.startsWith('job-listings'), orElse: () => '');
      if (seg.isNotEmpty) {
        final slug = seg.replaceFirst('job-listings-', '');
        final parts = slug.split('-').map(_cap).toList();
        if (parts.length > 2 && _companyCtrl.text.isEmpty) {
          _companyCtrl.text = parts.take(2).join(' ');
        }
      }
    }

    if (detectedSource != null) _source = detectedSource;
    setState(() {});
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  bool get _canSave =>
      _companyCtrl.text.trim().isNotEmpty && _roleCtrl.text.trim().isNotEmpty;

  // Custom name only makes sense for career pages / other platforms
  bool get _showSourceName =>
      _source == JobSource.company || _source == JobSource.other;

  Future<JobApplication> _saveApplication() {
    return ref.read(applicationsNotifierProvider.notifier).add(
          company: _companyCtrl.text.trim(),
          role: _roleCtrl.text.trim(),
          status: _status,
          jobUrl: _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
          source: _source,
          sourceName: _showSourceName && _sourceNameCtrl.text.trim().isNotEmpty
              ? _sourceNameCtrl.text.trim()
              : null,
          resumeVersionId: _resumeId,
        );
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final settings = ref.read(settingsNotifierProvider);
      final app = await _saveApplication();
      if (settings.notifyFollowUp && _status.isActive) {
        await NotificationService.scheduleFollowUpNudge(
          applicationId: app.id,
          company: app.company,
          role: app.role,
          nudgeAt: DateTime.now().add(Duration(days: settings.followUpDays)),
        );
      }
      if (mounted) {
        Navigator.pop(context);
        context.push('/applications/${app.id}');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAndOpenFull() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final app = await _saveApplication();
      if (mounted) {
        Navigator.pop(context);
        context.push('/applications/${app.id}/edit');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text('Quick Add Job',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Minimum info — add full details later.',
                style: TextStyle(
                    fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 20),

            // URL field with paste button
            TextField(
              controller: _urlCtrl,
              decoration: InputDecoration(
                labelText: 'Job URL (optional)',
                hintText: 'Paste job link…',
                prefixIcon: const Icon(Icons.link_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste_rounded, size: 18),
                  tooltip: 'Paste from clipboard',
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    final text = data?.text?.trim() ?? '';
                    if (text.isNotEmpty) {
                      setState(() => _urlCtrl.text = text);
                      if (text.startsWith('http')) _autofillFromUrl(text);
                    }
                  },
                ),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              onChanged: (v) {
                if (v.startsWith('http')) _autofillFromUrl(v);
              },
            ),
            const SizedBox(height: 14),

            // Company + Role (stacked — full width so labels never crowd)
            TextField(
              controller: _companyCtrl,
              focusNode: _companyFocus,
              decoration: const InputDecoration(
                labelText: 'Company *',
                prefixIcon: Icon(Icons.business_outlined, size: 20),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roleCtrl,
              decoration: const InputDecoration(
                labelText: 'Role *',
                prefixIcon: Icon(Icons.work_outline_rounded, size: 20),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Platform / source
            _SectionLabel('Platform', cs),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: JobSource.values.map((s) {
                  final selected = _source == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label:
                          Text(s.label, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) => setState(() => _source = s),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_showSourceName) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _sourceNameCtrl,
                decoration: InputDecoration(
                  labelText: _source == JobSource.company
                      ? 'Career page name (optional)'
                      : 'Platform name (optional)',
                  hintText: _source == JobSource.company
                      ? 'e.g. Google Careers'
                      : 'e.g. Wellfound, Instahyre…',
                  prefixIcon: const Icon(Icons.public_outlined, size: 20),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
            const SizedBox(height: 16),

            // Resume used
            ResumePickerField(
              value: _resumeId,
              onChanged: (id) => setState(() => _resumeId = id),
              label: 'Resume used',
            ),
            const SizedBox(height: 16),

            // Status chips
            _SectionLabel('Status', cs),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ApplicationStatus.wishlist,
                  ApplicationStatus.applied,
                  ApplicationStatus.phoneScreen,
                  ApplicationStatus.technicalRound,
                ].map((s) {
                  final selected = _status == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label:
                          Text(s.label, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) => setState(() => _status = s),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Actions — stacked full-width so labels never wrap
            FilledButton.icon(
              onPressed: _canSave && !_saving ? _save : null,
              icon: _saving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_saving ? 'Saving…' : 'Save'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _canSave && !_saving ? _saveAndOpenFull : null,
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46)),
              child: const Text('Save & Add Full Details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final ColorScheme cs;
  const _SectionLabel(this.text, this.cs);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withValues(alpha: 0.6)));
  }
}
