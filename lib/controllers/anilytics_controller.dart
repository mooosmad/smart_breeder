import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:smart_breeder/controllers/animal_controller.dart';

class AnalyticsController extends GetxController {
  final AnimalController animalController = Get.find();

  RxInt totalAnimals = 0.obs;
  RxDouble totalCost = 0.0.obs;
  RxInt scheduledVaccinations = 0.obs;
  RxInt healthAlerts = 0.obs;
  RxList<FlSpot> costData = <FlSpot>[].obs;
  RxMap<String, int> animalDistribution = <String, int>{}.obs;
  RxList<Map<String, dynamic>> upcomingTasks = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _computeStats();
  }

  void _computeStats() {
    final animals = animalController.animals;
    final vaccinations = animalController.upcomingVaccinations;

    totalAnimals.value = animals.fold(0, (sum, a) => sum + a.count);
    totalCost.value = vaccinations.fold(0.0, (sum, v) => sum + (v.estimatedCost ?? 0));
    scheduledVaccinations.value = vaccinations.length;
    healthAlerts.value = vaccinations.where((v) => v.isOverdue).length;

    // Exemple de données pour le graphique (à adapter)
    costData.value = List.generate(6, (i) => FlSpot(i.toDouble(), (i * 10000).toDouble()));

    // Répartition par type
    Map<String, int> dist = {};
    for (var a in animals) {
      dist[a.type] = (dist[a.type] ?? 0) + a.count;
    }
    animalDistribution.value = dist;

    // Prochaines tâches (exemple)
    upcomingTasks.value = vaccinations.take(5).map((v) => {
      'title': v.vaccineName,
      'description': v.veterinaryAdvice ?? '',
      'dueDate': v.scheduledDate.toString().substring(0, 10),
      'priority': v.priority,
      'type': v.vaccineType,
    }).toList();
  }
}
