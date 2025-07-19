// lib/views/animal_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_breeder/controllers/animal_controller.dart';
import 'package:smart_breeder/data/models/animal_model.dart';

class AnimalDetailView extends StatelessWidget {
  final AnimalController controller = Get.find();

  AnimalDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final String animalId = Get.parameters['id'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Détails Animal'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, animalId),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, animalId),
          ),
        ],
      ),
      body: Obx(() {
        final animal = controller.animals.firstWhereOrNull(
          (a) => a.id?.toString() == animalId,
        );

        if (animal == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  'Animal non trouvé',
                  style: TextStyle(fontSize: 24, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          _getAnimalIcon(animal.type),
                          size: 40,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        animal.type,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${animal.breed ?? ""} • ${animal.count} animaux',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Informations principales
              _buildInfoSection('Informations Générales', [
                _buildInfoTile('Âge', '${animal.ageInMonths} mois', Icons.calendar_today),
                _buildInfoTile('Catégorie', animal.category, Icons.category),
                _buildInfoTile('Poids moyen', '${animal.averageWeight ?? "-"} kg', Icons.scale),
                _buildInfoTile('État de santé', animal.healthStatus, Icons.favorite),
              ]),

              const SizedBox(height: 20),

              // Informations production
              _buildInfoSection('Production & Objectifs', [
                _buildInfoTile('Stade physiologique', animal.physiologicalStage, Icons.timeline),
                _buildInfoTile('Objectif', animal.productionObjective, Icons.flag),
                _buildInfoTile('Origine', animal.origin ?? '-', Icons.location_on),
              ]),

              const SizedBox(height: 20),

              // Actions rapides
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actions Rapides',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _scheduleVaccination(animal),
                              icon: const Icon(Icons.medical_services),
                              label: const Text('Vacciner'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _addHealthRecord(animal),
                              icon: const Icon(Icons.note_add),
                              label: const Text('Suivi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAnimalIcon(String type) {
    switch (type.toLowerCase()) {
      case 'poulets':
      case 'volailles':
        return Icons.egg;
      case 'bovins':
        return Icons.pets;
      case 'ovins':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  void _showEditDialog(BuildContext context, String animalId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Modifier l\'animal'),
        content: const Text('Fonctionnalité de modification à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Info', 'Modification sauvegardée');
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String animalId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer l\'animal'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet animal ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await controller.deleteAnimal(int.parse(animalId));
              Get.back(); // Ferme le dialog
              Get.back(); // Retour à la liste
              Get.snackbar('Succès', 'Animal supprimé');
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _scheduleVaccination(AnimalModel animal) {
    Get.snackbar(
      'Vaccination',
      'Planification de vaccination pour ${animal.type}',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _addHealthRecord(AnimalModel animal) {
    Get.snackbar(
      'Suivi Santé',
      'Nouveau suivi ajouté pour ${animal.type}',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
}
