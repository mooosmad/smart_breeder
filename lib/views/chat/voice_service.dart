import 'dart:async';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class VoiceService extends GetxController {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  // États observables
  final RxBool isListening = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString recognizedText = ''.obs;
  final RxString speechStatus = ''.obs;
  final RxDouble soundLevel = 0.0.obs;
  
  // Paramètres de configuration
  final String locale = 'fr-FR'; // Français
  final double speechTimeout = 30.0; // 30 secondes max
  final double pauseTimeout = 3.0;   // 3 secondes de pause
  
  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialiser Speech-to-Text
      await _initializeSpeechToText();
      
      // Initialiser Text-to-Speech
      await _initializeTextToSpeech();
      
      isInitialized.value = true;
      print('Services vocaux initialisés avec succès');
      
    } catch (e) {
      print('Erreur initialisation services vocaux: $e');
      _showVoiceError('Erreur d\'initialisation des services vocaux');
    }
  }

  Future<void> _initializeSpeechToText() async {
    // Vérifier les permissions
    final micPermission = await Permission.microphone.request();
    if (micPermission != PermissionStatus.granted) {
      throw Exception('Permission microphone refusée');
    }

    final available = await _speechToText.initialize(
      onError: _onSpeechError,
      onStatus: _onSpeechStatus,
      debugLogging: true,
    );

    if (!available) {
      throw Exception('Speech-to-Text non disponible sur cet appareil');
    }
  }

  Future<void> _initializeTextToSpeech() async {
    await _flutterTts.setLanguage(locale);
    await _flutterTts.setSpeechRate(0.8); // Vitesse de lecture
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setPitch(1.0);

    // Gestionnaires d'événements TTS
    _flutterTts.setStartHandler(() {
      isSpeaking.value = true;
    });

    _flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });

    _flutterTts.setErrorHandler((msg) {
      isSpeaking.value = false;
      print('Erreur TTS: $msg');
    });
  }

  Future<String?> startListening() async {
    if (!isInitialized.value) {
      _showVoiceError('Services vocaux non initialisés');
      return null;
    }

    if (isListening.value) {
      print('Écoute déjà en cours');
      return null;
    }

    try {
      // Arrêter la synthèse vocale si en cours
      if (isSpeaking.value) {
        await stopSpeaking();
      }

      // Reset des états
      recognizedText.value = '';
      speechStatus.value = 'Initialisation...';
      soundLevel.value = 0.0;

      // Completer pour attendre la fin de l'écoute
      final Completer<String?> completer = Completer<String?>();

      // Démarrer l'écoute
      await _speechToText.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;
          
          if (result.finalResult) {
            // Résultat final obtenu
            completer.complete(result.recognizedWords.isNotEmpty 
                ? result.recognizedWords 
                : null);
          }
        },
        onSoundLevelChange: (level) {
          soundLevel.value = level.clamp(0.0, 1.0);
        },
        listenFor: Duration(seconds: speechTimeout.toInt()),
        pauseFor: Duration(seconds: pauseTimeout.toInt()),
        partialResults: true,
        localeId: locale,
        cancelOnError: true,
      );

      isListening.value = true;
      speechStatus.value = 'Parlez maintenant...';

      // Timeout de sécurité
      Timer(Duration(seconds: speechTimeout.toInt() + 5), () {
        if (!completer.isCompleted) {
          stopListening();
          completer.complete(recognizedText.value.isNotEmpty 
              ? recognizedText.value 
              : null);
        }
      });

      return await completer.future;

    } catch (e) {
      print('Erreur startListening: $e');
      _handleSpeechError(e.toString());
      return null;
    }
  }

  Future<void> stopListening() async {
    if (isListening.value) {
      await _speechToText.stop();
      isListening.value = false;
      speechStatus.value = '';
    }
  }

  Future<void> speak(String text) async {
    if (!isInitialized.value || text.trim().isEmpty) return;

    try {
      // Nettoyer le texte pour la synthèse vocale
      final cleanText = _cleanTextForSpeech(text);
      
      isSpeaking.value = true;
      await _flutterTts.speak(cleanText);
      
    } catch (e) {
      print('Erreur speak: $e');
      isSpeaking.value = false;
      _showVoiceError('Erreur de synthèse vocale');
    }
  }

  Future<void> stopSpeaking() async {
    if (isSpeaking.value) {
      await _flutterTts.stop();
      isSpeaking.value = false;
    }
  }

  String _cleanTextForSpeech(String text) {
    // Supprimer le markdown et autres formatages
    return text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // Gras
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')     // Italique
        .replaceAll(RegExp(r'`(.*?)`'), r'$1')       // Code inline
        .replaceAll(RegExp(r'#{1,6}\s*'), '')        // Titres
        .replaceAll(RegExp(r'\n\s*[-*+]\s*'), '\n')  // Listes
        .replaceAll(RegExp(r'\n{2,}'), '\n')         // Lignes vides multiples
        .trim();
  }

  void _onSpeechError(dynamic error) {
    print('Erreur Speech: $error');
    _handleSpeechError(error.toString());
  }

  void _onSpeechStatus(String status) {
    print('Status speech: $status');
    
    switch (status) {
      case 'listening':
        speechStatus.value = '🎤 En écoute...';
        break;
      case 'notListening':
        if (isListening.value) {
          speechStatus.value = '⏸️ Traitement...';
        }
        break;
      case 'done':
        speechStatus.value = recognizedText.value.isNotEmpty 
            ? '✅ Texte capturé' 
            : '❌ Aucun texte détecté';
        break;
      default:
        speechStatus.value = status;
    }
  }

  void _handleSpeechError(String error) {
    isListening.value = false;
    
    String userMessage = 'Erreur de reconnaissance vocale';
    
    if (error.contains('timeout') || error.contains('speech_timeout')) {
      userMessage = 'Temps d\'écoute écoulé. Réessayez en parlant plus fort.';
      speechStatus.value = '⏰ Temps écoulé';
    } else if (error.contains('network')) {
      userMessage = 'Connexion internet requise pour la reconnaissance vocale.';
      speechStatus.value = '🌐 Pas de réseau';
    } else if (error.contains('permission')) {
      userMessage = 'Permission microphone requise.';
      speechStatus.value = '🚫 Permission refusée';
    } else if (error.contains('not_available')) {
      userMessage = 'Service de reconnaissance vocale non disponible.';
      speechStatus.value = '❌ Service indisponible';
    } else {
      speechStatus.value = '❌ Erreur technique';
    }

    _showVoiceError(userMessage);
  }

  void _showVoiceError(String message) {
    Get.snackbar(
      'Erreur Vocale',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.mic_off, color: Colors.red),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      isDismissible: true,
    );
  }

  // Méthodes utilitaires pour l'interface
  bool get canStartListening => 
      isInitialized.value && !isListening.value && !isSpeaking.value;

  bool get canStopListening => isListening.value;

  bool get canSpeak => isInitialized.value && !isSpeaking.value;

  bool get canStopSpeaking => isSpeaking.value;

  String get currentStatus {
    if (!isInitialized.value) return 'Initialisation...';
    if (isListening.value) return speechStatus.value;
    if (isSpeaking.value) return '🔊 Lecture en cours...';
    return 'Prêt';
  }

  // Nettoyage des ressources
  @override
  void onClose() {
    stopListening();
    stopSpeaking();
    _speechToText.cancel();
    _flutterTts.stop();
    super.onClose();
  }
}