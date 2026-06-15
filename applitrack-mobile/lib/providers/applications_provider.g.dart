// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$applicationsByStatusHash() =>
    r'cca3a4e6e0d7d0fa4d70dbd8fa9c73c9d7d71a55';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [applicationsByStatus].
@ProviderFor(applicationsByStatus)
const applicationsByStatusProvider = ApplicationsByStatusFamily();

/// See also [applicationsByStatus].
class ApplicationsByStatusFamily extends Family<List<JobApplication>> {
  /// See also [applicationsByStatus].
  const ApplicationsByStatusFamily();

  /// See also [applicationsByStatus].
  ApplicationsByStatusProvider call(ApplicationStatus status) {
    return ApplicationsByStatusProvider(status);
  }

  @override
  ApplicationsByStatusProvider getProviderOverride(
    covariant ApplicationsByStatusProvider provider,
  ) {
    return call(provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'applicationsByStatusProvider';
}

/// See also [applicationsByStatus].
class ApplicationsByStatusProvider
    extends AutoDisposeProvider<List<JobApplication>> {
  /// See also [applicationsByStatus].
  ApplicationsByStatusProvider(ApplicationStatus status)
    : this._internal(
        (ref) => applicationsByStatus(ref as ApplicationsByStatusRef, status),
        from: applicationsByStatusProvider,
        name: r'applicationsByStatusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$applicationsByStatusHash,
        dependencies: ApplicationsByStatusFamily._dependencies,
        allTransitiveDependencies:
            ApplicationsByStatusFamily._allTransitiveDependencies,
        status: status,
      );

  ApplicationsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final ApplicationStatus status;

  @override
  Override overrideWith(
    List<JobApplication> Function(ApplicationsByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ApplicationsByStatusProvider._internal(
        (ref) => create(ref as ApplicationsByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<JobApplication>> createElement() {
    return _ApplicationsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ApplicationsByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ApplicationsByStatusRef on AutoDisposeProviderRef<List<JobApplication>> {
  /// The parameter `status` of this provider.
  ApplicationStatus get status;
}

class _ApplicationsByStatusProviderElement
    extends AutoDisposeProviderElement<List<JobApplication>>
    with ApplicationsByStatusRef {
  _ApplicationsByStatusProviderElement(super.provider);

  @override
  ApplicationStatus get status =>
      (origin as ApplicationsByStatusProvider).status;
}

String _$activeApplicationsHash() =>
    r'd6ded3f1cc99c6b491bee878f6bb8f1195fd6157';

/// See also [activeApplications].
@ProviderFor(activeApplications)
final activeApplicationsProvider =
    AutoDisposeProvider<List<JobApplication>>.internal(
      activeApplications,
      name: r'activeApplicationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeApplicationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveApplicationsRef = AutoDisposeProviderRef<List<JobApplication>>;
String _$recentApplicationsHash() =>
    r'146d25250e2908d91d197025602558419d153a20';

/// See also [recentApplications].
@ProviderFor(recentApplications)
final recentApplicationsProvider =
    AutoDisposeProvider<List<JobApplication>>.internal(
      recentApplications,
      name: r'recentApplicationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentApplicationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentApplicationsRef = AutoDisposeProviderRef<List<JobApplication>>;
String _$applicationCountsByStatusHash() =>
    r'e42643eb25094ec7110b68e104dcbcbbbe0c1d64';

/// See also [applicationCountsByStatus].
@ProviderFor(applicationCountsByStatus)
final applicationCountsByStatusProvider =
    AutoDisposeProvider<Map<ApplicationStatus, int>>.internal(
      applicationCountsByStatus,
      name: r'applicationCountsByStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$applicationCountsByStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApplicationCountsByStatusRef =
    AutoDisposeProviderRef<Map<ApplicationStatus, int>>;
String _$applicationsNotifierHash() =>
    r'96878ad23dd3bd2f547f2f4ca05172f7f4e406a1';

/// See also [ApplicationsNotifier].
@ProviderFor(ApplicationsNotifier)
final applicationsNotifierProvider =
    NotifierProvider<ApplicationsNotifier, List<JobApplication>>.internal(
      ApplicationsNotifier.new,
      name: r'applicationsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$applicationsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ApplicationsNotifier = Notifier<List<JobApplication>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
