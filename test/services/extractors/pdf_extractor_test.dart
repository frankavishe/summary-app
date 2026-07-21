import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/services/extractors/pdf_extractor.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Uint8List _buildSamplePdf(List<String> pageTexts) {
  final document = PdfDocument();
  final font = PdfStandardFont(PdfFontFamily.helvetica, 12);
  for (final text in pageTexts) {
    final page = document.pages.add();
    page.graphics.drawString(text, font, bounds: const Rect.fromLTWH(0, 0, 400, 100));
  }
  final bytes = Uint8List.fromList(document.saveSync());
  document.dispose();
  return bytes;
}

void main() {
  test('getPageCount reports the number of pages', () async {
    final bytes = _buildSamplePdf(['Page one text', 'Page two text', 'Page three text']);

    final count = await PdfExtractorService.getPageCount(bytes);

    expect(count, 3);
  });

  test('extractFromBytes extracts text per page with 1-based page numbers', () async {
    final bytes = _buildSamplePdf(['First page content', 'Second page content']);

    final result = await PdfExtractorService.extractFromBytes(bytes);

    expect(result.totalPageCount, 2);
    expect(result.pages, hasLength(2));
    expect(result.pages[0].pageNumber, 1);
    expect(result.pages[0].text, contains('First page content'));
    expect(result.pages[1].pageNumber, 2);
    expect(result.pages[1].text, contains('Second page content'));
    expect(result.toSourceText(), contains('--- Page 1 ---'));
    expect(result.toSourceText(), contains('--- Page 2 ---'));
  });

  test('extractFromBytes supports page-range subsetting', () async {
    final bytes = _buildSamplePdf(['Page A', 'Page B', 'Page C']);

    final result = await PdfExtractorService.extractFromBytes(
      bytes,
      startPageIndex: 1,
      endPageIndex: 1,
    );

    expect(result.totalPageCount, 3);
    expect(result.pages, hasLength(1));
    expect(result.pages.single.pageNumber, 2);
    expect(result.pages.single.text, contains('Page B'));
  });
}
