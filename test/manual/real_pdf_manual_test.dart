// Throwaway manual verification script - not part of the normal test suite.
// Requires a real GEMINI_API_KEY in .env and network access. Run with:
//   flutter test test/manual/real_pdf_manual_test.dart --timeout 20m
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/services/ai_service.dart';
import 'package:summaread/services/extractors/pdf_extractor.dart';

void main() {
  test(
    'summarizes a real large PDF end-to-end',
    () async {
      await dotenv.load(fileName: '.env');
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      expect(apiKey, isNotNull, reason: 'Set GEMINI_API_KEY in .env');

      final path =
          Platform.environment['PDF_PATH'] ??
          r'C:\Users\User\Downloads\dS&A Book By Alfred -Aho.pdf';
      // ignore: avoid_print
      print('Target PDF: $path');

      final extractStopwatch = Stopwatch()..start();
      final extracted = await PdfExtractorService.extractFromFile(path);
      extractStopwatch.stop();
      final text = extracted.toSourceText();

      // ignore: avoid_print
      print('Pages: ${extracted.totalPageCount}');
      // ignore: avoid_print
      print('Extracted chars: ${text.length}');
      // ignore: avoid_print
      print('Estimated tokens: ${(text.length / 4).ceil()}');
      // ignore: avoid_print
      print('Extract time: ${extractStopwatch.elapsed}');

      final service = GeminiSummarizerService(apiKey!);
      final summarizeStopwatch = Stopwatch()..start();
      final result = await service.summarizeDocument(
        content: text,
        docType: 'pdf',
      );
      summarizeStopwatch.stop();

      // ignore: avoid_print
      print('\n--- TIMING ---');
      // ignore: avoid_print
      print('Summarize time: ${summarizeStopwatch.elapsed}');

      // ignore: avoid_print
      print(
        '\n--- EXECUTIVE SUMMARY (${result.executiveSummary.length} chars) ---',
      );
      // ignore: avoid_print
      print(result.executiveSummary);

      // ignore: avoid_print
      print('\n--- SECTIONS: ${result.sections.length} ---');
      for (final s in result.sections) {
        // ignore: avoid_print
        print(
          '## ${s.sectionTitle}  (${s.summaryText.length} chars, ${s.keyPoints.length} key points)',
        );
        // ignore: avoid_print
        print(s.summaryText);
        for (final kp in s.keyPoints) {
          // ignore: avoid_print
          print(' - $kp');
        }
        // ignore: avoid_print
        print('');
      }

      expect(result.sections, isNotEmpty);
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}
