import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_breeder/controllers/animal_controller.dart';
import 'package:smart_breeder/data/models/animal_model.dart';

class AddAnimalView extends StatelessWidget {
  final AnimalController controller = Get.find();

  // Contrôleurs de champ
  final TextEditingController typeCtrl = TextEditingController();
  final TextEditingController countCtrl = TextEditingController();
  final TextEditingController breedCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController healthCtrl = TextEditingController();
  final TextEditingController originCtrl = TextEditingController();

  AddAnimalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Animal'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Type d\'animal', typeCtrl),
            const SizedBox(height: 16),
            _buildTextField('Nombre d\'animaux', countCtrl, isNumber: true),
            const SizedBox(height: 16),
            _buildTextField('Race/Souche', breedCtrl),
            const SizedBox(height: 16),
            _buildTextField('Âge (en mois)', ageCtrl, isNumber: true),
            const SizedBox(height: 16),
            _buildTextField('État sanitaire', healthCtrl),
            const SizedBox(height: 16),
            _buildTextField('Origine', originCtrl),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Validation simple
                  if (typeCtrl.text.isEmpty || countCtrl.text.isEmpty) {
                    Get.snackbar('Erreur', 'Veuillez remplir tous les champs obligatoires');
                    return;
                  }
                  final animal = AnimalModel(
                    type: typeCtrl.text,
                    subType: '', // à compléter selon ton modèle
                    count: int.tryParse(countCtrl.text) ?? 0,
                    ageInMonths: int.tryParse(ageCtrl.text) ?? 0,
                    category: '', // à compléter
                    breed: breedCtrl.text,
                    physiologicalStage: '', // à compléter
                    averageWeight: null,
                    productionObjective: '',
                    healthStatus: healthCtrl.text,
                    location: '',
                    temperature: null,
                    housingType: '',
                    soilType: '',
                    availableResources: [],
                    workforce: 0,
                    feedingType: '',
                    feedingFrequency: 0,
                    performanceHistory: null,
                    timeAvailability: '',
                    specificConstraints: [],
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    arrivalStatus: null,
                    origin: originCtrl.text,
                    buildingArea: null,
                    budget: null,
                  );
                  await controller.addAnimal(animal);
                  Get.back();
                  Get.snackbar('Succès', 'Animal ajouté avec succès', backgroundColor: Colors.green, colorText: Colors.white);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ajouter l\'animal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[700]!),
            ),
          ),
        ),
      ],
    );
  }
}
