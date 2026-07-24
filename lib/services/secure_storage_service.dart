import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage for the one secret this app persists on-device: the user-supplied
/// Gemini API key (spec section 8 - never bundled with the app). Abstracted
/// behind an interface so tests can inject an in-memory fake instead of
/// `flutter_secure_storage`'s platform channel, which has no test-time
/// implementation - the same seam pattern as `tts_service.dart`'s
/// `TtsEngine`.
abstract class ApiKeyStorage {
  Future<String?> read();
  Future<void> write(String apiKey);
  Future<void> delete();
}

class SecureApiKeyStorage implements ApiKeyStorage {
  SecureApiKeyStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _storageKey = 'gemini_api_key';

  @override
  Future<String?> read() => _storage.read(key: _storageKey);

  @override
  Future<void> write(String apiKey) => _storage.write(key: _storageKey, value: apiKey);

  @override
  Future<void> delete() => _storage.delete(key: _storageKey);
}
