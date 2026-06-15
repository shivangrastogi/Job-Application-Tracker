// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppDocument _$AppDocumentFromJson(Map<String, dynamic> json) => _AppDocument(
  id: json['id'] as String,
  name: json['name'] as String,
  type:
      $enumDecodeNullable(_$DocumentTypeEnumMap, json['type']) ??
      DocumentType.resume,
  version: json['version'] as String?,
  content: json['content'] as String?,
  filePath: json['filePath'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AppDocumentToJson(_AppDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$DocumentTypeEnumMap[instance.type]!,
      'version': instance.version,
      'content': instance.content,
      'filePath': instance.filePath,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DocumentTypeEnumMap = {
  DocumentType.resume: 'resume',
  DocumentType.coverLetter: 'coverLetter',
  DocumentType.portfolio: 'portfolio',
  DocumentType.other: 'other',
};
