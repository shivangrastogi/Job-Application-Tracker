// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Company _$CompanyFromJson(Map<String, dynamic> json) => _Company(
  id: json['id'] as String,
  name: json['name'] as String,
  provider:
      $enumDecodeNullable(_$AtsProviderEnumMap, json['provider']) ??
      AtsProvider.custom,
  slug: json['slug'] as String?,
  careerUrl: json['careerUrl'] as String?,
  logoUrl: json['logoUrl'] as String?,
  location: json['location'] as String?,
  category:
      $enumDecodeNullable(_$CompanyCategoryEnumMap, json['category']) ??
      CompanyCategory.other,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  notes: json['notes'] as String?,
  config:
      (json['config'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  lastFetchedAt: json['lastFetchedAt'] == null
      ? null
      : DateTime.parse(json['lastFetchedAt'] as String),
  lastJobCount: (json['lastJobCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CompanyToJson(_Company instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'provider': _$AtsProviderEnumMap[instance.provider]!,
  'slug': instance.slug,
  'careerUrl': instance.careerUrl,
  'logoUrl': instance.logoUrl,
  'location': instance.location,
  'category': _$CompanyCategoryEnumMap[instance.category]!,
  'tags': instance.tags,
  'notes': instance.notes,
  'config': instance.config,
  'lastFetchedAt': instance.lastFetchedAt?.toIso8601String(),
  'lastJobCount': instance.lastJobCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$AtsProviderEnumMap = {
  AtsProvider.greenhouse: 'greenhouse',
  AtsProvider.lever: 'lever',
  AtsProvider.ashby: 'ashby',
  AtsProvider.smartrecruiters: 'smartrecruiters',
  AtsProvider.workable: 'workable',
  AtsProvider.recruitee: 'recruitee',
  AtsProvider.amazon: 'amazon',
  AtsProvider.workday: 'workday',
  AtsProvider.custom: 'custom',
};

const _$CompanyCategoryEnumMap = {
  CompanyCategory.bigTech: 'bigTech',
  CompanyCategory.productSaas: 'productSaas',
  CompanyCategory.fintech: 'fintech',
  CompanyCategory.indianIt: 'indianIt',
  CompanyCategory.unicorn: 'unicorn',
  CompanyCategory.semiconductorHardware: 'semiconductorHardware',
  CompanyCategory.consultingGcc: 'consultingGcc',
  CompanyCategory.other: 'other',
};
