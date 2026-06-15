import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/constants/enums.dart';

part 'referral_source.freezed.dart';
part 'referral_source.g.dart';

/// A reusable referral channel — a Google Form, a WhatsApp/Telegram group, a
/// LinkedIn contact list, or a specific employee you go through.
@freezed
abstract class ReferralSource with _$ReferralSource {
  const factory ReferralSource({
    required String id,
    required String name,
    @Default(ReferralSourceType.group) ReferralSourceType type,
    String? url,
    /// For Google Forms: a "pre-filled link" with tokens like {name}, {email},
    /// {phone}, {linkedin}, {resume}, {company}, {role} that we substitute
    /// before opening.
    String? formTemplate,
    String? notes,
    required DateTime createdAt,
  }) = _ReferralSource;

  factory ReferralSource.fromJson(Map<String, dynamic> json) =>
      _$ReferralSourceFromJson(json);
}
