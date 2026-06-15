import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/enums.dart';
import '../core/data/company_catalog.dart';
import '../models/company.dart';
import '../services/hive_service.dart';

part 'companies_provider.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
class CompaniesNotifier extends _$CompaniesNotifier {
  @override
  List<Company> build() => _loadAll();

  List<Company> _loadAll() {
    final box = HiveService.companiesBox;
    return box.values
        .map((raw) => Company.fromJson(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<Company> add({
    required String name,
    AtsProvider provider = AtsProvider.custom,
    String? slug,
    String? careerUrl,
    String? logoUrl,
    String? location,
    CompanyCategory category = CompanyCategory.other,
    List<String> tags = const [],
    String? notes,
    Map<String, String> config = const {},
  }) async {
    final now = DateTime.now();
    final company = Company(
      id: _uuid.v4(),
      name: name,
      provider: provider,
      slug: slug,
      careerUrl: careerUrl,
      logoUrl: logoUrl,
      location: location,
      category: category,
      tags: tags,
      notes: notes,
      config: config,
      createdAt: now,
      updatedAt: now,
    );
    await HiveService.companiesBox.put(company.id, company.toJson());
    state = _loadAll();
    return company;
  }

  /// True when a company with the same name already exists (used by the catalog
  /// import to avoid duplicates).
  bool existsByName(String name) {
    final n = name.trim().toLowerCase();
    return state.any((c) => c.name.trim().toLowerCase() == n);
  }

  /// Adds a company straight from the built-in catalog (no-op if already added).
  Future<void> addSeed(SeedCompany seed) async {
    if (existsByName(seed.name)) return;
    await add(
      name: seed.name,
      provider: seed.provider,
      slug: seed.slug,
      careerUrl: seed.careerUrl,
      category: seed.category,
      tags: seed.tags,
      config: seed.config,
    );
  }

  Future<void> update(Company updated) async {
    final company = updated.copyWith(updatedAt: DateTime.now());
    await HiveService.companiesBox.put(company.id, company.toJson());
    state = _loadAll();
  }

  Future<void> delete(String id) async {
    await HiveService.companiesBox.delete(id);
    state = _loadAll();
  }

  Company? getById(String id) {
    final raw = HiveService.companiesBox.get(id);
    if (raw == null) return null;
    return Company.fromJson(Map<String, dynamic>.from(raw));
  }

  /// Record the result of a successful fetch so the list can show counts.
  Future<void> recordFetch(String id, int jobCount) async {
    final company = getById(id);
    if (company == null) return;
    await update(company.copyWith(
      lastFetchedAt: DateTime.now(),
      lastJobCount: jobCount,
    ));
  }
}
