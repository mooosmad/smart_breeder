import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService extends GetxService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  final RxBool isListening = false.obs;
  final RxBool isAvailable = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxString lastWords = ''.obs;
  final RxDouble confidence = 0.0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initSpeech();
    await _initTts();
  }

  Future<void> _initSpeech() async {
    try {
      isAvailable.value = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: false,
      );
    } catch (e) {
      print('Erreur initialisation speech: $e');
      isAvailable.value = false;
    }
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("fr-FR");
      await _flutterTts.setSpeechRate(0.8);
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        isSpeaking.value = true;
      });

      _flutterTts.setCompletionHandler(() {
        isSpeaking.value = false;
      });

      _flutterTts.setErrorHandler((message) {
        isSpeaking.value = false;
        print('Erreur TTS: $message');
      });
    } catch (e) {
      print('Erreur initialisation TTS: $e');
    }
  }

  void _onSpeechStatus(String status) {
    print('Status speech: $status');
    if (status == 'notListening') {
      isListening.value = false;
    }
  }

  void _onSpeechError(dynamic error) {
    print('Erreur speech: $error');
    isListening.value = false;
  }

  Future<String?> startListening() async {
    if (!isAvailable.value) return null;

    if (isListening.value) {
      await stopListening();
      return null;
    }

    lastWords.value = '';
    confidence.value = 0.0;

    try {
      isListening.value = true;
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'fr_FR',
        onSoundLevelChange: (level) => confidence.value = level,
      );
      
      // Attendre que l'écoute se termine
      await Future.delayed(const Duration(seconds: 10));
      return lastWords.value.isNotEmpty ? lastWords.value : null;
    } catch (e) {
      print('Erreur start listening: $e');
      isListening.value = false;
      return null;
    }
  }

  Future<void> stopListening() async {
    if (isListening.value) {
      await _speechToText.stop();
      isListening.value = false;
    }
  }

  void _onSpeechResult(dynamic result) {
    if (result.recognizedWords.isNotEmpty) {
      lastWords.value = result.recognizedWords;
      confidence.value = result.confidence;
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      // Arrêter toute lecture en cours
      await _flutterTts.stop();
      
      // Commencer la nouvelle lecture
      await _flutterTts.speak(text);
    } catch (e) {
      print('Erreur speak: $e');
      isSpeaking.value = false;
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      isSpeaking.value = false;
    } catch (e) {
      print('Erreur stop speaking: $e');
    }
  }

  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  @override
  void onClose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.onClose();
  }
}