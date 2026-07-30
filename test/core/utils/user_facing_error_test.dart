import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/core/utils/user_facing_error.dart';
import 'package:summaread/services/ai_service.dart';

void main() {
  group('userFacingErrorMessage', () {
    test('maps a SocketException to a no-internet message', () {
      expect(
        userFacingErrorMessage(const SocketException('Failed host lookup')),
        'No internet connection. Check your connection and try again.',
      );
    });

    test('maps an invalid-API-key AiSummarizationException to a Settings-pointing message', () {
      final error = const AiSummarizationException(
        'Invalid Gemini API key (API key not valid.). Check the key saved in Settings.',
      );
      expect(
        userFacingErrorMessage(error),
        'Your Gemini API key looks invalid. Check it in Settings.',
      );
    });

    test('maps a corrupt/unsupported-format error to a plain-language message', () {
      expect(
        userFacingErrorMessage(const FormatException('Not a valid .docx file')),
        'This file appears to be corrupted or in an unsupported format.',
      );
    });

    test('maps a generic AiSummarizationException to a retry message', () {
      expect(
        userFacingErrorMessage(const AiSummarizationException('Gemini API request failed after 5 attempts')),
        'Could not generate a summary right now. Please try again.',
      );
    });

    test('falls back to a truncated raw message for anything unrecognized', () {
      final message = userFacingErrorMessage(Exception('boom'));
      expect(message, startsWith('Something went wrong:'));
      expect(message, contains('boom'));
    });

    test('truncates very long fallback messages', () {
      final message = userFacingErrorMessage(Exception('x' * 500));
      expect(message.length, lessThan(200));
      expect(message, endsWith('…'));
    });
  });
}
