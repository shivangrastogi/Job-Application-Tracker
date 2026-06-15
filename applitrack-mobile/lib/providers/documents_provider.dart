import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../core/constants/enums.dart';
import '../services/hive_service.dart';

part 'documents_provider.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
class DocumentsNotifier extends _$DocumentsNotifier {
  @override
  List<AppDocument> build() => _loadAll();

  List<AppDocument> _loadAll() {
    return HiveService.documentsBox.values
        .map((raw) => AppDocument.fromJson(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<AppDocument> add({
    required String name,
    required DocumentType type,
    String? version,
    String? content,
    String? filePath,
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final doc = AppDocument(
      id: _uuid.v4(),
      name: name,
      type: type,
      version: version,
      content: content,
      filePath: filePath,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
    await HiveService.documentsBox.put(doc.id, doc.toJson());
    state = _loadAll();
    return doc;
  }

  Future<void> update(AppDocument updated) async {
    final doc = updated.copyWith(updatedAt: DateTime.now());
    await HiveService.documentsBox.put(doc.id, doc.toJson());
    state = _loadAll();
  }

  Future<void> delete(String id) async {
    await HiveService.documentsBox.delete(id);
    state = _loadAll();
  }

  List<AppDocument> ofType(DocumentType type) =>
      state.where((d) => d.type == type).toList();

  AppDocument? getById(String id) {
    final raw = HiveService.documentsBox.get(id);
    if (raw == null) return null;
    return AppDocument.fromJson(Map<String, dynamic>.from(raw));
  }
}
