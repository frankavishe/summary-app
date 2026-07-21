import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/services/extractors/docx_extractor.dart';

/// Hand-builds a minimal valid `.docx` (a zip containing `word/document.xml`)
/// so the extractor can be tested without a real Word-authored fixture file.
Uint8List _buildSampleDocx() {
  const documentXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p>
      <w:pPr><w:pStyle w:val="Title"/></w:pPr>
      <w:r><w:t>Quarterly Report</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
      <w:r><w:t>Chapter 1</w:t></w:r>
    </w:p>
    <w:p>
      <w:r><w:t>This is a plain paragraph of body text.</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr></w:pPr>
      <w:r><w:t>First list item</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr></w:pPr>
      <w:r><w:t>Second list item</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr><w:pStyle w:val="Heading2"/></w:pPr>
      <w:r><w:t>Subsection</w:t></w:r>
    </w:p>
  </w:body>
</w:document>
''';

  final contentBytes = utf8.encode(documentXml);
  final archive = Archive();
  archive.addFile(
    ArchiveFile('word/document.xml', contentBytes.length, contentBytes),
  );
  final bytes = ZipEncoder().encode(archive);
  return Uint8List.fromList(bytes!);
}

void main() {
  test('extractFromBytes converts headings, lists, and paragraphs to Markdown', () async {
    final bytes = _buildSampleDocx();

    final markdown = await DocxExtractorService.extractFromBytes(bytes);

    // Both "Title" and "HeadingN" styles map to Markdown level N (Title ~ H1).
    expect(markdown, contains('# Quarterly Report'));
    expect(markdown, contains('# Chapter 1'));
    expect(markdown, contains('This is a plain paragraph of body text.'));
    expect(markdown, contains('- First list item'));
    expect(markdown, contains('- Second list item'));
    expect(markdown, contains('## Subsection'));
  });

  test('extractFromBytes throws a FormatException for a non-docx zip', () async {
    final contentBytes = utf8.encode('hello');
    final archive = Archive();
    archive.addFile(ArchiveFile('not_a_document.txt', contentBytes.length, contentBytes));
    final bytes = Uint8List.fromList(ZipEncoder().encode(archive)!);

    expect(
      () => DocxExtractorService.extractFromBytes(bytes),
      throwsA(isA<Exception>()),
    );
  });
}
