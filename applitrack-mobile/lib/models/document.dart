import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/constants/enums.dart';

part 'document.freezed.dart';
part 'document.g.dart';

@freezed
abstract class AppDocument with _$AppDocument {
  const factory AppDocument({
    required String id,
    required String name,
    @Default(DocumentType.resume) DocumentType type,
    String? version,
    String? content,
    String? filePath,
    @Default(<String>[]) List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppDocument;

  factory AppDocument.fromJson(Map<String, dynamic> json) =>
      _$AppDocumentFromJson(json);
}
