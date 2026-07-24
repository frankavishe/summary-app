import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/services/providers.dart';
import 'package:summaread/services/secure_storage_service.dart';

/// In-memory fake for [ApiKeyStorage] - `flutter_secure_storage`'s platform
/// channel has no test-time implementation (see secure_storage_service.dart).
class FakeApiKeyStorage implements ApiKeyStorage {
  FakeApiKeyStorage([this._value]);

  String? _value;
  int writeCalls = 0;
  int deleteCalls = 0;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String apiKey) async {
    writeCalls++;
    _value = apiKey;
  }

  @override
  Future<void> delete() async {
    deleteCalls++;
    _value = null;
  }
}

void main() {
  test('build() returns the key already saved in storage', () async {
    final storage = FakeApiKeyStorage('stored-key');
    final container = ProviderContainer(
      overrides: [apiKeyStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    final key = await container.read(apiKeyControllerProvider.future);

    expect(key, 'stored-key');
  });

  test('build() falls back to null when storage is empty and .env is not loaded', () async {
    final storage = FakeApiKeyStorage();
    final container = ProviderContainer(
      overrides: [apiKeyStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    final key = await container.read(apiKeyControllerProvider.future);

    expect(key, isNull);
  });

  test('save() writes to storage and updates state immediately', () async {
    final storage = FakeApiKeyStorage();
    final container = ProviderContainer(
      overrides: [apiKeyStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
    await container.read(apiKeyControllerProvider.future);

    await container.read(apiKeyControllerProvider.notifier).save('  new-key  ');

    expect(storage.writeCalls, 1);
    expect(container.read(apiKeyControllerProvider).value, 'new-key');
  });

  test('clear() deletes from storage and updates state immediately', () async {
    final storage = FakeApiKeyStorage('existing-key');
    final container = ProviderContainer(
      overrides: [apiKeyStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
    await container.read(apiKeyControllerProvider.future);

    await container.read(apiKeyControllerProvider.notifier).clear();

    expect(storage.deleteCalls, 1);
    expect(container.read(apiKeyControllerProvider).value, isNull);
  });

  test('aiServiceProvider throws while no key is configured (or still loading)', () {
    final storage = FakeApiKeyStorage();
    final container = ProviderContainer(
      overrides: [apiKeyStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    expect(() => container.read(aiServiceProvider), throwsStateError);
  });

  test('aiServiceProvider builds once a key is configured', () async {
    final storage = FakeApiKeyStorage('configured-key');
    final container = ProviderContainer(
      overrides: [apiKeyStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
    await container.read(apiKeyControllerProvider.future);

    expect(container.read(aiServiceProvider), isNotNull);
  });
}
