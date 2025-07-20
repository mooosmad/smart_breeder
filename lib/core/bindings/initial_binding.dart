// lib/core/bindings/initial_binding.dart
import 'package:get/get.dart';
import 'package:smart_breeder/controllers/anilytics_controller.dart';
import 'package:smart_breeder/data/services/database_helper.dart';
import 'package:smart_breeder/data/services/gemini_service.dart';
import 'package:smart_breeder/data/services/gemini_strict_planning_service.dart';
import 'package:smart_breeder/data/services/voice_service.dart';
import 'package:smart_breeder/controllers/animal_controller.dart';
import 'package:smart_breeder/controllers/chat_controller.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services singletons (permanents)
    Get.put<DatabaseHelper>(DatabaseHelper(), permanent: true);
    Get.put<GeminiService>(GeminiService(), permanent: true);
    Get.put<GeminiStrictPlanningService>(GeminiStrictPlanningService(), permanent: true);
    Get.put<VoiceService>(VoiceService(), permanent: true);

    // Contrôleurs globaux (fenix = recréé si supprimé de la mémoire)
    Get.lazyPut<AnimalController>(() => AnimalController(), fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
    Get.lazyPut<AnalyticsController>(() => AnalyticsController(), fenix: true);
  }
}
