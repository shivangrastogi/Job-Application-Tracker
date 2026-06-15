import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/document.dart';
import '../../providers/documents_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/enums.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(documentsNotifierProvider);
    final defaultResumeId =
        ref.watch(settingsNotifierProvider).defaultResumeId;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Document Vault')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDocSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Document'),
      ),
      body: docs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_outlined,
                      size: 64, color: cs.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text('No documents yet',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4))),
                  const SizedBox(height: 8),
                  Text('Upload your resume or cover letter to get started',
                      style: TextStyle(
                          fontSize: 13, color: cs.onSurface.withValues(alpha: 0.3))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final doc = docs[i];
                final isDefault = doc.id == defaultResumeId;
                final hasFile = doc.filePath != null;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: hasFile ? () => _openFile(context, doc) : null,
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _docColor(doc.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_docIcon(doc.type),
                          color: _docColor(doc.type)),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(doc.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Default',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: cs.primary)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      [
                        doc.type.label,
                        if (doc.version != null) 'v${doc.version}',
                        hasFile ? _fileExt(doc.filePath!) : 'No file attached',
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (action) =>
                          _onMenuAction(context, ref, doc, action),
                      itemBuilder: (_) => [
                        if (hasFile)
                          const PopupMenuItem(
                            value: 'open',
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.open_in_new, size: 20),
                              title: Text('Open'),
                            ),
                          ),
                        if (hasFile)
                          const PopupMenuItem(
                            value: 'share',
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.ios_share, size: 20),
                              title: Text('Share / Download'),
                            ),
                          ),
                        if (doc.type == DocumentType.resume)
                          PopupMenuItem(
                            value: 'default',
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                  isDefault ? Icons.star : Icons.star_outline,
                                  size: 20),
                              title: Text(isDefault
                                  ? 'Remove default'
                                  : 'Set as default resume'),
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            title: Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _fileExt(String path) {
    final dot = path.lastIndexOf('.');
    return dot == -1 ? 'File' : path.substring(dot + 1).toUpperCase();
  }

  Future<void> _openFile(BuildContext context, AppDocument doc) async {
    final path = doc.filePath;
    if (path == null) return;
    if (!File(path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('File not found on this device. Re-upload it.')),
      );
      return;
    }
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  }

  Future<void> _onMenuAction(BuildContext context, WidgetRef ref,
      AppDocument doc, String action) async {
    switch (action) {
      case 'open':
        await _openFile(context, doc);
      case 'share':
        final path = doc.filePath;
        if (path != null && File(path).existsSync()) {
          await Share.shareXFiles([XFile(path)], text: doc.name);
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File not found on this device.')),
          );
        }
      case 'default':
        final settings = ref.read(settingsNotifierProvider.notifier);
        final current = ref.read(settingsNotifierProvider).defaultResumeId;
        settings.setDefaultResumeId(current == doc.id ? null : doc.id);
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Document'),
            content: Text('Delete "${doc.name}"? This cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        // Remove the copied file and clear default if it pointed here
        if (doc.filePath != null) {
          final f = File(doc.filePath!);
          if (f.existsSync()) await f.delete();
        }
        if (ref.read(settingsNotifierProvider).defaultResumeId == doc.id) {
          ref.read(settingsNotifierProvider.notifier).setDefaultResumeId(null);
        }
        await ref.read(documentsNotifierProvider.notifier).delete(doc.id);
    }
  }

  Color _docColor(DocumentType t) {
    switch (t) {
      case DocumentType.resume: return const Color(0xFF3B82F6);
      case DocumentType.coverLetter: return const Color(0xFF8B5CF6);
      case DocumentType.portfolio: return const Color(0xFF22C55E);
      case DocumentType.other: return const Color(0xFF9CA3AF);
    }
  }

  IconData _docIcon(DocumentType t) {
    switch (t) {
      case DocumentType.resume: return Icons.description_outlined;
      case DocumentType.coverLetter: return Icons.mail_outline;
      case DocumentType.portfolio: return Icons.web_outlined;
      case DocumentType.other: return Icons.attach_file;
    }
  }

  void _showAddDocSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final versionCtrl = TextEditingController();
    DocumentType type = DocumentType.resume;
    String? pickedPath;
    String? pickedFileName;
    bool setAsDefault = false;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final cs = Theme.of(ctx).colorScheme;
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Document',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 16),

                  // File upload area
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: [
                          'pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'
                        ],
                      );
                      final file = result?.files.singleOrNull;
                      if (file?.path == null) return;
                      setModalState(() {
                        pickedPath = file!.path;
                        pickedFileName = file.name;
                        if (nameCtrl.text.trim().isEmpty) {
                          final dot = file.name.lastIndexOf('.');
                          nameCtrl.text =
                              dot == -1 ? file.name : file.name.substring(0, dot);
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: cs.primary.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                              pickedPath == null
                                  ? Icons.upload_file_outlined
                                  : Icons.task_outlined,
                              color: cs.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pickedFileName ??
                                  'Tap to upload file (PDF, DOC…)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary),
                            ),
                          ),
                          if (pickedPath != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setModalState(() {
                                pickedPath = null;
                                pickedFileName = null;
                              }),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Document name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: versionCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Version (optional, e.g. 2)'),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: DocumentType.values
                        .map((t) => ChoiceChip(
                              label: Text(t.label),
                              selected: type == t,
                              onSelected: (_) => setModalState(() => type = t),
                            ))
                        .toList(),
                  ),
                  if (type == DocumentType.resume) ...[
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Set as default resume',
                          style: TextStyle(fontSize: 14)),
                      value: setAsDefault,
                      onChanged: (v) => setModalState(() => setAsDefault = v),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: saving
                          ? null
                          : () async {
                              if (nameCtrl.text.trim().isEmpty) return;
                              setModalState(() => saving = true);
                              try {
                                String? storedPath;
                                if (pickedPath != null) {
                                  storedPath = await _copyIntoVault(
                                      pickedPath!, pickedFileName!);
                                }
                                final doc = await ref
                                    .read(documentsNotifierProvider.notifier)
                                    .add(
                                      name: nameCtrl.text.trim(),
                                      type: type,
                                      version: versionCtrl.text.trim().isEmpty
                                          ? null
                                          : versionCtrl.text.trim(),
                                      filePath: storedPath,
                                    );
                                if (type == DocumentType.resume &&
                                    setAsDefault) {
                                  ref
                                      .read(settingsNotifierProvider.notifier)
                                      .setDefaultResumeId(doc.id);
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                              } finally {
                                if (ctx.mounted) {
                                  setModalState(() => saving = false);
                                }
                              }
                            },
                      child: Text(saving ? 'Saving…' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Copies a picked file into the app's private documents folder so it
  /// survives even if the original is moved or deleted.
  Future<String> _copyIntoVault(String sourcePath, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final vault = Directory('${dir.path}${Platform.pathSeparator}documents');
    if (!vault.existsSync()) vault.createSync(recursive: true);
    final target =
        '${vault.path}${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await File(sourcePath).copy(target);
    return target;
  }
}
