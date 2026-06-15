import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/enums.dart';
import '../models/document.dart';
import '../providers/documents_provider.dart';
import '../providers/settings_provider.dart';

/// Tappable field that opens a bottom sheet to pick a resume from the
/// Document Vault. Shows the default resume badge and a shortcut to the vault.
class ResumePickerField extends ConsumerWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;

  const ResumePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Resume',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final resumes = ref
        .watch(documentsNotifierProvider)
        .where((d) => d.type == DocumentType.resume)
        .toList();
    final selected =
        resumes.where((d) => d.id == value).cast<AppDocument?>().firstOrNull;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showPicker(context, ref, resumes),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.description_outlined, size: 20),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        isEmpty: selected == null,
        child: selected == null
            ? null
            : Text(
                _docLabel(selected),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, color: cs.onSurface),
              ),
      ),
    );
  }

  String _docLabel(AppDocument d) =>
      d.version != null && d.version!.isNotEmpty ? '${d.name} · v${d.version}' : d.name;

  void _showPicker(
      BuildContext context, WidgetRef ref, List<AppDocument> resumes) {
    final defaultId = ref.read(settingsNotifierProvider).defaultResumeId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Resume',
                        style:
                            TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/documents');
                      },
                      icon: const Icon(Icons.folder_outlined, size: 16),
                      label: const Text('Manage'),
                    ),
                  ],
                ),
                if (resumes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No resumes yet.\nUpload one from Settings → Document Vault.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.5)),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.block_outlined, size: 20),
                          title: const Text('None'),
                          trailing:
                              value == null ? const Icon(Icons.check) : null,
                          onTap: () {
                            onChanged(null);
                            Navigator.pop(ctx);
                          },
                        ),
                        ...resumes.map((d) => ListTile(
                              leading: const Icon(Icons.description_outlined,
                                  size: 20),
                              title: Text(_docLabel(d),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              subtitle: d.id == defaultId
                                  ? Text('Default',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: cs.primary))
                                  : null,
                              trailing: value == d.id
                                  ? const Icon(Icons.check)
                                  : null,
                              onTap: () {
                                onChanged(d.id);
                                Navigator.pop(ctx);
                              },
                            )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
