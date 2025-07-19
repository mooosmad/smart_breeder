import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_breeder/controllers/animal_controller.dart';
import 'package:smart_breeder/data/models/vaccination_schedule_model.dart';

class CalendarView extends StatelessWidget {
  final AnimalController controller = Get.find();

  CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier Sanitaire'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.upcomingVaccinations.isEmpty) {
          return const Center(child: Text('Aucune vaccination à venir.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.upcomingVaccinations.length,
          itemBuilder: (context, index) {
            final VaccinationScheduleModel vax = controller.upcomingVaccinations[index];
            return _buildCalendarEvent(
              vax.vaccineName,
              _getDelayText(vax.scheduledDate),
              vax.veterinaryAdvice ?? '',
              _getPriorityColor(vax.priority),
              () => _markAsDone(vax, controller),
              () => _postponeTask(vax, controller),
            );
          },
        );
      }),
    );
  }

  Widget _buildCalendarEvent(
    String title,
    String delay,
    String description,
    Color color,
    VoidCallback onDone,
    VoidCallback onPostpone,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  delay,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Marquer fait'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: onPostpone,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text('Reporter', style: TextStyle(color: color)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDelayText(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff < 0) return 'En retard';
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Demain';
    return 'Dans $diff jours';
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'haute':
        return Colors.red;
      case 'medium':
      case 'moyenne':
        return Colors.orange;
      case 'low':
      case 'basse':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _markAsDone(VaccinationScheduleModel vax, AnimalController controller) {
    // Ici tu peux demander le coût réel si besoin
    controller.markVaccinationAsCompleted(vax, vax.estimatedCost ?? 0);
  }

  void _postponeTask(VaccinationScheduleModel vax, AnimalController controller) {
    // Ici tu peux ouvrir un dialog pour choisir une nouvelle date
    Get.snackbar('À faire', 'Fonction de report à implémenter');
  }
}
