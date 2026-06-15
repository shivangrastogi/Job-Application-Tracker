import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/applications_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/enums.dart';
import '../../services/notification_service.dart';

class AddApplicationScreen extends ConsumerStatefulWidget {
  const AddApplicationScreen({super.key});

  @override
  ConsumerState<AddApplicationScreen> createState() => _AddApplicationScreenState();
}

class _AddApplicationScreenState extends ConsumerState<AddApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  ApplicationStatus _status = ApplicationStatus.wishlist;
  WorkType _workType = WorkType.onsite;
  JobSource _source = JobSource.other;
  int _priority = 3;
  bool _loading = false;

  double? _salaryMin;
  double? _salaryMax;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _urlCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final settings = ref.read(settingsNotifierProvider);
      final app = await ref.read(applicationsNotifierProvider.notifier).add(
            company: _companyCtrl.text.trim(),
            role: _roleCtrl.text.trim(),
            status: _status,
            jobUrl: _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
            location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
            workType: _workType,
            salaryMin: _salaryMin,
            salaryMax: _salaryMax,
            source: _source,
            priority: _priority,
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );
      if (settings.notifyFollowUp && _status.isActive) {
        await NotificationService.scheduleFollowUpNudge(
          applicationId: app.id,
          company: app.company,
          role: app.role,
          nudgeAt: DateTime.now()
              .add(Duration(days: settings.followUpDays)),
        );
      }
      if (mounted) context.pushReplacement('/applications/${app.id}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Application'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Company
            TextFormField(
              controller: _companyCtrl,
              decoration: const InputDecoration(
                labelText: 'Company *',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Role
            TextFormField(
              controller: _roleCtrl,
              decoration: const InputDecoration(
                labelText: 'Role / Job Title *',
                prefixIcon: Icon(Icons.work_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Status
            _FieldLabel('Status'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ApplicationStatus.values.map((s) {
                final sel = _status == s;
                return ChoiceChip(
                  label: Text(s.label),
                  selected: sel,
                  onSelected: (_) => setState(() => _status = s),
                  selectedColor: cs.primaryContainer,
                  labelStyle: TextStyle(
                      fontWeight: sel ? FontWeight.w700 : FontWeight.normal),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Source
            _FieldLabel('Source'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: JobSource.values.map((s) {
                final sel = _source == s;
                return ChoiceChip(
                  label: Text(s.label),
                  selected: sel,
                  onSelected: (_) => setState(() => _source = s),
                  selectedColor: cs.primaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Work type
            _FieldLabel('Work Type'),
            Wrap(
              spacing: 8,
              children: WorkType.values.map((w) {
                final sel = _workType == w;
                return ChoiceChip(
                  label: Text(w.label),
                  selected: sel,
                  onSelected: (_) => setState(() => _workType = w),
                  selectedColor: cs.primaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Priority
            _FieldLabel('Priority'),
            Row(
              children: List.generate(5, (i) {
                final filled = i < _priority;
                return GestureDetector(
                  onTap: () => setState(() => _priority = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: filled ? const Color(0xFFF59E0B) : Colors.grey[300],
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Location
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),

            // Job URL
            TextFormField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: 'Job URL',
                prefixIcon: Icon(Icons.link_outlined),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),

            // Salary
            _FieldLabel('Salary Range (INR)'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Min (LPA)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _salaryMin = double.tryParse(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Max (LPA)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _salaryMax = double.tryParse(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notes
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              minLines: 2,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _save,
                child: const Text('Save Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
