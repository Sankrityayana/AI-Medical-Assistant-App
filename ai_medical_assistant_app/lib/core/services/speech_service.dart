import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText speechToText = SpeechToText();
  final FlutterTts tts = FlutterTts();

  Future<bool> initSpeech() => speechToText.initialize();

  Future<void> startListening(void Function(String) onResult) async {
    await speechToText.listen(
      onResult: (result) => onResult(result.recognizedWords),
    );
  }

  Future<void> stopListening() => speechToText.stop();

  Future<void> speak(String text) async {
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }
}
