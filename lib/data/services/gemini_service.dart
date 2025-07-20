import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import 'package:smart_breeder/data/models/animal_model.dart';
import 'package:smart_breeder/data/models/vaccination_schedule_model.dart';

class GeminiService extends GetxService {
  static const String _apiKey =
      'YOUR_KEY_GEMINI'; // À remplacer par ta clé API
  late GenerativeModel _model;

  @override
  void onInit() {
    super.onInit();
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 1,
        topP: 1,
        maxOutputTokens: 2048,
      ),
    );
  }

  Future<String> generateVeterinaryAdvice(
    String question, {
    AnimalModel? animalContext,
  }) async {
    try {
      String contextPrompt = _buildContextPrompt(animalContext);

      String fullPrompt =
          '''
$contextPrompt

Question de l'éleveur: $question

En tant qu'assistant vétérinaire intelligent pour SmartBreeder, fournissez une réponse claire, précise et pratique en français. 
Incluez:
- Les actions immédiates à prendre
- Les signes à surveiller
- Les coûts approximatifs si applicables
- Quand consulter un vétérinaire

Réponse concise et pratique:
''';

      final response = await _model.generateContent([Content.text(fullPrompt)]);
      return response.text ??
          'Désolé, je n\'ai pas pu générer une réponse. Veuillez réessayer.';
    } catch (e) {
  print('Erreur Gemini: $e');
  return 'Erreur de connexion au service IA. Vérifiez votre connexion internet.';
}

  }

  Future<List<VaccinationScheduleModel>> generateVaccinationSchedule(
    AnimalModel animal,
  ) async {
    try {
      String prompt =
          '''
Générez un planning de vaccination complet pour cet animal:
- Type: ${animal.type} (${animal.subType})
- Nombre: ${animal.count}
- Âge: ${animal.ageInMonths} mois
- Catégorie: ${animal.category}
- Race: ${animal.breed ?? 'Non spécifiée'}
- Stade: ${animal.physiologicalStage}
- Localisation: ${animal.location}
- État sanitaire: ${animal.healthStatus}

Retournez un planning de vaccination avec les éléments suivants pour chaque vaccination (format JSON):
- vaccineName: nom du vaccin
- vaccineType: type (Vaccination/Vermifugation/Traitement)
- scheduledDate: date recommandée (format ISO)
- priority: priorité (high/medium/low)
- estimatedCost: coût estimé en FCFA
- veterinaryAdvice: conseils vétérinaires

Tenez compte des spécificités de l'élevage en Côte d'Ivoire.
''';

      final response = await _model.generateContent([Content.text(prompt)]);

      // Ici, tu devrais parser la réponse JSON de Gemini
      // Pour la démo, on retourne un planning exemple
      return _generateExampleSchedule(animal);
    } catch (e) {
      return _generateExampleSchedule(animal);
    }
  }

  Future<Map<String, dynamic>> analyzeCosts(
    List<AnimalModel> animals,
    List<VaccinationScheduleModel> schedules,
  ) async {
    double totalEstimatedCost = schedules.fold(
        0,
        (sum, schedule) => sum + (schedule.estimatedCost ?? 0),
      );
    try {
      String prompt =
          '''
Analysez les coûts pour cette exploitation:
- Nombre total d'animaux: ${animals.fold(0, (sum, animal) => sum + animal.count)}
- Types d'animaux: ${animals.map((a) => '${a.type} (${a.count})').join(', ')}
- Coût total des vaccinations prévues: ${totalEstimatedCost.toStringAsFixed(0)} FCFA

Fournissez:
1. Répartition des coûts par catégorie
2. Recommandations d'optimisation
3. Périodes de dépenses importantes
4. Budget mensuel recommandé

Format: analyse claire et recommandations pratiques.
''';

      final response = await _model.generateContent([Content.text(prompt)]);

      return {
        'totalCost': totalEstimatedCost,
        'analysis': response.text ?? 'Analyse non disponible',
        'monthlyBudget': (totalEstimatedCost / 12).round(),
        'recommendations': [
          'Grouper les achats pour obtenir des remises',
          'Privilégier les vaccinations préventives',
          'Négocier avec les fournisseurs locaux',
        ],
      };
    } catch (e) {
      return {
        'totalCost': totalEstimatedCost,
        'analysis': 'Erreur lors de l\'analyse des coûts',
        'monthlyBudget': (totalEstimatedCost / 12).round(),
        'recommendations': [
          'Grouper les achats pour obtenir des remises',
          'Privilégier les vaccinations préventives',
        ],
      };
    }
  }

  String _buildContextPrompt(AnimalModel? animal) {
    if (animal == null) {
      return 'Contexte: Question générale sur l\'élevage.';
    }

    return '''
Contexte de l'élevage:
- Animal: ${animal.type} (${animal.subType})
- Nombre: ${animal.count}
- Âge: ${animal.ageInMonths} mois
- Stade: ${animal.physiologicalStage}
- État de santé: ${animal.healthStatus}
- Logement: ${animal.housingType}
- Localisation: ${animal.location}
- Alimentation: ${animal.feedingType}
''';
  }

  List<VaccinationScheduleModel> _generateExampleSchedule(AnimalModel animal) {
    List<VaccinationScheduleModel> schedules = [];
    DateTime now = DateTime.now();

    if (animal.type.toLowerCase().contains('volaille') ||
        animal.subType.toLowerCase().contains('poulet')) {
      // Planning pour poulets
      schedules.addAll([
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Newcastle + Bronchite',
          vaccineType: 'Vaccination',
          scheduledDate: now.add(Duration(days: 7)),
          status: 'pending',
          priority: 'high',
          estimatedCost: (500 * animal.count).toDouble(),
          veterinaryAdvice:
              'Vaccination essentielle contre les maladies virales',
          createdAt: now,
          updatedAt: now,
        ),
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Gumboro',
          vaccineType: 'Vaccination',
          scheduledDate: now.add(Duration(days: 14)),
          status: 'pending',
          priority: 'high',
          estimatedCost: (300 * animal.count).toDouble(),
          veterinaryAdvice: 'Protection contre la maladie de Gumboro',
          createdAt: now,
          updatedAt: now,
        ),
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Vermifugation',
          vaccineType: 'Vermifugation',
          scheduledDate: now.add(Duration(days: 21)),
          status: 'pending',
          priority: 'medium',
          estimatedCost: (200 * animal.count).toDouble(),
          veterinaryAdvice: 'Traitement antiparasitaire préventif',
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    } else if (animal.type.toLowerCase().contains('bovin')) {
      // Planning pour bovins
      schedules.addAll([
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Fièvre aphteuse',
          vaccineType: 'Vaccination',
          scheduledDate: now.add(Duration(days: 10)),
          status: 'pending',
          priority: 'high',
          estimatedCost: (2000 * animal.count).toDouble(),
          veterinaryAdvice: 'Vaccination obligatoire contre la fièvre aphteuse',
          createdAt: now,
          updatedAt: now,
        ),
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Charbon symptomatique',
          vaccineType: 'Vaccination',
          scheduledDate: now.add(Duration(days: 30)),
          status: 'pending',
          priority: 'high',
          estimatedCost: (1500 * animal.count).toDouble(),
          veterinaryAdvice: 'Protection contre le charbon symptomatique',
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    }

    return schedules;
  }

  Future<String> getHealthRecommendations(List<AnimalModel> animals) async {
    try {
      String animalsContext = animals
          .map(
            (animal) =>
                '${animal.type} (${animal.count} têtes, ${animal.ageInMonths} mois, état: ${animal.healthStatus})',
          )
          .join(', ');

      String prompt =
          '''
Analysez l'état général de ce cheptel et fournissez des recommandations:

Animaux: $animalsContext

Fournissez:
1. État général du cheptel
2. Risques identifiés
3. Actions prioritaires à prendre
4. Recommandations de suivi

Réponse structurée et pratique pour un éleveur en Côte d'Ivoire.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Recommandations non disponibles actuellement.';
    } catch (e) {
      return 'Erreur lors de la génération des recommandations de santé.';
    }
  }
}
