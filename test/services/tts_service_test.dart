import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/services/tts_service.dart';

class _FakeTtsEngine implements TtsEngine {
  final List<String> spoken = [];
  VoidCallback? _onStart;
  VoidCallback? _onCompletion;
  VoidCallback? _onCancel;
  VoidCallback? _onPause;

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
    _onStart?.call();
  }

  void completeCurrentUtterance() => _onCompletion?.call();

  @override
  Future<void> pause() async => _onPause?.call();

  @override
  Future<void> stop() async => _onCancel?.call();

  @override
  void setStartHandler(VoidCallback handler) => _onStart = handler;

  @override
  void setCompletionHandler(VoidCallback handler) => _onCompletion = handler;

  @override
  void setPauseHandler(VoidCallback handler) => _onPause = handler;

  @override
  void setContinueHandler(VoidCallback handler) {}

  @override
  void setCancelHandler(VoidCallback handler) => _onCancel = handler;

  @override
  void setErrorHandler(void Function(dynamic message) handler) {}
}

void main() {
  group('splitForSpeech', () {
    test('leaves short text untouched', () {
      expect(splitForSpeech('hello world', maxLength: 3500), ['hello world']);
    });

    test('splits long text on word boundaries under the limit', () {
      final text = List.filled(2000, 'word').join(' ');
      final chunks = splitForSpeech(text, maxLength: 100);
      expect(chunks, isNotEmpty);
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(100));
      }
      expect(chunks.join(' '), text);
    });

    test('hard-splits a single word longer than the limit', () {
      final word = 'a' * 250;
      final chunks = splitForSpeech(word, maxLength: 100);
      expect(chunks, ['a' * 100, 'a' * 100, 'a' * 50]);
    });

    test('empty input yields no chunks', () {
      expect(splitForSpeech('   ', maxLength: 100), isEmpty);
    });
  });

  group('TtsService chunk queueing', () {
    test(
      'a summary longer than the per-utterance limit is split and spoken as '
      'multiple queued engine calls, staying in "playing" state until the '
      'last chunk completes',
      () async {
        final engine = _FakeTtsEngine();
        final service = TtsService.withEngine(engine);
        final states = <TtsPlaybackState>[];
        service.stateStream.listen(states.add);

        final longText = List.filled(2000, 'word').join(' ');
        await service.speak(longText);
        expect(engine.spoken.length, 1);
        expect(service.state, TtsPlaybackState.playing);

        // Simulate the engine finishing each queued utterance in turn.
        while (engine.spoken.length < 2 || service.state != TtsPlaybackState.stopped) {
          final before = engine.spoken.length;
          engine.completeCurrentUtterance();
          if (engine.spoken.length == before && service.state == TtsPlaybackState.stopped) {
            break;
          }
        }

        expect(engine.spoken.length, greaterThan(1));
        expect(engine.spoken.join(' '), longText);
        expect(service.state, TtsPlaybackState.stopped);
      },
    );

    test('stop() clears any remaining queued chunks', () async {
      final engine = _FakeTtsEngine();
      final service = TtsService.withEngine(engine);

      final longText = List.filled(2000, 'word').join(' ');
      await service.speak(longText);
      expect(engine.spoken.length, 1);

      await service.stop();
      expect(service.state, TtsPlaybackState.stopped);

      // Even if the engine fires a stray completion after stop(), no further
      // chunk should be spoken.
      engine.completeCurrentUtterance();
      expect(engine.spoken.length, 1);
    });
  });
}
