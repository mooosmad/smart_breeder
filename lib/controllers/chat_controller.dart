import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smart_breeder/data/models/chat_message_model.dart';
import 'package:smart_breeder/data/models/animal_model.dart';
import 'package:smart_breeder/data/services/database_helper.dart';
import 'package:smart_breeder/data/services/gemini_service.dart';
import 'package:smart_breeder/data/services/voice_service.dart';
import 'package:smart_breeder/controllers/animal_controller.dart';

class ChatController extends GetxController {
  final DatabaseHelper _dbHelper = Get.find<DatabaseHelper>();
  final GeminiService _geminiService = Get.find<GeminiService>();
  final VoiceService _voiceService = Get.find<VoiceService>();
  final AnimalController _animalController = Get.find<AnimalController>();

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool isListening = false.obs;
  final RxBool isRecording = false.obs; // Nouvel état pour l'enregistrement
  final RxBool isSpeaking = false.obs; // Nouvel état pour la synthèse vocale
  final RxString selectedAnimalContext = ''.obs;
  final RxString recordingStatus = ''.obs; // Status de l'enregistrement
  final RxDouble recordingVolume = 0.0.obs; // Volume du micro (optionnel)

  // Prompt système amélioré pour SmartBreeder
  final String systemPrompt = '''
Vous êtes SmartBreeder Assistant, un expert en santé animale et gestion d'élevage. Votre rôle est d'aider les éleveurs à:
1. Comprendre les protocoles vétérinaires (vaccins, traitements)
2. Planifier les soins préventifs
3. Optimiser les dépenses liées à l'élevage
4. Identifier les risques sanitaires
5. Fournir des conseils adaptés au type d'animal et à la région

Règles de base:
- Soyez clair, concis et utilisez un langage accessible
- Fournissez des informations vérifiées par des vétérinaires
- Demandez des précisions si nécessaire (type/nombre d'animaux, région, saison)
- Pour les questions complexes, proposez de connecter avec un expert
- Mentionnez toujours les risques potentiels et les signes d'alerte
- Proposez des solutions économiques quand possible

Format des réponses:
1. Réponse directe à la question
2. Informations complémentaires utiles
3. Suggestions d'actions (si applicable)
4. Rappel des prochains soins à prévoir (si pertinent)

Réponds en markdown pour la mise en forme (titres, listes, gras, etc.).
''';

  @override
  void onInit() {
    super.onInit();
    loadChatHistory();
    
    // Écoute des changements d'état vocal
    ever(_voiceService.isListening, (bool listening) {
      isListening.value = listening;
      if (listening) {
        isRecording.value = true;
        recordingStatus.value = "🎤 Parlez maintenant...";
      } else {
        isRecording.value = false;
        recordingStatus.value = "";
      }
    });
  }

  Future<void> loadChatHistory() async {
    try {
      messages.value = await _dbHelper.getChatMessages();
      _scrollToBottom();
    } catch (e) {
      print('Erreur chargement historique chat: $e');
    }
  }

  Future<void> sendMessage(String text, {bool isVoiceMessage = false}) async {
    if (text.trim().isEmpty) return;

    // Arrêter la synthèse vocale si en cours
    if (isSpeaking.value) {
      stopSpeaking();
    }

    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: text.trim(),
      sender: 'user',
      timestamp: DateTime.now(),
      isVoiceMessage: isVoiceMessage,
      animalContext: selectedAnimalContext.value.isNotEmpty
          ? selectedAnimalContext.value
          : null,
    );

    messages.add(userMessage);
    await _dbHelper.insertChatMessage(userMessage);

    messageController.clear();
    _scrollToBottom();

    await _generateAIResponse(text);
  }

  Future<void> _generateAIResponse(String userMessage) async {
    isTyping.value = true;

    try {
      AnimalModel? animalContext;
      if (selectedAnimalContext.value.isNotEmpty) {
        animalContext = _animalController.animals
            .firstWhereOrNull((animal) => animal.id.toString() == selectedAnimalContext.value);
      }

      // Utilisation du prompt système amélioré
      final response = await _geminiService.generateVeterinaryAdvice(
        userMessage,
        animalContext: animalContext,
        customSystemPrompt: systemPrompt,
      );

      final aiMessage = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: response,
        sender: 'ai',
        timestamp: DateTime.now(),
        animalContext: selectedAnimalContext.value.isNotEmpty
            ? selectedAnimalContext.value
            : null,
      );

      messages.add(aiMessage);
      await _dbHelper.insertChatMessage(aiMessage);

      // Synthèse vocale automatique avec indicateur
      await startSpeaking(response);

    } catch (e) {
      final errorMessage = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: 'Désolé, je ne peux pas répondre pour le moment. Vérifiez votre connexion internet.',
        sender: 'ai',
        timestamp: DateTime.now(),
      );

      messages.add(errorMessage);
      await _dbHelper.insertChatMessage(errorMessage);
    } finally {
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  Future<void> startVoiceInput() async {
    try {
      // Arrêter la synthèse vocale si en cours
      if (isSpeaking.value) {
        stopSpeaking();
      }

      isRecording.value = true;
      recordingStatus.value = "🎤 Initialisation...";
      
      // Feedback haptique
      // HapticFeedback.lightImpact(); // Décommentez si disponible
      
      final spokenText = await _voiceService.startListening();
      
      if (spokenText != null && spokenText.isNotEmpty) {
        recordingStatus.value = "✅ Message reçu";
        await Future.delayed(const Duration(milliseconds: 500)); // Petit délai pour le feedback
        await sendMessage(spokenText, isVoiceMessage: true);
      } else {
        recordingStatus.value = "❌ Aucun message détecté";
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    } catch (e) {
      recordingStatus.value = "❌ Erreur d'enregistrement";
      
      String errorMessage = 'Impossible d\'utiliser la reconnaissance vocale';
      
      // Messages d'erreur plus spécifiques
      if (e.toString().contains('timeout')) {
        errorMessage = 'Temps d\'écoute écoulé. Réessayez.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission microphone requise';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Connexion internet requise';
      }
      
      Get.snackbar(
        'Erreur Vocale',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.mic_off, color: Colors.red),
      );
      
      await Future.delayed(const Duration(milliseconds: 1500));
    } finally {
      isRecording.value = false;
      recordingStatus.value = "";
    }
  }

  void stopVoiceInput() {
    _voiceService.stopListening();
    isRecording.value = false;
    recordingStatus.value = "";
  }

  Future<void> startSpeaking(String text) async {
    try {
      isSpeaking.value = true;
      await _voiceService.speak(text);
    } catch (e) {
      print('Erreur synthèse vocale: $e');
    } finally {
      isSpeaking.value = false;
    }
  }

  void stopSpeaking() {
    _voiceService.stopSpeaking();
    isSpeaking.value = false;
  }

  void setAnimalContext(String? animalId) {
    selectedAnimalContext.value = animalId ?? '';
  }

  String getAnimalContextName() {
    if (selectedAnimalContext.value.isEmpty) return 'Général';

    final animal = _animalController.animals
        .firstWhereOrNull((a) => a.id.toString() == selectedAnimalContext.value);

    return animal != null
        ? '${animal.type} (${animal.count})'
        : 'Animal sélectionné';
  }

  Future<void> clearHistory() async {
    try {
      await _dbHelper.clearChatHistory();
      messages.clear();
      Get.snackbar('Succès', 'Historique effacé');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'effacer l\'historique');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Suggestions de questions rapides
  List<String> get quickQuestions => [
        "Comment prévenir les maladies chez mes poules ?",
        "Quel est le bon moment pour vacciner ?",
        "Mon animal refuse de manger, que faire ?",
        "Comment améliorer la ponte de mes poules ?",
        "Quels sont les signes d'une maladie ?",
        "Comment calculer le coût de l'alimentation ?",
      ];

  void sendQuickQuestion(String question) {
    sendMessage(question);
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}