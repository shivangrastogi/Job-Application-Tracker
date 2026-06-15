import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/enums.dart';
import '../models/referral.dart';
import '../models/referral_source.dart';
import '../services/hive_service.dart';

part 'referrals_provider.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
class ReferralSourcesNotifier extends _$ReferralSourcesNotifier {
  @override
  List<ReferralSource> build() => _loadAll();

  List<ReferralSource> _loadAll() {
    return HiveService.referralSourcesBox.values
        .map((raw) => ReferralSource.fromJson(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<ReferralSource> add({
    required String name,
    ReferralSourceType type = ReferralSourceType.group,
    String? url,
    String? formTemplate,
    String? notes,
  }) async {
    final source = ReferralSource(
      id: _uuid.v4(),
      name: name,
      type: type,
      url: url,
      formTemplate: formTemplate,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await HiveService.referralSourcesBox.put(source.id, source.toJson());
    state = _loadAll();
    return source;
  }

  Future<void> update(ReferralSource source) async {
    await HiveService.referralSourcesBox.put(source.id, source.toJson());
    state = _loadAll();
  }

  Future<void> delete(String id) async {
    await HiveService.referralSourcesBox.delete(id);
    state = _loadAll();
  }

  ReferralSource? getById(String? id) {
    if (id == null) return null;
    final raw = HiveService.referralSourcesBox.get(id);
    if (raw == null) return null;
    return ReferralSource.fromJson(Map<String, dynamic>.from(raw));
  }
}

@Riverpod(keepAlive: true)
class ReferralsNotifier extends _$ReferralsNotifier {
  @override
  List<Referral> build() => _loadAll();

  List<Referral> _loadAll() {
    return HiveService.referralsBox.values
        .map((raw) => Referral.fromJson(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<Referral> add({
    String? sourceId,
    required String company,
    String? role,
    String? jobUrl,
    String? referrerName,
    ReferralStatus status = ReferralStatus.requested,
    DateTime? requestedDate,
    String? notes,
  }) async {
    final now = DateTime.now();
    final referral = Referral(
      id: _uuid.v4(),
      sourceId: sourceId,
      company: company,
      role: role,
      jobUrl: jobUrl,
      referrerName: referrerName,
      status: status,
      requestedDate: requestedDate ?? now,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    await HiveService.referralsBox.put(referral.id, referral.toJson());
    state = _loadAll();
    return referral;
  }

  Future<void> update(Referral referral) async {
    final updated = referral.copyWith(updatedAt: DateTime.now());
    await HiveService.referralsBox.put(updated.id, updated.toJson());
    state = _loadAll();
  }

  Future<void> setStatus(Referral referral, ReferralStatus status) =>
      update(referral.copyWith(status: status));

  Future<void> linkApplication(Referral referral, String applicationId) =>
      update(referral.copyWith(
          linkedApplicationId: applicationId, status: ReferralStatus.applied));

  Future<void> delete(String id) async {
    await HiveService.referralsBox.delete(id);
    state = _loadAll();
  }
}

/// Referral requests counted by status (for the summary header).
@riverpod
Map<ReferralStatus, int> referralCounts(ReferralCountsRef ref) {
  final all = ref.watch(referralsNotifierProvider);
  final map = {for (final s in ReferralStatus.values) s: 0};
  for (final r in all) {
    map[r.status] = (map[r.status] ?? 0) + 1;
  }
  return map;
}

/// Builds the URL to open for a referral source, substituting Google-Form
/// prefill tokens ({name},{email},{phone},{linkedin},{resume},{company},{role})
/// from the saved referral profile when a [formTemplate] is set.
String? buildReferralOpenUrl({
  required ReferralSource source,
  Referral? referral,
  String? name,
  String? email,
  String? phone,
  String? linkedin,
  String? resumeUrl,
}) {
  final template = source.formTemplate;
  if (template == null || template.trim().isEmpty) {
    return source.url;
  }
  final tokens = <String, String>{
    'name': name ?? '',
    'email': email ?? '',
    'phone': phone ?? '',
    'linkedin': linkedin ?? '',
    'resume': resumeUrl ?? '',
    'company': referral?.company ?? '',
    'role': referral?.role ?? '',
  };
  var url = template;
  tokens.forEach((key, value) {
    url = url.replaceAll('{$key}', Uri.encodeComponent(value));
  });
  return url;
}
