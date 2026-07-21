import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/core/utils/text_chunker.dart';

void main() {
  group('TextChunker.estimateTokens', () {
    test('estimates roughly 4 characters per token', () {
      expect(TextChunker.estimateTokens('abcd'), 1);
      expect(TextChunker.estimateTokens('a' * 40), 10);
    });
  });

  group('TextChunker.chunk', () {
    test('returns the whole text as one chunk when under the limit', () {
      const text = 'Paragraph one.\n\nParagraph two.';
      final chunks = TextChunker.chunk(text, maxTokensPerChunk: 50000);
      expect(chunks, [text]);
    });

    test('returns an empty list for empty input', () {
      expect(TextChunker.chunk(''), isEmpty);
    });

    test('splits on paragraph boundaries once the token budget is exceeded', () {
      // Each paragraph is 400 chars (~100 tokens). maxTokensPerChunk of 150
      // (~600 chars) should fit at most one paragraph per chunk.
      final paragraphs = List.generate(5, (i) => 'Paragraph $i: ${'x' * 390}');
      final text = paragraphs.join('\n\n');

      final chunks = TextChunker.chunk(text, maxTokensPerChunk: 150);

      expect(chunks.length, 5);
      for (var i = 0; i < paragraphs.length; i++) {
        expect(chunks[i], paragraphs[i]);
      }
    });

    test('hard-splits a single paragraph that alone exceeds the limit', () {
      final hugeParagraph = 'y' * 1000; // ~250 tokens
      final chunks = TextChunker.chunk(hugeParagraph, maxTokensPerChunk: 100);

      expect(chunks.length, greaterThan(1));
      expect(chunks.join(), hugeParagraph);
      for (final chunk in chunks) {
        expect(TextChunker.estimateTokens(chunk), lessThanOrEqualTo(100));
      }
    });
  });
}
