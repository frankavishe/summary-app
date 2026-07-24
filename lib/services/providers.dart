import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_service.dart';
import 'isar_service.dart';
import 'secure_storage_service.dart';
import 'tts_service.dart';

/// Opens the on-device Isar database once and keeps it alive for the life of
/// the app.
final isarServiceProvider = FutureProvider<IsarService>((ref) async {
  return IsarService.open();
});

final apiKeyStorageProvider = Provider<ApiKeyStorage>((ref) => SecureApiKeyStorage());

/// Owns the user-supplied Gemini API key (spec section 8: never bundled with
/// the app). On first load, reads whatever was last saved via Settings from
/// secure on-device storage; if nothing has been saved yet, falls back to a
/// local `.env` value for dev convenience. [save]/[clear] update storage and
/// this provider's state together, so a newly-entered key takes effect
/// immediately without an app restart.
class ApiKeyController extends AsyncNotifier<String?> {
  ApiKeyStorage get _storage => ref.read(apiKeyStorageProvider);

  @override
  Future<String?> build() async {
    final stored = await _storage.read();
    if (stored != null && stored.isNotEmpty) return stored;
    if (!dotenv.isInitialized) return null;
    final envKey = dotenv.env['GEMINI_API_KEY'];
    return (envKey == null || envKey.isEmpty) ? null : envKey;
  }

  Future<void> save(String apiKey) async {
    final trimmed = apiKey.trim();
    await _storage.write(trimmed);
    state = AsyncValue.data(trimmed);
  }

  Future<void> clear() async {
    await _storage.delete();
    state = const AsyncValue.data(null);
  }
}

final apiKeyControllerProvider = AsyncNotifierProvider<ApiKeyController, String?>(
  ApiKeyController.new,
);

/// The current API key value, or null if none is configured (either nothing
/// has been saved via Settings, or [apiKeyControllerProvider] hasn't
/// finished its initial load yet).
final geminiApiKeyProvider = Provider<String?>((ref) {
  return ref.watch(apiKeyControllerProvider).valueOrNull;
});

/// Throws if no API key is configured. Callers should check
/// [apiKeyControllerProvider] first and show a "add your API key" state
/// instead of reaching this provider with none set.
final aiServiceProvider = Provider<GeminiSummarizerService>((ref) {
  final apiKey = ref.watch(geminiApiKeyProvider);
  if (apiKey == null) {
    throw StateError('No Gemini API key configured. Add one in Settings.');
  }
  return GeminiSummarizerService(apiKey);
});

/// One [TtsService] shared for the life of the app, so playback state
/// survives navigating away from and back to the Summary Viewer.
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Live playback state for the shared [ttsServiceProvider], for the Summary
/// Viewer's play/pause/stop bar to react to.
final ttsStateProvider = StreamProvider<TtsPlaybackState>((ref) {
  final service = ref.watch(ttsServiceProvider);
  return service.stateStream;
});
