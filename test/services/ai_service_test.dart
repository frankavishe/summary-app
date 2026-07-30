import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:summaread/services/ai_service.dart';

void main() {
  group('single-chunk documents', () {
    test('parses a well-formed Gemini JSON response into a GeneratedSummary', () async {
      final service = GeminiSummarizerService.withGenerator((prompt) async {
        expect(prompt, contains('Summarize the following pdf document'));
        return '''
        {
          "executiveSummary": "- Point one\\n- Point two",
          "sections": [
            {"sectionTitle": "Chapter 1", "summaryText": "Intro text.", "keyPoints": ["A", "B"]}
          ]
        }
        ''';
      });

      final result = await service.summarizeDocument(content: 'short document text', docType: 'pdf');

      expect(result.executiveSummary, '- Point one\n- Point two');
      expect(result.sections, hasLength(1));
      expect(result.sections.single.sectionTitle, 'Chapter 1');
      expect(result.sections.single.keyPoints, ['A', 'B']);
    });

    test('normalizes an executiveSummary given as a JSON array into bullet text', () async {
      final service = GeminiSummarizerService.withGenerator((prompt) async {
        return '{"executiveSummary": ["First point", "Second point"], "sections": []}';
      });

      final result = await service.summarizeDocument(content: 'text', docType: 'docx');

      expect(result.executiveSummary, '- First point\n- Second point');
      expect(result.sections, isEmpty);
    });

    test('retries on transient failures and eventually succeeds', () async {
      var attempts = 0;
      final service = GeminiSummarizerService.withGenerator((prompt) async {
        attempts++;
        if (attempts < 2) throw Exception('simulated network error');
        return '{"executiveSummary": "ok", "sections": []}';
      });

      final result = await service.summarizeDocument(content: 'text', docType: 'excel');

      expect(attempts, 2);
      expect(result.executiveSummary, 'ok');
    });

    test('honors a server-suggested retry delay for quota/rate-limit errors', () async {
      var attempts = 0;
      final stopwatch = Stopwatch()..start();
      final service = GeminiSummarizerService.withGenerator((prompt) async {
        attempts++;
        if (attempts < 2) {
          // Mirrors the real Gemini free-tier quota error message format.
          throw Exception(
            'You exceeded your current quota... Please retry in 0.05s.',
          );
        }
        return '{"executiveSummary": "ok", "sections": []}';
      });

      final result = await service.summarizeDocument(content: 'text', docType: 'pdf');
      stopwatch.stop();

      expect(attempts, 2);
      expect(result.executiveSummary, 'ok');
      // The parsed 0.05s delay plus the implementation's 500ms safety buffer.
      expect(stopwatch.elapsed, greaterThanOrEqualTo(const Duration(milliseconds: 500)));
    });

    test('throws AiSummarizationException after exhausting retries', () async {
      final service = GeminiSummarizerService.withGenerator((prompt) async {
        throw Exception('permanent failure');
      });

      expect(
        () => service.summarizeDocument(content: 'text', docType: 'pdf'),
        throwsA(isA<AiSummarizationException>()),
      );
    });

    test('fails fast on an invalid API key without retrying', () async {
      var attempts = 0;
      final service = GeminiSummarizerService.withGenerator((prompt) async {
        attempts++;
        throw InvalidApiKey('API key not valid. Please pass a valid API key.');
      });

      await expectLater(
        () => service.summarizeDocument(content: 'text', docType: 'pdf'),
        throwsA(
          isA<AiSummarizationException>().having(
            (e) => e.message,
            'message',
            contains('Invalid Gemini API key'),
          ),
        ),
      );
      expect(attempts, 1);
    });

    test('throws AiSummarizationException on malformed JSON', () async {
      final service = GeminiSummarizerService.withGenerator((prompt) async {
        return 'not valid json at all';
      });

      expect(
        () => service.summarizeDocument(content: 'text', docType: 'pdf'),
        throwsA(isA<AiSummarizationException>()),
      );
    });

    test('recovers from an un-escaped backslash in Gemini JSON (e.g. LaTeX notation)', () async {
      final service = GeminiSummarizerService.withGenerator((prompt) async {
        // Real-world failure: Gemini echoes LaTeX like $\Omega$ into a JSON string
        // without escaping the backslash, which plain jsonDecode rejects.
        return r'{"executiveSummary": "Uses $\Omega$ notation.", "sections": []}';
      });

      final result = await service.summarizeDocument(content: 'text', docType: 'pdf');

      expect(result.executiveSummary, r'Uses $\Omega$ notation.');
    });

    test('throws AiSummarizationException on a JSON response that is not an object', () async {
      final service = GeminiSummarizerService.withGenerator((prompt) async {
        return '[1, 2, 3]';
      });

      expect(
        () => service.summarizeDocument(content: 'text', docType: 'pdf'),
        throwsA(isA<AiSummarizationException>()),
      );
    });

    test('throws AiSummarizationException when Gemini returns an empty response', () async {
      final service = GeminiSummarizerService.withGenerator((prompt) async => '');

      expect(
        () => service.summarizeDocument(content: 'text', docType: 'pdf'),
        throwsA(isA<AiSummarizationException>()),
      );
    });
  });

  group('map-reduce chunking for oversized documents', () {
    test('summarizes each chunk independently then merges into one executive summary', () async {
      final promptsSeen = <String>[];
      final service = GeminiSummarizerService.withGenerator(
        (prompt) async {
          promptsSeen.add(prompt);
          if (prompt.contains('Merge them into ONE coherent executive summary')) {
            return '{"executiveSummary": "- Merged overview point"}';
          }
          final partNumber = promptsSeen.length;
          return '''
          {
            "executiveSummary": "- Part $partNumber point",
            "sections": [
              {"sectionTitle": "Section $partNumber", "summaryText": "Summary $partNumber", "keyPoints": ["kp$partNumber"]}
            ]
          }
          ''';
        },
        // A tiny per-chunk budget so two short paragraphs are enough to force
        // TextChunker to split into two chunks, without needing a
        // multi-hundred-thousand-character fixture.
        maxTokensPerChunk: 20,
      );

      // Two 50-char paragraphs: each fits within the 20-token (~80 char)
      // budget alone, but together they don't, so TextChunker puts each in
      // its own chunk rather than hard-splitting either one.
      final content = '${'A' * 50}\n\n${'B' * 50}';

      final result = await service.summarizeDocument(content: content, docType: 'pdf');

      // 2 chunk calls (map) + 1 merge call (reduce).
      expect(promptsSeen.length, 3);
      expect(result.executiveSummary, '- Merged overview point');
      expect(result.sections, hasLength(2));
      expect(result.sections.map((s) => s.sectionTitle), ['Section 1', 'Section 2']);
    });
  });
}
