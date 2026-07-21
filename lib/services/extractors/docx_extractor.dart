import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

/// Extracts headings (H1-H3), lists, and paragraph bodies from `.docx` files
/// by unzipping the package and parsing `word/document.xml` directly,
/// discarding styling nodes we don't care about. Runs inside a `compute()`
/// isolate so large documents don't block the UI thread.
class DocxExtractorService {
  const DocxExtractorService._();

  static Future<String> extractFromFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return extractFromBytes(bytes);
  }

  static Future<String> extractFromBytes(Uint8List bytes) {
    return compute(_extractSync, bytes);
  }
}

String _extractSync(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final documentFile = archive.findFile('word/document.xml');
  if (documentFile == null) {
    throw const FormatException('Not a valid .docx file: missing word/document.xml');
  }

  final xmlContent = utf8.decode(documentFile.content as List<int>);
  final document = XmlDocument.parse(xmlContent);

  final buffer = StringBuffer();
  for (final paragraph in document.findAllElements('p', namespace: '*')) {
    final text = _paragraphText(paragraph);
    if (text.isEmpty) continue;

    final headingLevel = _headingLevel(paragraph);
    if (headingLevel != null) {
      buffer.writeln('${'#' * headingLevel} $text');
    } else if (_isListItem(paragraph)) {
      buffer.writeln('- $text');
    } else {
      buffer.writeln(text);
    }
    buffer.writeln();
  }

  return buffer.toString().trim();
}

XmlElement? _firstOrNull(Iterable<XmlElement> elements) =>
    elements.isEmpty ? null : elements.first;

String _paragraphText(XmlElement paragraph) {
  final texts = <String>[];
  for (final run in paragraph.findElements('r', namespace: '*')) {
    for (final t in run.findElements('t', namespace: '*')) {
      texts.add(t.innerText);
    }
    if (run.findElements('tab', namespace: '*').isNotEmpty) {
      texts.add('\t');
    }
  }
  return texts.join().trim();
}

/// Maps a `w:pStyle` value like "Heading1" / "Title" to a Markdown heading
/// level (1-3), or null if the paragraph isn't a heading.
int? _headingLevel(XmlElement paragraph) {
  final pPr = _firstOrNull(paragraph.findElements('pPr', namespace: '*'));
  if (pPr == null) return null;
  final pStyle = _firstOrNull(pPr.findElements('pStyle', namespace: '*'));
  final styleVal = pStyle?.getAttribute('val', namespace: '*');
  if (styleVal == null) return null;

  if (styleVal.toLowerCase() == 'title') return 1;
  final match = RegExp(r'^Heading(\d)$', caseSensitive: false).firstMatch(styleVal);
  if (match == null) return null;
  return int.parse(match.group(1)!).clamp(1, 3);
}

bool _isListItem(XmlElement paragraph) {
  final pPr = _firstOrNull(paragraph.findElements('pPr', namespace: '*'));
  if (pPr == null) return false;
  return pPr.findElements('numPr', namespace: '*').isNotEmpty;
}
