import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../core/utils/text_chunker.dart';

/// Thrown for both Gemini API failures and malformed/unexpected JSON
/// responses, so callers can show one consistent error state instead of
/// crashing.
class AiSummarizationException implements Exception {
  const AiSummarizationException(this.message);

  final String message;

  @override
  String toString() => 'AiSummarizationException: $message';
}

class SectionSummaryData {
  const SectionSummaryData({
    required this.sectionTitle,
    required this.summaryText,
    required this.keyPoints,
  });

  factory SectionSummaryData.fromJson(Map<String, dynamic> json) {
    return SectionSummaryData(
      sectionTitle: json['sectionTitle']?.toString() ?? '',
      summaryText: json['summaryText']?.toString() ?? '',
      keyPoints: _asStringList(json['keyPoints']),
    );
  }

  final String sectionTitle;
  final String summaryText;
  final List<String> keyPoints;
}

/// The parsed result of a Gemini summarization call - shaped to map directly
/// onto `SummaryRecord`/`SectionSummary` (see `models/summary_record.dart`).
class GeneratedSummary {
  const GeneratedSummary({required this.executiveSummary, required this.sections});

  factory GeneratedSummary.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'];
    return GeneratedSummary(
      executiveSummary: _asExecutiveSummaryText(json['executiveSummary']),
      sections: sectionsJson is List
          ? sectionsJson
              .whereType<Map<String, dynamic>>()
              .map(SectionSummaryData.fromJson)
              .toList()
          : const [],
    );
  }

  final String executiveSummary;
  final List<SectionSummaryData> sections;
}

List<String> _asStringList(dynamic value) {
  if (value is List) return value.map((e) => e.toString()).toList();
  if (value is String && value.isNotEmpty) return [value];
  return const [];
}

/// Gemini sometimes returns the executive summary as a JSON array of bullet
/// strings and sometimes as one pre-formatted string; `SummaryRecord.
/// executiveSummary` is a single `String`, so normalize either shape into one
/// Markdown bullet list.
String _asExecutiveSummaryText(dynamic value) {
  if (value is List) {
    return value.map((e) => '- $e').join('\n');
  }
  return value?.toString() ?? '';
}

/// A prompt → raw response-text function. The real implementation calls
/// Gemini; tests inject a fake one so the chunking/parsing/merge logic can be
/// exercised without any network access or API key.
typedef ContentGenerator = Future<String> Function(String prompt);

/// Summarizes extracted document text via the Gemini API (spec section 6.2),
/// transparently applying Map-Reduce chunking (spec section 8) for documents
/// over the token budget.
class GeminiSummarizerService {
  GeminiSummarizerService(
    String apiKey, {
    String modelName = 'gemini-flash-latest',
    this.maxTokensPerChunk = _defaultMaxTokensPerChunk,
  }) : _generate = _createGenerator(apiKey, modelName);

  /// Injects a fake [ContentGenerator] for testing instead of a real Gemini
  /// client. [maxTokensPerChunk] can be set low so tests can exercise the
  /// Map-Reduce path without needing a multi-hundred-thousand-character
  /// fixture.
  @visibleForTesting
  GeminiSummarizerService.withGenerator(
    ContentGenerator generator, {
    this.maxTokensPerChunk = _defaultMaxTokensPerChunk,
  }) : _generate = generator;

  final ContentGenerator _generate;

  /// Documents whose estimated token count exceeds this are split via
  /// [TextChunker] and summarized chunk-by-chunk (map) before being merged
  /// into one final result (reduce). Defaults to the spec's 50,000-token
  /// threshold (section 8).
  final int maxTokensPerChunk;

  static const int _defaultMaxTokensPerChunk = 50000;
  static const int _maxAttempts = 3;

  static ContentGenerator _createGenerator(String apiKey, String modelName) {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        responseMimeType: 'application/json',
      ),
    );
    return (prompt) async {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    };
  }

  /// Summarizes [content] (already-extracted plain text/Markdown) into a
  /// structured [GeneratedSummary]. For documents whose estimated token count
  /// exceeds [maxTokensPerChunk], each chunk is summarized independently
  /// (map) and the chunk summaries are merged into one final result (reduce).
  Future<GeneratedSummary> summarizeDocument({
    required String content,
    required String docType,
  }) async {
    final chunks = TextChunker.chunk(content, maxTokensPerChunk: maxTokensPerChunk);
    if (chunks.length <= 1) {
      return _summarizeSingle(
        content: chunks.isEmpty ? content : chunks.first,
        docType: docType,
      );
    }

    final chunkSummaries = <GeneratedSummary>[];
    for (var i = 0; i < chunks.length; i++) {
      chunkSummaries.add(
        await _summarizeSingle(
          content: chunks[i],
          docType: docType,
          partLabel: 'part ${i + 1} of ${chunks.length}',
        ),
      );
    }
    return _reduce(chunkSummaries, docType: docType);
  }

  Future<GeneratedSummary> _summarizeSingle({
    required String content,
    required String docType,
    String? partLabel,
  }) async {
    final prompt = _buildPrompt(content: content, docType: docType, partLabel: partLabel);
    final responseText = await _generateWithRetry(prompt);
    return _parse(responseText);
  }

  /// Merges the executive summaries of each chunk into one coherent overview
  /// via a final Gemini call, and flattens all chunk sections together.
  Future<GeneratedSummary> _reduce(
    List<GeneratedSummary> chunkSummaries, {
    required String docType,
  }) async {
    final allSections = chunkSummaries.expand((s) => s.sections).toList();
    final partSummaries = chunkSummaries
        .map((s) => s.executiveSummary)
        .where((s) => s.isNotEmpty)
        .join('\n');

    if (partSummaries.isEmpty) {
      return GeneratedSummary(executiveSummary: '', sections: allSections);
    }

    final prompt = '''
You are an expert summary generator. Below are executive summaries generated from consecutive
parts of a single $docType document. Merge them into ONE coherent executive summary (3-5 bullet
points) describing the document as a whole.
Respond in JSON with exactly one key, "executiveSummary", containing a single string of Markdown
bullet points.

Part summaries:
$partSummaries
''';

    final responseText = await _generateWithRetry(prompt);
    final json = _decodeJson(responseText);
    final merged = _asExecutiveSummaryText(json['executiveSummary']);

    return GeneratedSummary(
      executiveSummary: merged.isNotEmpty ? merged : partSummaries,
      sections: allSections,
    );
  }

  String _buildPrompt({
    required String content,
    required String docType,
    String? partLabel,
  }) {
    final partNote = partLabel != null ? ' (this is $partLabel of a larger document)' : '';
    return '''
You are an expert summary generator. Summarize the following $docType document$partNote.
Structure the response in JSON format with two keys:
1. "executiveSummary": High-level executive overview (3-5 bullet points).
2. "sections": List of objects with "sectionTitle", "summaryText", and "keyPoints".

Document Text:
$content
''';
  }

  Future<String> _generateWithRetry(String prompt) async {
    Object? lastError;
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final text = await _generate(prompt);
        if (text.isEmpty) {
          throw const AiSummarizationException('Gemini returned an empty response.');
        }
        return text;
      } catch (e) {
        lastError = e;
        if (attempt < _maxAttempts) {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }
    throw AiSummarizationException('Gemini API request failed after $_maxAttempts attempts: $lastError');
  }

  GeneratedSummary _parse(String responseText) {
    final json = _decodeJson(responseText);
    try {
      return GeneratedSummary.fromJson(json);
    } catch (e) {
      throw AiSummarizationException('Failed to parse Gemini response into a summary: $e');
    }
  }

  Map<String, dynamic> _decodeJson(String responseText) {
    Object? decoded;
    try {
      decoded = jsonDecode(responseText);
    } catch (e) {
      throw AiSummarizationException('Gemini did not return valid JSON: $e');
    }
    if (decoded is Map<String, dynamic>) return decoded;
    throw const AiSummarizationException('Expected a JSON object at the top level of the Gemini response.');
  }
}
