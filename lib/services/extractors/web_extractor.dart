import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class WebExtractionResult {
  const WebExtractionResult({required this.title, required this.markdown});

  final String? title;
  final String markdown;
}

/// Downloads a web article and strips scripts, navigation, ads, and footers,
/// leaving only the main body content and heading tags - a hand-rolled
/// readability heuristic on top of `http` + `html` (there is no maintained
/// Dart port of Mozilla's Readability algorithm; see issues.md).
class WebExtractorService {
  const WebExtractorService._();

  static Future<WebExtractionResult> extractFromUrl(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: const {'User-Agent': 'Mozilla/5.0 (compatible; SummaReadBot/1.0)'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch $url (status ${response.statusCode})');
    }
    return compute(_extractSync, response.body);
  }
}

const _junkTags = {
  'script',
  'style',
  'noscript',
  'iframe',
  'nav',
  'footer',
  'header',
  'aside',
  'form',
  'svg',
  'button',
};

const _junkClassOrIdHints = {
  'advert',
  'advertisement',
  'sponsor',
  'banner',
  'cookie',
  'popup',
  'newsletter',
  'sidebar',
  'comment',
  'social',
  'share',
  'related',
  'breadcrumb',
  'nav-',
  'menu',
};

WebExtractionResult _extractSync(String htmlSource) {
  final document = html_parser.parse(htmlSource);

  for (final tag in _junkTags) {
    for (final element in document.querySelectorAll(tag).toList()) {
      element.remove();
    }
  }
  for (final element in document.querySelectorAll('*').toList()) {
    final classAndId = '${element.className} ${element.id}'.toLowerCase();
    if (_junkClassOrIdHints.any(classAndId.contains)) {
      element.remove();
    }
  }

  final title = document.querySelector('title')?.text.trim();
  final container = _pickMainContainer(document);

  final buffer = StringBuffer();
  _emitContent(container, buffer);

  return WebExtractionResult(title: title, markdown: buffer.toString().trim());
}

/// Picks the most likely "main content" element: prefer `<article>`/`<main>`
/// if substantial, otherwise the `<div>`/`<section>` with the best
/// text-density score (total text minus text inside links, which penalizes
/// link-heavy nav/list clutter that survived tag stripping).
dom.Element _pickMainContainer(dom.Document document) {
  final article = document.querySelector('article');
  if (article != null && _textLength(article) > 200) return article;

  final main = document.querySelector('main');
  if (main != null && _textLength(main) > 200) return main;

  dom.Element? best;
  var bestScore = 0;
  for (final candidate in document.querySelectorAll('div, section')) {
    final score = _textLength(candidate) - _linkTextLength(candidate);
    if (score > bestScore) {
      bestScore = score;
      best = candidate;
    }
  }
  return best ?? document.body ?? document.documentElement!;
}

int _textLength(dom.Element el) => el.text.trim().length;

int _linkTextLength(dom.Element el) {
  return el
      .querySelectorAll('a')
      .fold(0, (sum, a) => sum + a.text.trim().length);
}

void _emitContent(dom.Element container, StringBuffer buffer) {
  final blocks = container.querySelectorAll('h1, h2, h3, h4, h5, h6, p, li');
  if (blocks.isEmpty) {
    buffer.writeln(container.text.trim());
    return;
  }

  final headingPattern = RegExp(r'^h([1-6])$');
  for (final el in blocks) {
    final text = el.text.trim();
    if (text.isEmpty) continue;

    final headingMatch = headingPattern.firstMatch(el.localName ?? '');
    if (headingMatch != null) {
      final level = int.parse(headingMatch.group(1)!);
      buffer.writeln('${'#' * level} $text');
    } else if (el.localName == 'li') {
      buffer.writeln('- $text');
    } else {
      buffer.writeln(text);
    }
    buffer.writeln();
  }
}
