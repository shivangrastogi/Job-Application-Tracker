import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/hive_service.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  static const _onboarded = 'onboarded';
  static const _themeMode = 'themeMode';
  static const _notifyFollowUp = 'notifyFollowUp';
  static const _notifyInterview = 'notifyInterview';
  static const _notifyStale = 'notifyStale';
  static const _notifyWeekly = 'notifyWeekly';
  static const _followUpDays = 'followUpDays';
  static const _defaultResumeId = 'defaultResumeId';
  static const _refName = 'referralName';
  static const _refEmail = 'referralEmail';
  static const _refPhone = 'referralPhone';
  static const _refLinkedin = 'referralLinkedin';
  static const _refResume = 'referralResumeUrl';

  Box get _box => HiveService.settingsBox;

  @override
  AppSettings build() {
    return AppSettings(
      onboarded: _box.get(_onboarded, defaultValue: false) as bool,
      themeModeName: _box.get(_themeMode, defaultValue: 'system') as String,
      notifyFollowUp: _box.get(_notifyFollowUp, defaultValue: true) as bool,
      notifyInterview: _box.get(_notifyInterview, defaultValue: true) as bool,
      notifyStale: _box.get(_notifyStale, defaultValue: true) as bool,
      notifyWeekly: _box.get(_notifyWeekly, defaultValue: false) as bool,
      followUpDays: _box.get(_followUpDays, defaultValue: 14) as int,
      defaultResumeId: _box.get(_defaultResumeId) as String?,
      referralName: _box.get(_refName) as String?,
      referralEmail: _box.get(_refEmail) as String?,
      referralPhone: _box.get(_refPhone) as String?,
      referralLinkedin: _box.get(_refLinkedin) as String?,
      referralResumeUrl: _box.get(_refResume) as String?,
    );
  }

  void setReferralProfile({
    String? name,
    String? email,
    String? phone,
    String? linkedin,
    String? resumeUrl,
  }) {
    void put(String key, String? val) {
      if (val == null || val.isEmpty) {
        _box.delete(key);
      } else {
        _box.put(key, val);
      }
    }

    put(_refName, name);
    put(_refEmail, email);
    put(_refPhone, phone);
    put(_refLinkedin, linkedin);
    put(_refResume, resumeUrl);
    state = state.copyWith(
      referralName: name,
      referralEmail: email,
      referralPhone: phone,
      referralLinkedin: linkedin,
      referralResumeUrl: resumeUrl,
      clearReferral: true,
    );
  }

  void setDefaultResumeId(String? id) {
    if (id == null) {
      _box.delete(_defaultResumeId);
    } else {
      _box.put(_defaultResumeId, id);
    }
    state = state.copyWith(defaultResumeId: id, clearDefaultResumeId: id == null);
  }

  void completeOnboarding() {
    _box.put(_onboarded, true);
    state = state.copyWith(onboarded: true);
  }

  void setThemeMode(String mode) {
    _box.put(_themeMode, mode);
    state = state.copyWith(themeModeName: mode);
  }

  void setFollowUpDays(int days) {
    _box.put(_followUpDays, days);
    state = state.copyWith(followUpDays: days);
  }

  void toggleNotifyFollowUp(bool val) {
    _box.put(_notifyFollowUp, val);
    state = state.copyWith(notifyFollowUp: val);
  }

  void toggleNotifyInterview(bool val) {
    _box.put(_notifyInterview, val);
    state = state.copyWith(notifyInterview: val);
  }

  void toggleNotifyStale(bool val) {
    _box.put(_notifyStale, val);
    state = state.copyWith(notifyStale: val);
  }

  void toggleNotifyWeekly(bool val) {
    _box.put(_notifyWeekly, val);
    state = state.copyWith(notifyWeekly: val);
  }
}

// Manual copyWith since we can't use freezed here (no build_runner dependency in provider)
class AppSettings {
  final bool onboarded;
  final String themeModeName;
  final bool notifyFollowUp;
  final bool notifyInterview;
  final bool notifyStale;
  final bool notifyWeekly;
  final int followUpDays;
  final String? defaultResumeId;
  final String? referralName;
  final String? referralEmail;
  final String? referralPhone;
  final String? referralLinkedin;
  final String? referralResumeUrl;

  const AppSettings({
    required this.onboarded,
    required this.themeModeName,
    required this.notifyFollowUp,
    required this.notifyInterview,
    required this.notifyStale,
    required this.notifyWeekly,
    required this.followUpDays,
    this.defaultResumeId,
    this.referralName,
    this.referralEmail,
    this.referralPhone,
    this.referralLinkedin,
    this.referralResumeUrl,
  });

  AppSettings copyWith({
    bool? onboarded,
    String? themeModeName,
    bool? notifyFollowUp,
    bool? notifyInterview,
    bool? notifyStale,
    bool? notifyWeekly,
    int? followUpDays,
    String? defaultResumeId,
    bool clearDefaultResumeId = false,
    String? referralName,
    String? referralEmail,
    String? referralPhone,
    String? referralLinkedin,
    String? referralResumeUrl,
    bool clearReferral = false,
  }) {
    return AppSettings(
      onboarded: onboarded ?? this.onboarded,
      themeModeName: themeModeName ?? this.themeModeName,
      notifyFollowUp: notifyFollowUp ?? this.notifyFollowUp,
      notifyInterview: notifyInterview ?? this.notifyInterview,
      notifyStale: notifyStale ?? this.notifyStale,
      notifyWeekly: notifyWeekly ?? this.notifyWeekly,
      followUpDays: followUpDays ?? this.followUpDays,
      defaultResumeId: clearDefaultResumeId
          ? null
          : (defaultResumeId ?? this.defaultResumeId),
      referralName: clearReferral ? referralName : (referralName ?? this.referralName),
      referralEmail: clearReferral ? referralEmail : (referralEmail ?? this.referralEmail),
      referralPhone: clearReferral ? referralPhone : (referralPhone ?? this.referralPhone),
      referralLinkedin:
          clearReferral ? referralLinkedin : (referralLinkedin ?? this.referralLinkedin),
      referralResumeUrl:
          clearReferral ? referralResumeUrl : (referralResumeUrl ?? this.referralResumeUrl),
    );
  }
}

