import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smart_breeder/data/models/chat_message_model.dart';
import 'package:smart_breeder/data/models/animal_model.dart';
import 'package:smart_breeder/data/services/database_helper.dart';
import 'package:smart_breeder/data/services/gemini_service.dart';
import 'package:smart_breeder/data/services/voice_service.dart';
import 'package:smart_breeder/controllers/animal_controller.dart';

class ChatController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GeminiService _geminiService = Get.find<GeminiService>();
  final VoiceService _voiceService = Get.find<VoiceService>();
  final AnimalController _animalController = Get.find<AnimalController>();

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool isListening = false.obs;
  final RxString selectedAnimalContext = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadChatHistory();
    
    // Écouter les changements du service vocal
    ever(_voiceService.isListening, (bool listening) {
      isListening.value = listening;
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

    // Ajouter le message de l'utilisateur
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

    // Générer la réponse IA
    await _generateAIResponse(text);
  }

  Future<void> _generateAIResponse(String userMessage) async {
    isTyping.value = true;

    try {
      // Obtenir le contexte de l'animal sélectionné
      AnimalModel? animalContext;
      if (selectedAnimalContext.value.isNotEmpty) {
        animalContext = _animalController.animals
            .firstWhereOrNull((animal) => animal.id.toString() == selectedAnimalContext.value);
      }

      // Générer la réponse avec Gemini
      final response = await _geminiService.generateVeterinaryAdvice(
        userMessage,
        animalContext: animalContext,
      );

      // Ajouter la réponse de l'IA
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

      // Lire la réponse à voix haute si l'utilisateur a utilisé la voix
      if (isListening.value || messages.length > 1 && messages[messages.length - 2].isVoiceMessage) {
        await _voiceService.speak(response);
      }

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
      final spokenText = await _voiceService.startListening();
      
      if (spokenText != null && spokenText.isNotEmpty) {
        await sendMessage(spokenText, isVoiceMessage: true);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'utiliser la reconnaissance vocale: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void stopVoiceInput() {
    _voiceService.stopListening();
  }

  void stopSpeaking() {
    _voiceService.stopSpeaking();
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