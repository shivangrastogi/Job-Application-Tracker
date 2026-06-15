import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/constants/enums.dart';

part 'referral.freezed.dart';
part 'referral.g.dart';

/// A single referral request you made (e.g. "asked for a referral at Google
/// via the Tech Referrals form").
@freezed
abstract class Referral with _$Referral {
  const factory Referral({
    required String id,
    String? sourceId,
    required String company,
    String? role,
    String? jobUrl,
    String? referrerName,
    @Default(ReferralStatus.requested) ReferralStatus status,
    DateTime? requestedDate,
    String? notes,
    /// Set once converted into a tracked JobApplication.
    String? linkedApplicationId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Referral;

  factory Referral.fromJson(Map<String, dynamic> json) =>
      _$ReferralFromJson(json);
}
