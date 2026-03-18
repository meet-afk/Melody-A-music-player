// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_remote_repo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localRemoteRepo)
final localRemoteRepoProvider = LocalRemoteRepoProvider._();

final class LocalRemoteRepoProvider
    extends
        $FunctionalProvider<LocalRemoteRepo, LocalRemoteRepo, LocalRemoteRepo>
    with $Provider<LocalRemoteRepo> {
  LocalRemoteRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localRemoteRepoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localRemoteRepoHash();

  @$internal
  @override
  $ProviderElement<LocalRemoteRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalRemoteRepo create(Ref ref) {
    return localRemoteRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalRemoteRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalRemoteRepo>(value),
    );
  }
}

String _$localRemoteRepoHash() => r'2bae46069248db05fcd9809658d390d5b19f6d65';
