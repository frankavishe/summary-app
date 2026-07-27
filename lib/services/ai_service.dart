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
  /// into one final result (reduce). Kept well under the spec's 50,000-token
  /// ceiling (section 8) so each map call stays focused on a small enough
  /// slice of text to produce a genuinely detailed summary instead of
  /// compressing dozens of pages into a handful of bullets.
  final int maxTokensPerChunk;

  static const int _defaultMaxTokensPerChunk = 20000;

  /// How many chunks are summarized concurrently during the map step. Large
  /// documents now produce more (smaller) chunks so each one summarizes in
  /// depth; running them in parallel keeps overall wall-clock time down
  /// instead of multiplying it by the extra chunk count.
  static const int _chunkConcurrency = 4;

  static const int _maxAttempts = 3;

  static ContentGenerator _createGenerator(String apiKey, String modelName) {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        responseMimeType: 'application/json',
        maxOutputTokens: 16384,
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

    final chunkSummaries = await _mapConcurrently(
      chunks,
      _chunkConcurrency,
      (chunk, i) => _summarizeSingle(
        content: chunk,
        docType: docType,
        partLabel: 'part ${i + 1} of ${chunks.length}',
      ),
    );
    return _reduce(chunkSummaries, docType: docType);
  }

  /// Runs [task] over [items] with at most [concurrency] calls in flight at
  /// once, returning results in the same order as [items] regardless of
  /// completion order.
  Future<List<R>> _mapConcurrently<T, R>(
    List<T> items,
    int concurrency,
    Future<R> Function(T item, int index) task,
  ) async {
    final results = List<R?>.filled(items.length, null);
    var nextIndex = 0;

    Future<void> worker() async {
      while (nextIndex < items.length) {
        final index = nextIndex++;
        results[index] = await task(items[index], index);
      }
    }

    final workerCount = items.length < concurrency ? items.length : concurrency;
    await Future.wait(List.generate(workerCount, (_) => worker()));
    return results.cast<R>();
  }

  /// Below this content length, [_summarizeSingle] gives up on splitting
  /// further and just surfaces whatever error occurred - splitting a sliver
  /// this small isn't going to fix a genuine failure.
  static const int _minSplittableChars = 2000;

  /// Caps how many times a single chunk can be recursively halved (so a
  /// pathological chunk can't recurse indefinitely); 3 levels already means
  /// up to 8-way splitting.
  static const int _maxSplitDepth = 3;

  /// Summarizes [content] via one Gemini call. Detailed per-section output
  /// occasionally overruns the model's output token cap and comes back as
  /// truncated (invalid) JSON; rather than losing the whole document to one
  /// oversized chunk, this splits the chunk in half and summarizes each half
  /// independently, recursing until each piece is small enough to fit.
  Future<GeneratedSummary> _summarizeSingle({
    required String content,
    required String docType,
    String? partLabel,
    int splitDepth = 0,
  }) async {
    final prompt = _buildPrompt(content: content, docType: docType, partLabel: partLabel);
    try {
      final responseText = await _generateWithRetry(prompt);
      return _parse(responseText);
    } on AiSummarizationException {
      if (splitDepth >= _maxSplitDepth || content.length < _minSplittableChars) rethrow;

      final (firstHalf, secondHalf) = _splitContentInHalf(content);
      final results = await Future.wait([
        _summarizeSingle(
          content: firstHalf,
          docType: docType,
          partLabel: partLabel,
          splitDepth: splitDepth + 1,
        ),
        _summarizeSingle(
          content: secondHalf,
          docType: docType,
          partLabel: partLabel,
          splitDepth: splitDepth + 1,
        ),
      ]);
      return GeneratedSummary(
        executiveSummary: results
            .map((r) => r.executiveSummary)
            .where((s) => s.isNotEmpty)
            .join('\n'),
        sections: results.expand((r) => r.sections).toList(),
      );
    }
  }

  /// Splits [content] roughly in half on a paragraph boundary so a recursive
  /// re-summarization doesn't cut a paragraph in two. Falls back to a plain
  /// character-count split if [content] is one giant paragraph.
  (String, String) _splitContentInHalf(String content) {
    final paragraphs = content.split(RegExp(r'\n\s*\n'));
    if (paragraphs.length > 1) {
      final target = content.length / 2;
      final first = StringBuffer();
      var splitIndex = paragraphs.length;
      for (var i = 0; i < paragraphs.length; i++) {
        if (first.isNotEmpty && first.length + paragraphs[i].length > target) {
          splitIndex = i;
          break;
        }
        if (first.isNotEmpty) first.write('\n\n');
        first.write(paragraphs[i]);
      }
      final second = paragraphs.sublist(splitIndex).join('\n\n');
      if (first.isNotEmpty && second.isNotEmpty) {
        return (first.toString(), second);
      }
    }
    final mid = content.length ~/ 2;
    return (content.substring(0, mid), content.substring(mid));
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
parts of a single $docType document. Merge them into ONE coherent executive summary describing
the document as a whole.
Cover every major theme, argument, or plot thread from across ALL parts, not just the first few -
longer documents deserve more bullet points, not fewer. Use as many bullet points as needed to do
that (typically 6-12 for a book-length document), rather than forcing everything into 3-5.
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

Be thorough, not brief: a reader should come away understanding the actual substance of this
text, not just that it exists. Identify EVERY distinct topic, chapter, or section present in
this text - don't skip or merge minor ones - and capture concrete details (names, numbers,
arguments, examples) rather than vague generalities. When in doubt, include more detail rather
than less.

Structure the response in JSON format with two keys:
1. "executiveSummary": An overview of THIS TEXT (4-6 bullet points).
2. "sections": An array with one entry per major topic/chapter found in this text. Each object
   has:
   - "sectionTitle": a short descriptive title
   - "summaryText": a detailed paragraph (roughly 4-8 sentences) explaining what this section
     covers and why it matters
   - "keyPoints": 5-10 specific, concrete bullet points from this section (facts, arguments,
     figures, examples - not one-line platitudes)

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
