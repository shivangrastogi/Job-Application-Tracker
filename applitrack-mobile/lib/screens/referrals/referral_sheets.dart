import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../models/referral.dart';
import '../../models/referral_source.dart';
import '../../providers/referrals_provider.dart';
import '../../providers/settings_provider.dart';

Widget _wrap(BuildContext context, Widget child) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: child,
    );

Future<void> _show(BuildContext context, Widget child) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _wrap(context, child),
  );
}

// ===========================================================================
Future<void> showAddSourceSheet(BuildContext context,
        {ReferralSource? existing}) =>
    _show(context, _SourceSheet(existing: existing));

class _SourceSheet extends ConsumerStatefulWidget {
  final ReferralSource? existing;
  const _SourceSheet({this.existing});
  @override
  ConsumerState<_SourceSheet> createState() => _SourceSheetState();
}

class _SourceSheetState extends ConsumerState<_SourceSheet> {
  late final _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
  late final _urlCtrl = TextEditingController(text: widget.existing?.url ?? '');
  late final _templateCtrl =
      TextEditingController(text: widget.existing?.formTemplate ?? '');
  late final _notesCtrl =
      TextEditingController(text: widget.existing?.notes ?? '');
  late ReferralSourceType _type =
      widget.existing?.type ?? ReferralSourceType.group;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _templateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }
    final notifier = ref.read(referralSourcesNotifierProvider.notifier);
    final url = _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim();
    final template = _type.isForm && _templateCtrl.text.trim().isNotEmpty
        ? _templateCtrl.text.trim()
        : null;
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
    if (widget.existing != null) {
      notifier.update(widget.existing!.copyWith(
          name: name, type: _type, url: url, formTemplate: template, notes: notes));
    } else {
      notifier.add(
          name: name, type: _type, url: url, formTemplate: template, notes: notes);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing == null ? 'New Group / Form' : 'Edit Source',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g. Tech Referrals (Telegram)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ReferralSourceType.values
                  .map((t) => ChoiceChip(
                        label: Text(t.label),
                        selected: _type == t,
                        onSelected: (_) => setState(() => _type = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(
                  labelText: _type.isForm ? 'Form URL' : 'Group / profile link',
                  hintText: 'https://…',
                  border: const OutlineInputBorder()),
            ),
            if (_type.isForm) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _templateCtrl,
                maxLines: 2,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Prefilled link template (optional)',
                  helperText:
                      'Paste a Google Forms "pre-filled link" and replace your answers with {name} {email} {phone} {linkedin} {resume} {company} {role}',
                  helperMaxLines: 4,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tip: in Google Forms → ⋮ → Get pre-filled link, fill sample answers, then swap them for the tokens above.',
                style: TextStyle(
                    fontSize: 11.5, color: cs.onSurface.withValues(alpha: 0.6)),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                  labelText: 'Notes (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text('Save')),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
Future<void> showAddReferralSheet(BuildContext context, {Referral? existing}) =>
    _show(context, _ReferralSheet(existing: existing));

class _ReferralSheet extends ConsumerStatefulWidget {
  final Referral? existing;
  const _ReferralSheet({this.existing});
  @override
  ConsumerState<_ReferralSheet> createState() => _ReferralSheetState();
}

class _ReferralSheetState extends ConsumerState<_ReferralSheet> {
  late final _companyCtrl =
      TextEditingController(text: widget.existing?.company ?? '');
  late final _roleCtrl = TextEditingController(text: widget.existing?.role ?? '');
  late final _urlCtrl =
      TextEditingController(text: widget.existing?.jobUrl ?? '');
  late final _referrerCtrl =
      TextEditingController(text: widget.existing?.referrerName ?? '');
  late String? _sourceId = widget.existing?.sourceId;
  late ReferralStatus _status = widget.existing?.status ?? ReferralStatus.requested;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _urlCtrl.dispose();
    _referrerCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final company = _companyCtrl.text.trim();
    if (company.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Company is required')));
      return;
    }
    final notifier = ref.read(referralsNotifierProvider.notifier);
    final role = _roleCtrl.text.trim().isEmpty ? null : _roleCtrl.text.trim();
    final url = _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim();
    final referrer =
        _referrerCtrl.text.trim().isEmpty ? null : _referrerCtrl.text.trim();
    if (widget.existing != null) {
      notifier.update(widget.existing!.copyWith(
        company: company,
        role: role,
        jobUrl: url,
        referrerName: referrer,
        sourceId: _sourceId,
        status: _status,
      ));
    } else {
      notifier.add(
        company: company,
        role: role,
        jobUrl: url,
        referrerName: referrer,
        sourceId: _sourceId,
        status: _status,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final sources = ref.watch(referralSourcesNotifierProvider);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing == null ? 'New Referral Request' : 'Edit Request',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _companyCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Company *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Role', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _sourceId,
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: 'Via group / form', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('None')),
                ...sources.map((s) => DropdownMenuItem<String?>(
                    value: s.id,
                    child: Text(s.name, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) => setState(() => _sourceId = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _referrerCtrl,
              decoration: const InputDecoration(
                  labelText: 'Referrer name (optional)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                  labelText: 'Job URL (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ReferralStatus.values
                  .map((s) => ChoiceChip(
                        label: Text(s.label),
                        selected: _status == s,
                        onSelected: (_) => setState(() => _status = s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text('Save')),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
Future<void> showReferralProfileSheet(BuildContext context) =>
    _show(context, const _ProfileSheet());

class _ProfileSheet extends ConsumerStatefulWidget {
  const _ProfileSheet();
  @override
  ConsumerState<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<_ProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _linkedin;
  late final TextEditingController _resume;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsNotifierProvider);
    _name = TextEditingController(text: s.referralName ?? '');
    _email = TextEditingController(text: s.referralEmail ?? '');
    _phone = TextEditingController(text: s.referralPhone ?? '');
    _linkedin = TextEditingController(text: s.referralLinkedin ?? '');
    _resume = TextEditingController(text: s.referralResumeUrl ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _linkedin, _resume]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    ref.read(settingsNotifierProvider.notifier).setReferralProfile(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          linkedin: _linkedin.text.trim(),
          resumeUrl: _resume.text.trim(),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My referral details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Used to auto-fill Google Form referral links via {name}, {email}, … tokens.',
              style: TextStyle(
                  fontSize: 12.5, color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            _field(_name, 'Full name'),
            _field(_email, 'Email', keyboard: TextInputType.emailAddress),
            _field(_phone, 'Phone', keyboard: TextInputType.phone),
            _field(_linkedin, 'LinkedIn URL', keyboard: TextInputType.url),
            _field(_resume, 'Resume link', keyboard: TextInputType.url),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text('Save')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        autocorrect: false,
        decoration:
            InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}
