/// Strips common Markdown syntax characters, leaving plain readable text -
/// shared by the TTS speech script (summary_detail_page.dart) and the Home
/// dashboard's card preview snippets (home_page.dart), both of which need to
/// show/speak `SummaryRecord.executiveSummary` without literal `**`/`#`/etc.
String stripMarkdown(String text) {
  return text.replaceAll(RegExp(r'[*_#`>-]'), '').trim();
}

/// A single-line, length-bounded preview of [markdown] with syntax stripped
/// and internal whitespace/newlines collapsed - used for card subtitles.
String previewText(String markdown, {int maxLength = 140}) {
  final collapsed = stripMarkdown(markdown).replaceAll(RegExp(r'\s+'), ' ').trim();
  if (collapsed.length <= maxLength) return collapsed;
  return '${collapsed.substring(0, maxLength).trimRight()}…';
}
