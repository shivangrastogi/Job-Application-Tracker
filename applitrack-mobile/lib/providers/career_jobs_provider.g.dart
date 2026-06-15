// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_jobs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$careerJobsHash() => r'580abfb96db13f4fcbb49d797ccc5820b28fdac2';

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

/// Fetches live openings for one company from its ATS. Pull-to-refresh in the
/// UI calls `ref.invalidate` / `ref.refresh` on this family.
///
/// Copied from [careerJobs].
@ProviderFor(careerJobs)
const careerJobsProvider = CareerJobsFamily();

/// Fetches live openings for one company from its ATS. Pull-to-refresh in the
/// UI calls `ref.invalidate` / `ref.refresh` on this family.
///
/// Copied from [careerJobs].
class CareerJobsFamily extends Family<AsyncValue<List<CareerJob>>> {
  /// Fetches live openings for one company from its ATS. Pull-to-refresh in the
  /// UI calls `ref.invalidate` / `ref.refresh` on this family.
  ///
  /// Copied from [careerJobs].
  const CareerJobsFamily();

  /// Fetches live openings for one company from its ATS. Pull-to-refresh in the
  /// UI calls `ref.invalidate` / `ref.refresh` on this family.
  ///
  /// Copied from [careerJobs].
  CareerJobsProvider call(String companyId) {
    return CareerJobsProvider(companyId);
  }

  @override
  CareerJobsProvider getProviderOverride(
    covariant CareerJobsProvider provider,
  ) {
    return call(provider.companyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'careerJobsProvider';
}

/// Fetches live openings for one company from its ATS. Pull-to-refresh in the
/// UI calls `ref.invalidate` / `ref.refresh` on this family.
///
/// Copied from [careerJobs].
class CareerJobsProvider extends AutoDisposeFutureProvider<List<CareerJob>> {
  /// Fetches live openings for one company from its ATS. Pull-to-refresh in the
  /// UI calls `ref.invalidate` / `ref.refresh` on this family.
  ///
  /// Copied from [careerJobs].
  CareerJobsProvider(String companyId)
    : this._internal(
        (ref) => careerJobs(ref as CareerJobsRef, companyId),
        from: careerJobsProvider,
        name: r'careerJobsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$careerJobsHash,
        dependencies: CareerJobsFamily._dependencies,
        allTransitiveDependencies: CareerJobsFamily._allTransitiveDependencies,
        companyId: companyId,
      );

  CareerJobsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.companyId,
  }) : super.internal();

  final String companyId;

  @override
  Override overrideWith(
    FutureOr<List<CareerJob>> Function(CareerJobsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CareerJobsProvider._internal(
        (ref) => create(ref as CareerJobsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        companyId: companyId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CareerJob>> createElement() {
    return _CareerJobsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CareerJobsProvider && other.companyId == companyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, companyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CareerJobsRef on AutoDisposeFutureProviderRef<List<CareerJob>> {
  /// The parameter `companyId` of this provider.
  String get companyId;
}

class _CareerJobsProviderElement
    extends AutoDisposeFutureProviderElement<List<CareerJob>>
    with CareerJobsRef {
  _CareerJobsProviderElement(super.provider);

  @override
  String get companyId => (origin as CareerJobsProvider).companyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
