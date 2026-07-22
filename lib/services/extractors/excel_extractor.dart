import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

/// Converts `.xlsx` worksheets into Markdown tables for Gemini context, per
/// spec section 6.1 (Grid-to-Markdown Pipeline): iterates each worksheet,
/// skips empty rows, and emits a Markdown table with a header separator row.
/// Runs inside a `compute()` isolate so large spreadsheets don't block the UI
/// thread.
class ExcelExtractorService {
  const ExcelExtractorService._();

  static Future<String> extractFromFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return extractFromBytes(bytes);
  }

  static Future<String> extractFromBytes(Uint8List bytes) {
    return compute(_extractToMarkdownSync, bytes);
  }
}

String _extractToMarkdownSync(Uint8List bytes) {
  final excel = Excel.decodeBytes(bytes);
  final buffer = StringBuffer();

  for (final table in excel.tables.keys) {
    final sheet = excel.tables[table];
    if (sheet == null || sheet.maxRows == 0) continue;

    buffer.writeln('## Sheet: $table\n');

    var wroteHeaderRow = false;
    for (var i = 0; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.every((cell) => cell == null || cell.value == null)) continue;

      final rowCells = row
          .map((c) => c?.value?.toString().replaceAll('\n', ' ') ?? '')
          .toList();
      buffer.writeln('| ${rowCells.join(' | ')} |');

      // Header separator line after the first non-empty row, wherever it
      // falls (a leading blank row shouldn't suppress the divider).
      if (!wroteHeaderRow) {
        final separators = List.generate(rowCells.length, (_) => '---');
        buffer.writeln('| ${separators.join(' | ')} |');
        wroteHeaderRow = true;
      }
    }
    buffer.writeln('\n');
  }

  return buffer.toString();
}
