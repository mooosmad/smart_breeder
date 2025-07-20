// lib/services/gemini_strict_planning_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiStrictPlanningService extends GetxService {
  // Remplacez par votre vraie clé API Gemini
  static const String _apiKey = 'YOUR_KEY_GEMINI';
  late GenerativeModel _model;

  // Configuration des références par type d'animal
  static const Map<String, dynamic> REFERENCE_CONFIG = {
    'bovins': {
      'url': 'https://agritrop.cirad.fr/605485/1/605485.pdf',
      'keyPages': {
        'protocols': [12, 15],
        'intervals': [18, 20],
        'exceptions': 22,
      },
      'description': 'Bovins - Protocoles de vaccination et vermifugation'
    },
    'ovins': {
      'url': 'https://www.fao.org/3/x6546f/x6546f.pdf',
      'keyPages': {
        'protocols': [10, 13],
        'intervals': [14, 16],
        'exceptions': 18,
      },
      'description': 'Ovins - Guide FAO des pratiques d\'élevage'
    },
    'caprins': {
      'url': 'https://www.fao.org/3/x6546f/x6546f.pdf',
      'keyPages': {
        'protocols': [20, 23],
        'intervals': [24, 26],
        'exceptions': 28,
      },
      'description': 'Caprins - Protocoles sanitaires spécialisés'
    },
    'porcins': {
      'url': 'https://www.fao.org/3/x6546f/x6546f.pdf',
      'keyPages': {
        'protocols': [30, 33],
        'intervals': [34, 36],
        'exceptions': 38,
      },
      'description': 'Porcins - Guide de santé animale'
    },
    'volailles': {
      'url': 'https://www.fao.org/3/x6546f/x6546f.pdf',
      'keyPages': {
        'protocols': [40, 43],
        'intervals': [44, 46],
        'exceptions': 48,
      },
      'description': 'Volailles - Protocoles avicoles'
    },
  };

  @override
  void onInit() {
    super.onInit();
    _initializeModel();
  }

  void _initializeModel() {
    try {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1, // Très faible pour plus de cohérence
          topK: 1,
          topP: 0.8,
          maxOutputTokens: 4096,
        ),
      );
      print('✅ Modèle Gemini initialisé avec succès');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation du modèle: $e');
      rethrow;
    }
  }

  // Génération du prompt système
  String _buildSystemPrompt(String animalType) {
    final ref = REFERENCE_CONFIG[animalType];
    if (ref == null) {
      throw ArgumentError("Type d'animal non supporté: $animalType");
    }

    return '''Tu es un expert vétérinaire spécialisé en élevage africain.

MISSION STRICTE :
1. Consulter OBLIGATOIREMENT le document de référence : ${ref['url']}
2. Respecter EXACTEMENT le schéma JSON fourni
3. Adapter au contexte africain (climat, ressources, contraintes locales)

RÉFÉRENCES TECHNIQUES :
- Protocoles: pages ${(ref['keyPages']['protocols'] as List).join('-')}
- Intervalles: pages ${(ref['keyPages']['intervals'] as List).join('-')}
- Exceptions: page ${ref['keyPages']['exceptions']}

SCHÉMA JSON OBLIGATOIRE :
{
  "nom": "string (nom élevage)",
  "type": "enum: bovins|ovins|caprins|porcins|volailles",
  "user_id": "string (ID MongoDB)",
  "conditions_initiales": {
    "date_arrivee": "YYYY-MM-DD",
    "effectif": "number",
    "statut_sanitaire": {
      "valeur": "enum: excellent|bon|moyen|mauvais",
      "details": "string optionnel"
    }
  },
  "planning": {
    "periode": {
      "debut": "YYYY-MM-DD",
      "fin": "YYYY-MM-DD"
    },
    "protocoles": [
      {
        "nom": "string",
        "type": "enum: vaccin|vermifuge|alimentation|bilan",
        "contraintes": ["array de strings"],
        "frequence_jours": "number",
        "prochain_evenement": "YYYY-MM-DD optionnel"
      }
    ],
    "evenements": [
      {
        "nom": "string",
        "type": "enum: vaccin|vermifuge|alimentation|bilan",
        "date_prevue": "YYYY-MM-DD",
        "statut": "enum: a_faire|en_cours|termine|annule"
      }
    ]
  }
}

VALIDATION REQUISE :
- ✓ Chaque protocole doit référencer une page du document
- ✓ Les intervalles doivent respecter les recommandations vétérinaires
- ✓ Adaptation au climat tropical (saisons sèches/pluvieuses)
- ✓ JSON valide sans erreur de syntaxe

RÉPONSE ATTENDUE : JSON pur uniquement, sans texte avant/après.''';
  }

  // Génération du prompt utilisateur
  String _buildUserPrompt({
    required String animalType,
    required int animalCount,
    required String localite,
    required String conditionArriver,
    required String elevageNom,
    required String userId,
    required String dateArrivee,
    required String statutSanitaire,
    String? detailsSanitaire,
  }) {
    final ref = REFERENCE_CONFIG[animalType];
    
    return '''Génère un planning $animalType STRICTEMENT conforme au schéma JSON.

DONNÉES D'ENTRÉE :
- Nom élevage: "$elevageNom"
- Type: "$animalType"
- Effectif: $animalCount animaux
- Localité: $localite
- Date d'arrivée: $dateArrivee
- État initial: $conditionArriver
- Statut sanitaire: $statutSanitaire
- User ID: $userId
${detailsSanitaire != null ? '- Détails sanitaires: $detailsSanitaire' : ''}

CONTEXTE GÉOGRAPHIQUE :
- Zone tropicale africaine
- Ressources vétérinaires limitées
- Saison actuelle à considérer

EXIGENCES :
1. Planning sur 12 mois minimum
2. Protocoles adaptés au contexte local
3. Fréquences réalistes pour l'Afrique
4. Contraintes budgétaires modérées

RÉFÉRENCE TECHNIQUE : ${ref!['url']}

Génère UNIQUEMENT le JSON, sans commentaire.''';
  }

  // Méthode principale de génération du planning
  Future<Map<String, dynamic>> generateStrictPlanning({
    required String animalType,
    required int animalCount,
    required String localite,
    required String conditionArriver,
    required String elevageNom,
    required String userId,
    required String dateArrivee,
    required String statutSanitaire,
    String? detailsSanitaire,
  }) async {
    try {
      // Validation des entrées
      _validateInputs(animalType, animalCount, elevageNom, userId, dateArrivee);
      
      print('🔄 Génération du planning pour: $elevageNom ($animalType)');
      
      final systemPrompt = _buildSystemPrompt(animalType);
      final userPrompt = _buildUserPrompt(
        animalType: animalType,
        animalCount: animalCount,
        localite: localite,
        conditionArriver: conditionArriver,
        elevageNom: elevageNom,
        userId: userId,
        dateArrivee: dateArrivee,
        statutSanitaire: statutSanitaire,
        detailsSanitaire: detailsSanitaire,
      );

      // Créer un modèle avec instruction système
      final model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          topK: 1,
          topP: 0.8,
          maxOutputTokens: 4096,
        ),
        // systemInstruction: Content.text(systemPrompt),
      );

      // Génération avec gestion d'erreur
      final response = await model.generateContent([
        Content.text(systemPrompt)
      ]).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout: Gemini a mis trop de temps à répondre'),
      );

      final text = response.text?.trim() ?? '';
      
      if (text.isEmpty) {
        throw Exception('Réponse vide de Gemini');
      }

      // Extraction et validation du JSON
      final jsonResult = _extractAndValidateJson(text);
      
      print('✅ Planning généré avec succès pour $elevageNom');
      return jsonResult;

    } catch (e) {
      print('❌ Erreur lors de la génération: $e');
      return _createErrorResponse(e.toString(), animalType, elevageNom);
    }
  }

  // Validation des entrées
  void _validateInputs(String animalType, int animalCount, String elevageNom, 
                      String userId, String dateArrivee) {
    if (!REFERENCE_CONFIG.containsKey(animalType)) {
      throw ArgumentError('Type d\'animal non supporté: $animalType');
    }
    
    if (animalCount <= 0) {
      throw ArgumentError('L\'effectif doit être supérieur à 0');
    }
    
    if (elevageNom.trim().isEmpty) {
      throw ArgumentError('Le nom de l\'élevage ne peut pas être vide');
    }
    
    if (userId.trim().isEmpty) {
      throw ArgumentError('L\'ID utilisateur ne peut pas être vide');
    }

    // Validation du format de date
    try {
      DateTime.parse(dateArrivee);
    } catch (e) {
      throw ArgumentError('Format de date invalide pour dateArrivee: $dateArrivee');
    }
  }

  // Extraction et validation du JSON
  Map<String, dynamic> _extractAndValidateJson(String text) {
    try {
      // Chercher le JSON dans la réponse (entre { et })
      final jsonMatch = RegExp(r'\{[\s\S]*\}', multiLine: true).firstMatch(text);
      
      if (jsonMatch == null) {
        throw Exception('Aucun JSON trouvé dans la réponse:\n$text');
      }

      final jsonString = jsonMatch.group(0)!;
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validation de base de la structure
      _validateJsonStructure(decoded);
      
      return decoded;
    } catch (e) {
      throw Exception('Erreur de parsing JSON: $e\nTexte reçu:\n$text');
    }
  }

  // Validation de la structure JSON
  void _validateJsonStructure(Map<String, dynamic> json) {
    final requiredFields = ['nom', 'type', 'user_id', 'conditions_initiales', 'planning'];
    
    for (final field in requiredFields) {
      if (!json.containsKey(field)) {
        throw Exception('Champ requis manquant: $field');
      }
    }
    
    // Validation du type d'animal
    if (!REFERENCE_CONFIG.containsKey(json['type'])) {
      throw Exception('Type d\'animal invalide: ${json['type']}');
    }
    
    // Validation de la structure planning
    final planning = json['planning'] as Map<String, dynamic>?;
    if (planning == null || !planning.containsKey('periode')) {
      throw Exception('Structure de planning invalide');
    }
  }

  // Création d'une réponse d'erreur
  Map<String, dynamic> _createErrorResponse(String error, String animalType, String elevageNom) {
    return {
      "error": true,
      "message": "Échec de génération du planning",
      "details": error,
      "fallback_data": {
        "nom": elevageNom,
        "type": animalType,
        "user_id": "unknown",
        "conditions_initiales": {
          "date_arrivee": DateTime.now().toIso8601String().split('T')[0],
          "effectif": 0,
          "statut_sanitaire": {
            "valeur": "moyen",
            "details": "Données non disponibles suite à l'erreur"
          }
        },
        "planning": {
          "periode": {
            "debut": DateTime.now().toIso8601String().split('T')[0],
            "fin": DateTime.now().add(Duration(days: 365)).toIso8601String().split('T')[0]
          },
          "protocoles": [],
          "evenements": []
        }
      }
    };
  }

  // Méthode utilitaire pour tester la connexion
  Future<bool> testConnection() async {
    try {
      final response = await _model.generateContent([
        Content.text('Réponds simplement "OK" pour tester la connexion.')
      ]).timeout(Duration(seconds: 10));
      
      return response.text?.toLowerCase().contains('ok') ?? false;
    } catch (e) {
      print('❌ Test de connexion échoué: $e');
      return false;
    }
  }

  // Récupération des types d'animaux supportés
  List<String> getSupportedAnimalTypes() {
    return REFERENCE_CONFIG.keys.toList();
  }

  // Récupération des informations de référence pour un type d'animal
  Map<String, dynamic>? getReferenceInfo(String animalType) {
    return REFERENCE_CONFIG[animalType];
  }
}