// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interviews_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$upcomingInterviewsHash() =>
    r'48f26796b48881615fd9e8a9cc00aeb32ee89c97';

/// See also [upcomingInterviews].
@ProviderFor(upcomingInterviews)
final upcomingInterviewsProvider =
    AutoDisposeProvider<List<Interview>>.internal(
      upcomingInterviews,
      name: r'upcomingInterviewsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$upcomingInterviewsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingInterviewsRef = AutoDisposeProviderRef<List<Interview>>;
String _$interviewsThisWeekHash() =>
    r'e4a6cdd18b2037bc18453c9fdf2302f5865d2789';

/// See also [interviewsThisWeek].
@ProviderFor(interviewsThisWeek)
final interviewsThisWeekProvider =
    AutoDisposeProvider<List<Interview>>.internal(
      interviewsThisWeek,
      name: r'interviewsThisWeekProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$interviewsThisWeekHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InterviewsThisWeekRef = AutoDisposeProviderRef<List<Interview>>;
String _$interviewsNotifierHash() =>
    r'ddaf560e68988e698fd9644017da9d145dd6ae9c';

/// See also [InterviewsNotifier].
@ProviderFor(InterviewsNotifier)
final interviewsNotifierProvider =
    NotifierProvider<InterviewsNotifier, List<Interview>>.internal(
      InterviewsNotifier.new,
      name: r'interviewsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$interviewsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InterviewsNotifier = Notifier<List<Interview>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
