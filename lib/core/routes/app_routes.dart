import 'package:get/get.dart';
import 'package:smart_breeder/controllers/animal_controller.dart';
import 'package:smart_breeder/controllers/chat_controller.dart';
import 'package:smart_breeder/views/add_animal_view.dart';
import 'package:smart_breeder/views/analytics_view.dart';
import 'package:smart_breeder/views/animals_view.dart';
import 'package:smart_breeder/views/calendar_view.dart';
import 'package:smart_breeder/views/chat/chat_view.dart';
import 'package:smart_breeder/views/dashboard_view.dart';
import 'package:smart_breeder/views/generate_planning_view.dart';
import 'package:smart_breeder/views/splash_view.dart';
import 'package:smart_breeder/views/animal_detail_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String animalsList = '/animals-list';
  static const String addAnimal = '/add-animal';
  static const String animalDetail = '/animal-detail';
  static const String calendar = '/calendar';
  static const String chat = '/chat';
  static const String analytics = '/analytics';
  static const String generatePlanning = '/generate-planning';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnimalController>(() => AnimalController());
      }),
    ),
    GetPage(
      name: animalsList,
      page: () => AnimalsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnimalController>(() => AnimalController());
      }),
    ),
    GetPage(
      name: addAnimal,
      page: () => AddAnimalView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnimalController>(() => AnimalController());
      }),
    ),
    GetPage(
      name: animalDetail,
      page: () => AnimalDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnimalController>(() => AnimalController());
      }),
    ),
    GetPage(
      name: calendar,
      page: () => CalendarView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnimalController>(() => AnimalController());
      }),
    ),
    GetPage(
      name: chat,
      page: () => ChatView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatController>(() => ChatController());
        Get.lazyPut<AnimalController>(() => AnimalController());
      }),
    ),
    GetPage(
      name: analytics,
      page: () => AnalyticsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnimalController>(() => AnimalController());
      }),
    ),
    GetPage(
      name: generatePlanning,
      page: () => GeneratePlanningView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnimalController>(() => AnimalController());
      }),
    ),
  ];
}
