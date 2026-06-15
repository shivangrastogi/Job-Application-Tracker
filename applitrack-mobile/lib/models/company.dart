import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/constants/enums.dart';

part 'company.freezed.dart';
part 'company.g.dart';

/// An MNC / employer the user is tracking. We store the ATS provider + slug so
/// we can fetch live openings, plus an optional careers URL for the fallback
/// "open in browser" case.
@freezed
abstract class Company with _$Company {
  const factory Company({
    required String id,
    required String name,
    @Default(AtsProvider.custom) AtsProvider provider,
    String? slug,
    String? careerUrl,
    String? logoUrl,
    String? location,
    @Default(CompanyCategory.other) CompanyCategory category,
    @Default(<String>[]) List<String> tags,
    String? notes,
    /// Provider-specific parameters: Workday {tenant, dc, site}, Amazon
    /// {loc_query, country, query, category}, etc.
    @Default(<String, String>{}) Map<String, String> config,
    DateTime? lastFetchedAt,
    @Default(0) int lastJobCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Company;

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);
}
