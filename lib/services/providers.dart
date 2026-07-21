import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_service.dart';
import 'isar_service.dart';

/// Opens the on-device Isar database once and keeps it alive for the life of
/// the app.
final isarServiceProvider = FutureProvider<IsarService>((ref) async {
  return IsarService.open();
});

/// The user-supplied Gemini API key (spec section 8: never bundled with the
/// app). Read from `.env` for now; Phase 8 (Settings) will let the user set
/// this from within the app instead.
final geminiApiKeyProvider = Provider<String?>((ref) {
  final key = dotenv.env['GEMINI_API_KEY'];
  return (key == null || key.isEmpty) ? null : key;
});

/// Throws if no API key is configured. Callers should check
/// [geminiApiKeyProvider] first and show a "add your API key" state instead
/// of reaching this provider with none set.
final aiServiceProvider = Provider<GeminiSummarizerService>((ref) {
  final apiKey = ref.watch(geminiApiKeyProvider);
  if (apiKey == null) {
    throw StateError('No Gemini API key configured. Set GEMINI_API_KEY in .env or Settings.');
  }
  return GeminiSummarizerService(apiKey);
});
