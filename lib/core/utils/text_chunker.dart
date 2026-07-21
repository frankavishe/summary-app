/// Splits large document text into token-bounded chunks for Map-Reduce
/// summarization, per spec section 8 ("Implements Map-Reduce chunking when
/// input exceeds 50,000 tokens").
class TextChunker {
  const TextChunker._();

  /// Rough English-text heuristic: ~4 characters per token. Good enough to
  /// decide when to chunk without pulling in a real tokenizer.
  static int estimateTokens(String text) => (text.length / 4).ceil();

  /// Splits [text] into chunks whose estimated token count stays at or below
  /// [maxTokensPerChunk]. Splits on paragraph boundaries (blank lines) first
  /// so chunks don't cut a paragraph in half; a single paragraph that alone
  /// exceeds the limit is hard-split on the character budget as a fallback.
  static List<String> chunk(String text, {int maxTokensPerChunk = 50000}) {
    final maxChars = maxTokensPerChunk * 4;
    if (text.isEmpty) return [];
    if (estimateTokens(text) <= maxTokensPerChunk) return [text];

    final paragraphs = text.split(RegExp(r'\n\s*\n'));
    final chunks = <String>[];
    final current = StringBuffer();

    void flushCurrent() {
      if (current.isNotEmpty) {
        chunks.add(current.toString().trim());
        current.clear();
      }
    }

    for (final paragraph in paragraphs) {
      if (paragraph.trim().isEmpty) continue;

      if (paragraph.length > maxChars) {
        flushCurrent();
        chunks.addAll(_hardSplit(paragraph, maxChars));
        continue;
      }

      final wouldBeLength = current.length + paragraph.length + 2;
      if (current.isNotEmpty && wouldBeLength > maxChars) {
        flushCurrent();
      }
      if (current.isNotEmpty) current.write('\n\n');
      current.write(paragraph);
    }
    flushCurrent();

    return chunks;
  }

  static List<String> _hardSplit(String text, int maxChars) {
    final pieces = <String>[];
    for (var i = 0; i < text.length; i += maxChars) {
      final end = (i + maxChars < text.length) ? i + maxChars : text.length;
      pieces.add(text.substring(i, end));
    }
    return pieces;
  }
}
