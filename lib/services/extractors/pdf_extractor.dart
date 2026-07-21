import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Text extracted from a single PDF page, 1-based [pageNumber] preserved for
/// citation references back to the source document.
class PdfPageText {
  const PdfPageText({required this.pageNumber, required this.text});

  final int pageNumber;
  final String text;
}

class PdfExtractionResult {
  const PdfExtractionResult({required this.pages, required this.totalPageCount});

  final List<PdfPageText> pages;
  final int totalPageCount;

  /// Joins all extracted pages into one document, with a page-marker header
  /// per page so downstream summarization can still cite page numbers.
  String toSourceText() {
    return pages
        .map((p) => '--- Page ${p.pageNumber} ---\n${p.text}')
        .join('\n\n');
  }
}

class _ExtractArgs {
  const _ExtractArgs(this.bytes, {this.startPageIndex, this.endPageIndex});

  final Uint8List bytes;
  final int? startPageIndex;
  final int? endPageIndex;
}

/// Extracts text from PDF documents page-by-page using `syncfusion_flutter_pdf`,
/// preserving page indices for citations. Runs inside a `compute()` isolate so
/// large PDFs don't block the UI thread.
class PdfExtractorService {
  const PdfExtractorService._();

  /// Returns the page count of a PDF without extracting any text - useful for
  /// callers deciding whether to subset a massive file into page ranges
  /// before requesting full extraction.
  static Future<int> getPageCount(Uint8List bytes) {
    return compute(_pageCountSync, bytes);
  }

  static Future<PdfExtractionResult> extractFromFile(
    String filePath, {
    int? startPageIndex,
    int? endPageIndex,
  }) async {
    final bytes = await File(filePath).readAsBytes();
    return extractFromBytes(
      bytes,
      startPageIndex: startPageIndex,
      endPageIndex: endPageIndex,
    );
  }

  /// Extracts text for [startPageIndex]..[endPageIndex] (inclusive, 0-based).
  /// Omit both to extract the entire document. Passing an explicit range
  /// lets callers subset massive files into page-range batches instead of
  /// holding the whole document's text in memory at once.
  static Future<PdfExtractionResult> extractFromBytes(
    Uint8List bytes, {
    int? startPageIndex,
    int? endPageIndex,
  }) {
    return compute(
      _extractSync,
      _ExtractArgs(bytes, startPageIndex: startPageIndex, endPageIndex: endPageIndex),
    );
  }
}

int _pageCountSync(Uint8List bytes) {
  final document = PdfDocument(inputBytes: bytes);
  try {
    return document.pages.count;
  } finally {
    document.dispose();
  }
}

PdfExtractionResult _extractSync(_ExtractArgs args) {
  final document = PdfDocument(inputBytes: args.bytes);
  try {
    final totalPageCount = document.pages.count;
    final start = args.startPageIndex ?? 0;
    final end = args.endPageIndex ?? totalPageCount - 1;
    final extractor = PdfTextExtractor(document);

    final pages = <PdfPageText>[];
    for (var i = start; i <= end; i++) {
      final text = extractor.extractText(startPageIndex: i, endPageIndex: i);
      pages.add(PdfPageText(pageNumber: i + 1, text: text.trim()));
    }

    return PdfExtractionResult(pages: pages, totalPageCount: totalPageCount);
  } finally {
    document.dispose();
  }
}
