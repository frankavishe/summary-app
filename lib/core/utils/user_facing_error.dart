import 'dart:io';

/// Maps a caught pipeline error into a short, human-readable message safe to
/// show directly in a SnackBar. `SummaryPipelineController` already catches
/// every exception via `AsyncValue.guard` so the app never crashes on a bad
/// upload - this only controls how that failure reads to the user, mapping
/// the common, expected cases (no internet, invalid API key, a corrupt or
/// unsupported file) to plain language instead of a raw exception dump.
String userFacingErrorMessage(Object error) {
  if (error is SocketException) {
    return 'No internet connection. Check your connection and try again.';
  }

  final text = error.toString();
  final lower = text.toLowerCase();

  if (lower.contains('invalid gemini api key')) {
    return 'Your Gemini API key looks invalid. Check it in Settings.';
  }
  if (lower.contains('failed host lookup') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection failed') ||
      lower.contains('connection refused') ||
      lower.contains('socketexception')) {
    return 'No internet connection. Check your connection and try again.';
  }
  if (lower.contains('not a valid') ||
      lower.contains('formatexception') ||
      lower.contains('corrupt')) {
    return 'This file appears to be corrupted or in an unsupported format.';
  }
  if (lower.contains('aisummarizationexception')) {
    return 'Could not generate a summary right now. Please try again.';
  }

  return 'Something went wrong: ${_truncate(text)}';
}

const int _maxFallbackMessageLength = 140;

String _truncate(String text) {
  if (text.length <= _maxFallbackMessageLength) return text;
  return '${text.substring(0, _maxFallbackMessageLength)}…';
}
