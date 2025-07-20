import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import 'package:smart_breeder/data/models/animal_model.dart';
import 'package:smart_breeder/data/models/vaccination_schedule_model.dart';

class GeminiService extends GetxService {
  static const String _apiKey =
      'YOUR_KEY_GEMINI'; // À remplacer par ta clé API
  late GenerativeModel _model;

  // Prompt système par défaut pour SmartBreeder
  static const String _defaultSystemPrompt = '''
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

Contexte géographique: Côte d'Ivoire (climat tropical, saisons sèches et pluvieuses).
''';

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
      systemInstruction: Content.text(_defaultSystemPrompt),
    );
  }

  Future<String> generateVeterinaryAdvice(
    String question, {
    AnimalModel? animalContext,
    String? customSystemPrompt,
  }) async {
    try {
      String contextPrompt = _buildContextPrompt(animalContext);
      
      // Si un prompt système personnalisé est fourni, créer un nouveau modèle temporairement
      GenerativeModel modelToUse = _model;
      if (customSystemPrompt != null) {
        modelToUse = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: _apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 1,
            topP: 1,
            maxOutputTokens: 2048,
          ),
          systemInstruction: Content.text(customSystemPrompt),
        );
      }

      String fullPrompt = '''
$contextPrompt

Question de l'éleveur: $question

Répondez en markdown pour la mise en forme (titres, listes, gras, etc.).
''';

      final response = await modelToUse.generateContent([Content.text(fullPrompt)]);
      return response.text ??
          'Désolé, je n\'ai pas pu générer une réponse. Veuillez réessayer.';
    } catch (e) {
      print('Erreur Gemini: $e');
      return _getErrorResponse(e);
    }
  }

  String _getErrorResponse(dynamic error) {
    String errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return '''
## ⚠️ Problème de connexion

Je ne peux pas me connecter au service d'IA pour le moment.

**Solutions possibles :**
- Vérifiez votre connexion internet
- Réessayez dans quelques minutes
- Utilisez la reconnaissance vocale si le texte ne fonctionne pas

En attendant, n'hésitez pas à consulter directement un vétérinaire pour les urgences.
''';
    } else if (errorString.contains('quota') || errorString.contains('limit')) {
      return '''
## ⚠️ Limite d'utilisation atteinte

Le service d'IA a atteint sa limite d'utilisation temporaire.

**Solutions :**
- Réessayez dans une heure
- Contactez le support de l'application
- Pour les urgences, consultez directement un vétérinaire
''';
    } else if (errorString.contains('api') || errorString.contains('key')) {
      return '''
## ⚠️ Problème de service

Un problème technique empêche le bon fonctionnement de l'assistant.

**Action recommandée :**
- Contactez le support technique de SmartBreeder
- Pour les urgences vétérinaires, consultez directement un professionnel
''';
    }
    
    return '''
## ⚠️ Erreur temporaire

Je rencontre une difficulté technique temporaire.

**Que faire :**
1. Réessayez votre question
2. Vérifiez votre connexion internet
3. Pour les urgences, consultez un vétérinaire

**Support :** Contactez l'équipe SmartBreeder si le problème persiste.
''';
  }

  Future<List<VaccinationScheduleModel>> generateVaccinationSchedule(
    AnimalModel animal,
  ) async {
    try {
      String prompt = '''
Contexte animal:
${_buildContextPrompt(animal)}

Générez un planning de vaccination complet adapté aux conditions de la Côte d'Ivoire.

Considérez:
- Les maladies courantes dans la région
- Le climat tropical (saisons sèches et pluvieuses)
- Les prix locaux des vaccins
- L'âge et le stade physiologique de l'animal

Retournez les informations de vaccination nécessaires avec:
- Nom du vaccin
- Type (Vaccination/Vermifugation/Traitement préventif)
- Urgence (haute/moyenne/faible)
- Période recommandée
- Coût estimé en FCFA
- Conseils spécifiques

Format: liste structurée et claire.
''';

      final response = await _model.generateContent([Content.text(prompt)]);

      // Pour l'instant, on utilise le planning d'exemple
      // Dans une vraie implémentation, on parserait la réponse de Gemini
      return _generateExampleSchedule(animal);
    } catch (e) {
      print('Erreur génération planning: $e');
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
      int totalAnimals = animals.fold(0, (sum, animal) => sum + animal.count);
      String animalBreakdown = animals
          .map((a) => '${a.type} (${a.count} têtes)')
          .join(', ');

      String prompt = '''
Analysez les coûts de cette exploitation en Côte d'Ivoire:

**Cheptel:**
- Total: $totalAnimals animaux
- Répartition: $animalBreakdown
- Coût vaccinations prévues: ${totalEstimatedCost.toStringAsFixed(0)} FCFA

**Demande d'analyse:**
1. Répartition détaillée des coûts
2. Optimisations possibles (achats groupés, négociations)
3. Budget mensuel recommandé
4. Périodes de dépenses importantes
5. Solutions de financement adaptées aux éleveurs ivoiriens

Tenez compte du contexte économique local et des pratiques d'élevage en Côte d'Ivoire.
''';

      final response = await _model.generateContent([Content.text(prompt)]);

      return {
        'totalCost': totalEstimatedCost,
        'totalAnimals': totalAnimals,
        'analysis': response.text ?? 'Analyse détaillée non disponible',
        'monthlyBudget': (totalEstimatedCost / 12).round(),
        'costPerAnimal': totalAnimals > 0 ? (totalEstimatedCost / totalAnimals).round() : 0,
        'recommendations': _getDefaultCostRecommendations(),
        'nextExpenses': _getUpcomingExpenses(schedules),
      };
    } catch (e) {
      print('Erreur analyse coûts: $e');
      return {
        'totalCost': totalEstimatedCost,
        'totalAnimals': animals.fold(0, (sum, animal) => sum + animal.count),
        'analysis': _getDefaultCostAnalysis(totalEstimatedCost),
        'monthlyBudget': (totalEstimatedCost / 12).round(),
        'costPerAnimal': 0,
        'recommendations': _getDefaultCostRecommendations(),
        'nextExpenses': _getUpcomingExpenses(schedules),
      };
    }
  }

  String _buildContextPrompt(AnimalModel? animal) {
    if (animal == null) {
      return 'Contexte: Question générale sur l\'élevage.';
    }

    return '''
**Contexte de l'élevage:**
- Animal: ${animal.type} (${animal.subType ?? 'Non spécifié'})
- Effectif: ${animal.count} têtes
- Âge: ${animal.ageInMonths} mois
- Stade physiologique: ${animal.physiologicalStage}
- État de santé: ${animal.healthStatus}
- Type de logement: ${animal.housingType}
- Localisation: ${animal.location}
- Alimentation: ${animal.feedingType}
- Race: ${animal.breed ?? 'Non spécifiée'}
''';
  }

  List<VaccinationScheduleModel> _generateExampleSchedule(AnimalModel animal) {
    List<VaccinationScheduleModel> schedules = [];
    DateTime now = DateTime.now();

    String animalType = animal.type.toLowerCase();
    String subType = animal.subType?.toLowerCase() ?? '';

    if (animalType.contains('volaille') || 
        subType.contains('poulet') || 
        subType.contains('poule')) {
      // Planning pour volailles
      schedules.addAll([
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Newcastle + Bronchite Infectieuse',
          vaccineType: 'Vaccination',
          scheduledDate: _getNextVaccinationDate(now, 7),
          status: 'pending',
          priority: 'high',
          estimatedCost: (600 * animal.count).toDouble(),
          veterinaryAdvice: 'Vaccination essentielle - Protège contre 2 maladies virales graves. À répéter tous les 3 mois.',
          createdAt: now,
          updatedAt: now,
        ),
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Gumboro (Bursite)',
          vaccineType: 'Vaccination',
          scheduledDate: _getNextVaccinationDate(now, 14),
          status: 'pending',
          priority: 'high',
          estimatedCost: (400 * animal.count).toDouble(),
          veterinaryAdvice: 'Indispensable pour les poussins. Protège le système immunitaire.',
          createdAt: now,
          updatedAt: now,
        ),
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Vermifugation (Ivermectine)',
          vaccineType: 'Vermifugation',
          scheduledDate: _getNextVaccinationDate(now, 21),
          status: 'pending',
          priority: 'medium',
          estimatedCost: (250 * animal.count).toDouble(),
          veterinaryAdvice: 'Traitement antiparasitaire - À répéter tous les 2 mois en saison pluvieuse.',
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    } else if (animalType.contains('bovin') || animalType.contains('bœuf') || animalType.contains('vache')) {
      // Planning pour bovins
      schedules.addAll([
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Fièvre Aphteuse',
          vaccineType: 'Vaccination',
          scheduledDate: _getNextVaccinationDate(now, 15),
          status: 'pending',
          priority: 'high',
          estimatedCost: (2500 * animal.count).toDouble(),
          veterinaryAdvice: 'Vaccination obligatoire en Côte d\'Ivoire. Répéter tous les 6 mois.',
          createdAt: now,
          updatedAt: now,
        ),
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Charbon Symptomatique',
          vaccineType: 'Vaccination',
          scheduledDate: _getNextVaccinationDate(now, 30),
          status: 'pending',
          priority: 'high',
          estimatedCost: (2000 * animal.count).toDouble(),
          veterinaryAdvice: 'Essentiel pour les jeunes bovins. Protection valable 1 an.',
          createdAt: now,
          updatedAt: now,
        ),
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Déparasitage (Albendazole)',
          vaccineType: 'Vermifugation',
          scheduledDate: _getNextVaccinationDate(now, 45),
          status: 'pending',
          priority: 'medium',
          estimatedCost: (800 * animal.count).toDouble(),
          veterinaryAdvice: 'Traitement contre les vers. Plus fréquent en saison des pluies.',
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    } else if (animalType.contains('porc') || animalType.contains('cochon')) {
      // Planning pour porcins
      schedules.addAll([
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Peste Porcine Classique',
          vaccineType: 'Vaccination',
          scheduledDate: _getNextVaccinationDate(now, 10),
          status: 'pending',
          priority: 'high',
          estimatedCost: (1500 * animal.count).toDouble(),
          veterinaryAdvice: 'Vaccination vitale - Maladie mortelle et contagieuse.',
          createdAt: now,
          updatedAt: now,
        ),
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Rouget + Pasteurellose',
          vaccineType: 'Vaccination',
          scheduledDate: _getNextVaccinationDate(now, 25),
          status: 'pending',
          priority: 'medium',
          estimatedCost: (1200 * animal.count).toDouble(),
          veterinaryAdvice: 'Protection contre infections bactériennes courantes.',
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    } else if (animalType.contains('chèvre') || animalType.contains('mouton')) {
      // Planning pour petits ruminants
      schedules.addAll([
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Peste des Petits Ruminants (PPR)',
          vaccineType: 'Vaccination',
          scheduledDate: _getNextVaccinationDate(now, 12),
          status: 'pending',
          priority: 'high',
          estimatedCost: (800 * animal.count).toDouble(),
          veterinaryAdvice: 'Vaccination gratuite dans les campagnes nationales. Très importante.',
          createdAt: now,
          updatedAt: now,
        ),
        VaccinationScheduleModel(
          animalId: animal.id ?? 0,
          vaccineName: 'Pasteurellose',
          vaccineType: 'Vaccination',
          scheduledDate: _getNextVaccinationDate(now, 28),
          status: 'pending',
          priority: 'medium',
          estimatedCost: (600 * animal.count).toDouble(),
          veterinaryAdvice: 'Important pendant la saison des pluies.',
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    }

    return schedules;
  }

  DateTime _getNextVaccinationDate(DateTime baseDate, int daysFromNow) {
    return baseDate.add(Duration(days: daysFromNow));
  }

  List<String> _getDefaultCostRecommendations() {
    return [
      'Grouper les achats de vaccins pour obtenir des remises (10-15%)',
      'Négocier avec les vétérinaires pour les interventions multiples',
      'Profiter des campagnes nationales de vaccination gratuites',
      'Créer une coopérative d\'éleveurs pour réduire les coûts',
      'Privilégier la prévention pour éviter les traitements coûteux',
      'Planifier un budget mensuel pour éviter les dépenses imprévisibles',
    ];
  }

  String _getDefaultCostAnalysis(double totalCost) {
    return '''
## 💰 Analyse des Coûts

**Budget total estimé:** ${totalCost.toStringAsFixed(0)} FCFA

**Répartition recommandée:**
- Vaccinations essentielles: 60%
- Vermifugations: 25% 
- Traitements préventifs: 15%

**Optimisations possibles:**
- Achats groupés: économie de 10-15%
- Campagnes nationales: vaccinations gratuites
- Négociation avec vétérinaires locaux

**Financement:**
- Étalement sur 6-12 mois possible
- Microcrédits agricoles disponibles
- Subventions gouvernementales à explorer
''';
  }

  List<Map<String, dynamic>> _getUpcomingExpenses(List<VaccinationScheduleModel> schedules) {
    DateTime now = DateTime.now();
    DateTime nextMonth = DateTime(now.year, now.month + 1);
    
    return schedules
        .where((schedule) => 
            schedule.scheduledDate.isBefore(nextMonth) &&
            schedule.status == 'pending')
        .map((schedule) => {
          'name': schedule.vaccineName,
          'date': schedule.scheduledDate,
          'cost': schedule.estimatedCost ?? 0,
          'priority': schedule.priority,
        })
        .toList();
  }

  Future<String> getHealthRecommendations(List<AnimalModel> animals) async {
    try {
      String animalsContext = animals
          .map((animal) =>
              '${animal.type} (${animal.count} têtes, ${animal.ageInMonths} mois, état: ${animal.healthStatus})')
          .join(', ');

      String prompt = '''
**Analyse du cheptel en Côte d'Ivoire:**

Animaux: $animalsContext

Fournissez une analyse complète avec:

1. **État général** - Évaluation globale de la santé du cheptel
2. **Risques identifiés** - Menaces liées au climat tropical et aux conditions locales
3. **Actions prioritaires** - Ce qu'il faut faire immédiatement
4. **Surveillance recommandée** - Signes à surveiller quotidiennement
5. **Mesures préventives** - Hygiène, alimentation, logement
6. **Planning sanitaire** - Prochaines étapes importantes

Tenez compte du climat tropical ivoirien (saisons sèches et pluvieuses) et des maladies courantes dans la région.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _getDefaultHealthRecommendations(animals);
    } catch (e) {
      print('Erreur recommandations santé: $e');
      return _getDefaultHealthRecommendations(animals);
    }
  }

  String _getDefaultHealthRecommendations(List<AnimalModel> animals) {
    int totalAnimals = animals.fold(0, (sum, animal) => sum + animal.count);
    
    return '''
## 🏥 Recommandations Sanitaires

**Votre cheptel:** $totalAnimals animaux

### 🎯 Actions Prioritaires
1. **Vaccinations à jour** - Vérifier le calendrier vaccinal
2. **Déparasitage régulier** - Crucial en saison des pluies  
3. **Contrôle de l'alimentation** - Eau propre et aliments sains
4. **Hygiène des installations** - Nettoyer et désinfecter régulièrement

### ⚠️ Surveillance Quotidienne
- Appétit et comportement des animaux
- Température corporelle anormale
- Écoulements nasaux ou oculaires
- Boiteries ou difficultés de mouvement
- Diarrhées ou constipation

### 🌿 Mesures Préventives
- Isolation des nouveaux animaux (quarantaine 14 jours)
- Limitation des visiteurs dans l'élevage
- Désinfection des équipements
- Vaccination préventive selon calendrier

### 📅 Planning Recommandé
- Visite vétérinaire: tous les 3 mois
- Vermifugation: tous les 2 mois (saison pluies)
- Nettoyage approfondi: chaque semaine
- Contrôle sanitaire: quotidien

**Urgence vétérinaire:** Contactez immédiatement un vétérinaire si vous observez des symptômes inhabituels.
''';
  }
}