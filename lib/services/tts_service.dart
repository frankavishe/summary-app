import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// The play/pause/stop state the Summary Viewer's TTS bar reflects.
enum TtsPlaybackState { stopped, playing, paused }

/// The subset of `flutter_tts`'s `FlutterTts` API that [TtsService] needs.
/// Lets tests inject a fake engine instead of going through a real platform
/// channel (which has no implementation in `flutter test`, matching the
/// `ContentGenerator` seam used by `ai_service.dart`).
abstract class TtsEngine {
  Future<void> speak(String text);
  Future<void> pause();
  Future<void> stop();
  void setStartHandler(VoidCallback handler);
  void setCompletionHandler(VoidCallback handler);
  void setPauseHandler(VoidCallback handler);
  void setContinueHandler(VoidCallback handler);
  void setCancelHandler(VoidCallback handler);
  void setErrorHandler(void Function(dynamic message) handler);
}

class FlutterTtsEngine implements TtsEngine {
  FlutterTtsEngine() : _tts = FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  @override
  Future<void> pause() async {
    await _tts.pause();
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  void setStartHandler(VoidCallback handler) => _tts.setStartHandler(handler);

  @override
  void setCompletionHandler(VoidCallback handler) => _tts.setCompletionHandler(handler);

  @override
  void setPauseHandler(VoidCallback handler) => _tts.setPauseHandler(handler);

  @override
  void setContinueHandler(VoidCallback handler) => _tts.setContinueHandler(handler);

  @override
  void setCancelHandler(VoidCallback handler) => _tts.setCancelHandler(handler);

  @override
  void setErrorHandler(void Function(dynamic message) handler) => _tts.setErrorHandler(handler);
}

/// Reads a summary aloud via the platform's text-to-speech engine, exposing a
/// [stateStream] so the Summary Viewer's play/pause/stop bar can reflect the
/// current playback state without polling.
///
/// Android's TTS engine generally doesn't support resuming mid-utterance
/// (unlike iOS), so [resume] restarts the last spoken text from the
/// beginning rather than a true resume - the pragmatic behavior for a
/// play/pause/stop bar on this platform.
class TtsService {
  TtsService() : _engine = FlutterTtsEngine() {
    _attachHandlers();
  }

  @visibleForTesting
  TtsService.withEngine(TtsEngine engine) : _engine = engine {
    _attachHandlers();
  }

  final TtsEngine _engine;
  final _stateController = StreamController<TtsPlaybackState>.broadcast();
  TtsPlaybackState _state = TtsPlaybackState.stopped;
  String? _lastText;

  TtsPlaybackState get state => _state;
  Stream<TtsPlaybackState> get stateStream => _stateController.stream;

  void _attachHandlers() {
    _engine.setStartHandler(() => _setState(TtsPlaybackState.playing));
    _engine.setCompletionHandler(() => _setState(TtsPlaybackState.stopped));
    _engine.setCancelHandler(() => _setState(TtsPlaybackState.stopped));
    _engine.setPauseHandler(() => _setState(TtsPlaybackState.paused));
    _engine.setContinueHandler(() => _setState(TtsPlaybackState.playing));
    _engine.setErrorHandler((_) => _setState(TtsPlaybackState.stopped));
  }

  void _setState(TtsPlaybackState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  /// Speaks [text] from the beginning, replacing anything currently playing.
  Future<void> speak(String text) async {
    _lastText = text;
    await _engine.speak(text);
  }

  /// Resumes playback of the last spoken text (see class doc - this restarts
  /// from the beginning rather than the paused position).
  Future<void> resume() async {
    final text = _lastText;
    if (text != null) {
      await _engine.speak(text);
    }
  }

  Future<void> pause() async {
    await _engine.pause();
  }

  Future<void> stop() async {
    await _engine.stop();
    _setState(TtsPlaybackState.stopped);
  }

  Future<void> dispose() async {
    await stop();
    await _stateController.close();
  }
}
