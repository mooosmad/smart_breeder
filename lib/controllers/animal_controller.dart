import 'package:get/get.dart';
import 'package:smart_breeder/data/models/animal_model.dart';
import 'package:smart_breeder/data/models/vaccination_schedule_model.dart';
import 'package:smart_breeder/data/services/database_helper.dart';
import 'package:smart_breeder/data/services/gemini_service.dart';

class AnimalController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GeminiService _geminiService = Get.find<GeminiService>();

  final RxList<AnimalModel> animals = <AnimalModel>[].obs;
  final RxList<VaccinationScheduleModel> upcomingVaccinations = <VaccinationScheduleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnimals();
    loadUpcomingVaccinations();
  }

  Future<void> loadAnimals() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      animals.value = await _dbHelper.getAllAnimals();
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des animaux: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAnimal(AnimalModel animal) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _dbHelper.insertAnimal(animal);
      
      // Générer automatiquement le planning de vaccination
      await generateVaccinationSchedule(animal);
      
      await loadAnimals();
      await loadUpcomingVaccinations();
      
      Get.snackbar(
        'Succès', 
        'Animal ajouté avec succès et planning généré',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de l\'ajout: $e';
      Get.snackbar('Erreur', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAnimal(AnimalModel animal) async {
    try {
      isLoading.value = true;
      await _dbHelper.updateAnimal(animal);
      await loadAnimals();
      Get.snackbar('Succès', 'Animal modifié avec succès');
    } catch (e) {
      errorMessage.value = 'Erreur lors de la modification: $e';
      Get.snackbar('Erreur', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAnimal(int animalId) async {
    try {
      isLoading.value = true;
      await _dbHelper.deleteAnimal(animalId);
      await loadAnimals();
      await loadUpcomingVaccinations();
      Get.snackbar('Succès', 'Animal supprimé avec succès');
    } catch (e) {
      errorMessage.value = 'Erreur lors de la suppression: $e';
      Get.snackbar('Erreur', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateVaccinationSchedule(AnimalModel animal) async {
    try {
      final schedules = await _geminiService.generateVaccinationSchedule(animal);
      
      for (var schedule in schedules) {
        await _dbHelper.insertVaccinationSchedule(schedule);
      }
    } catch (e) {
      print('Erreur génération planning: $e');
    }
  }

  Future<void> loadUpcomingVaccinations() async {
    try {
      upcomingVaccinations.value = await _dbHelper.getUpcomingVaccinations();
    } catch (e) {
      print('Erreur chargement vaccinations: $e');
    }
  }

  Future<List<VaccinationScheduleModel>> getVaccinationsForAnimal(int animalId) async {
    try {
      return await _dbHelper.getVaccinationSchedules(animalId: animalId);
    } catch (e) {
      print('Erreur chargement vaccinations animal: $e');
      return [];
    }
  }

  Future<void> markVaccinationAsCompleted(VaccinationScheduleModel vaccination, double actualCost) async {
    try {
      final updatedVaccination = vaccination.copyWith(
        status: 'completed',
        completedDate: DateTime.now(),
        actualCost: actualCost,
      );
      
      await _dbHelper.updateVaccinationSchedule(updatedVaccination);
      await loadUpcomingVaccinations();
      
      Get.snackbar('Succès', 'Vaccination marquée comme effectuée');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour: $e');
    }
  }

  // Statistiques
  int get totalAnimals => animals.fold(0, (sum, animal) => sum + animal.count);
  
  int get healthyAnimals => animals
      .where((animal) => animal.healthStatus.toLowerCase().contains('bonne'))
      .fold(0, (sum, animal) => sum + animal.count);
  
  int get overdueVaccinations => upcomingVaccinations
      .where((vaccination) => vaccination.isOverdue)
      .length;
  
  int get dueTodayVaccinations => upcomingVaccinations
      .where((vaccination) => vaccination.isDueToday)
      .length;

  double get totalEstimatedCosts => upcomingVaccinations
      .fold(0.0, (sum, vaccination) => sum + (vaccination.estimatedCost ?? 0));

  Map<String, int> get animalsByType {
    Map<String, int> result = {};
    for (var animal in animals) {
      result[animal.type] = (result[animal.type] ?? 0) + animal.count;
    }
    return result;
  }

  List<VaccinationScheduleModel> get criticalVaccinations => upcomingVaccinations
      .where((vaccination) => vaccination.priority == 'high' && 
      (vaccination.isOverdue || vaccination.isDueToday))
      .toList();
}