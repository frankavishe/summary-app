import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/services/extractors/web_extractor.dart';

const _samplePage = '''
<!DOCTYPE html>
<html>
<head><title>Sample Article Title</title></head>
<body>
  <nav><a href="/">Home</a><a href="/about">About</a><a href="/contact">Contact</a></nav>
  <header><div class="banner">Subscribe to our newsletter!</div></header>
  <script>console.log('tracking pixel');</script>
  <article>
    <h1>Main Article Heading</h1>
    <p>This is the first paragraph of the real article content, long enough to score well.</p>
    <h2>A Subheading</h2>
    <p>This is the second paragraph with more substantive body content for the reader.</p>
    <ul><li>First key point</li><li>Second key point</li></ul>
  </article>
  <aside class="sidebar"><a href="/related1">Related 1</a><a href="/related2">Related 2</a></aside>
  <div id="cookie-consent-banner">We use cookies. Accept?</div>
  <footer>Copyright 2026. All rights reserved.</footer>
</body>
</html>
''';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) {
      request.response
        ..headers.contentType = ContentType.html
        ..write(_samplePage);
      request.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('extractFromUrl strips nav/ads/scripts/footers and keeps article content', () async {
    final url = 'http://127.0.0.1:${server.port}/';

    final result = await WebExtractorService.extractFromUrl(url);

    expect(result.title, 'Sample Article Title');
    expect(result.markdown, contains('# Main Article Heading'));
    expect(result.markdown, contains('## A Subheading'));
    expect(result.markdown, contains('first paragraph of the real article content'));
    expect(result.markdown, contains('- First key point'));
    expect(result.markdown, contains('- Second key point'));

    expect(result.markdown, isNot(contains('Subscribe to our newsletter')));
    expect(result.markdown, isNot(contains('We use cookies')));
    expect(result.markdown, isNot(contains('Copyright 2026')));
    expect(result.markdown, isNot(contains('tracking pixel')));
    expect(result.markdown, isNot(contains('Related 1')));
  });

  test('extractFromUrl throws on a non-2xx response', () async {
    await server.close(force: true);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) {
      request.response.statusCode = 404;
      request.response.close();
    });
    final url = 'http://127.0.0.1:${server.port}/missing';

    expect(() => WebExtractorService.extractFromUrl(url), throwsException);
  });
}
