import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool enabled = true;

  TtsService() {
    _tts.setSpeechRate(0.47);
    _tts.setPitch(1.0);
  }

  Future speak(String text) async {
    if (!enabled) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future dispose() async {
    await _tts.stop();
  }
}
