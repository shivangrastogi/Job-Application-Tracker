// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goalProgressHash() => r'67a2af7da9c2577a09795babb7d14d5e88568c80';

/// Computes live progress for every goal from applications + interviews.
///
/// Copied from [goalProgress].
@ProviderFor(goalProgress)
final goalProgressProvider = AutoDisposeProvider<List<GoalProgress>>.internal(
  goalProgress,
  name: r'goalProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goalProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GoalProgressRef = AutoDisposeProviderRef<List<GoalProgress>>;
String _$goalsNotifierHash() => r'a1a8d5986ce1c09778080cc0214551214855ee83';

/// See also [GoalsNotifier].
@ProviderFor(GoalsNotifier)
final goalsNotifierProvider =
    NotifierProvider<GoalsNotifier, List<Goal>>.internal(
      GoalsNotifier.new,
      name: r'goalsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$goalsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GoalsNotifier = Notifier<List<Goal>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
