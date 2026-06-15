// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referrals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$referralCountsHash() => r'e87b37f9f3b6c74bf69ccc7357dde7574bd8884a';

/// Referral requests counted by status (for the summary header).
///
/// Copied from [referralCounts].
@ProviderFor(referralCounts)
final referralCountsProvider =
    AutoDisposeProvider<Map<ReferralStatus, int>>.internal(
      referralCounts,
      name: r'referralCountsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$referralCountsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReferralCountsRef = AutoDisposeProviderRef<Map<ReferralStatus, int>>;
String _$referralSourcesNotifierHash() =>
    r'c89d25db3c3b8e2936ac062454bdc9cdd87c35eb';

/// See also [ReferralSourcesNotifier].
@ProviderFor(ReferralSourcesNotifier)
final referralSourcesNotifierProvider =
    NotifierProvider<ReferralSourcesNotifier, List<ReferralSource>>.internal(
      ReferralSourcesNotifier.new,
      name: r'referralSourcesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$referralSourcesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReferralSourcesNotifier = Notifier<List<ReferralSource>>;
String _$referralsNotifierHash() => r'2f1b7d57dc9aaaf4ee57b2f3e26b630120cd8d63';

/// See also [ReferralsNotifier].
@ProviderFor(ReferralsNotifier)
final referralsNotifierProvider =
    NotifierProvider<ReferralsNotifier, List<Referral>>.internal(
      ReferralsNotifier.new,
      name: r'referralsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$referralsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReferralsNotifier = Notifier<List<Referral>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
