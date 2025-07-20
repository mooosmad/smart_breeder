// lib/views/generate_planning_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_breeder/data/services/gemini_strict_planning_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class GeneratePlanningView extends StatefulWidget {
  const GeneratePlanningView({super.key});

  @override
  State<GeneratePlanningView> createState() => _GeneratePlanningViewState();
}

class _GeneratePlanningViewState extends State<GeneratePlanningView> {
  final _formKey = GlobalKey<FormState>();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _currentField = '';
  bool _isGenerating = false;
  
  // Service Gemini
  final GeminiStrictPlanningService _planningService = Get.find<GeminiStrictPlanningService>();
  
  // Contrôleurs pour tous les champs
  final _elevageNomCtrl = TextEditingController();
  final _localiteCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _userIdCtrl = TextEditingController();
  final _detailsSanitairesCtrl = TextEditingController();

  // Variables pour les selects
  String _selectedAnimalType = 'volailles'; // Par défaut pour les poulets
  String _selectedStatutSanitaire = 'bon';
  String _selectedConditionArrivee = 'bon';
  DateTime _selectedDateArrivee = DateTime.now();

  // Listes adaptées au service
  final Map<String, String> _animalTypes = {
    'volailles': 'Volailles (Poulets/Poules)',
    'bovins': 'Bovins (Vaches/Taureaux)',
    'ovins': 'Ovins (Moutons/Brebis)',
    'caprins': 'Caprins (Chèvres/Boucs)',
    'porcins': 'Porcins (Porcs/Truies)',
  };

  final List<String> _statutsSanitaires = [
    'excellent',
    'bon', 
    'moyen',
    'mauvais'
  ];

  final List<String> _conditionsArrivee = [
    'excellent',
    'bon',
    'moyen', 
    'mauvais'
  ];

  @override
  void onInit() {
    super.initState();
    _speech = stt.SpeechToText();
    // Générer un ID utilisateur par défaut
    _userIdCtrl.text = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    _elevageNomCtrl.dispose();
    _localiteCtrl.dispose();
    _quantityCtrl.dispose();
    _userIdCtrl.dispose();
    _detailsSanitairesCtrl.dispose();
    super.dispose();
  }

  void _startListening(String fieldName, TextEditingController controller) async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _currentField = fieldName;
      });
      
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              controller.text = result.recognizedWords;
              _isListening = false;
              _currentField = '';
            });
          }
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _currentField = '';
    });
  }

  Widget _buildTextFieldWithVoice(
    String label, 
    TextEditingController controller, 
    {bool isNumber = false, int maxLines = 1, bool required = true}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                maxLines: maxLines,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green[700]!),
                  ),
                  hintText: 'Saisissez $label',
                ),
                validator: required ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est requis';
                  }
                  if (isNumber) {
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Veuillez entrer un nombre valide';
                    }
                  }
                  return null;
                } : null,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _isListening && _currentField == label 
                    ? Colors.red : Colors.green[700],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isListening && _currentField == label 
                      ? Icons.stop : Icons.mic,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_isListening && _currentField == label) {
                    _stopListening();
                  } else {
                    _startListening(label, controller);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectField<T>(
    String label,
    T value,
    Map<T, String> items,
    Function(T?) onChanged,
    {bool required = true}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[700]!),
            ),
          ),
          items: items.entries.map((entry) {
            return DropdownMenuItem<T>(
              value: entry.key,
              child: Text(entry.value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
          validator: required ? (value) {
            if (value == null) {
              return 'Veuillez sélectionner une option';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime selectedDate, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                Icon(Icons.calendar_today, color: Colors.green[700]),
              ],
            ),
          ),
        ),
      ],
    );
  }

// lib/views/generate_planning_view.dart
// Modification de la méthode _generatePlanning()

Future<void> _generatePlanning() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isGenerating = true;
  });

  try {
    // Préparer les données pour le service
    final result = await _planningService.generateStrictPlanning(
      animalType: _selectedAnimalType,
      animalCount: int.parse(_quantityCtrl.text),
      localite: _localiteCtrl.text,
      conditionArriver: _selectedConditionArrivee,
      elevageNom: _elevageNomCtrl.text,
      userId: _userIdCtrl.text,
      dateArrivee: '${_selectedDateArrivee.year}-${_selectedDateArrivee.month.toString().padLeft(2, '0')}-${_selectedDateArrivee.day.toString().padLeft(2, '0')}',
      statutSanitaire: _selectedStatutSanitaire,
      detailsSanitaire: _detailsSanitairesCtrl.text.isNotEmpty ? _detailsSanitairesCtrl.text : null,
    );

    // Vérifier si c'est une erreur
    if (result.containsKey('error') && result['error'] == true) {
      Get.snackbar(
        '❌ Erreur',
        result['message'] ?? 'Erreur lors de la génération',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      
      // Afficher les détails de l'erreur
      if (result.containsKey('details')) {
        print('Détails de l\'erreur: ${result['details']}');
      }
      return;
    }

    // Préparer les données formatées pour AnalyticsView
    final formattedData = {
      'planningData': result,
      'chickenType': _animalTypes[_selectedAnimalType] ?? _selectedAnimalType,
      'animalType': _selectedAnimalType,
      'elevageNom': _elevageNomCtrl.text,
      'quantity': int.parse(_quantityCtrl.text),
      'localite': _localiteCtrl.text,
      'conditionArrivee': _selectedConditionArrivee,
      'statutSanitaire': _selectedStatutSanitaire,
      'dateArrivee': _selectedDateArrivee,
      'detailsSanitaire': _detailsSanitairesCtrl.text,
      'userId': _userIdCtrl.text,
      'createdAt': DateTime.now(),
      // Données supplémentaires pour l'affichage
      'breed': _animalTypes[_selectedAnimalType] ?? 'Non spécifié',
      'age': _calculateInitialAge(), // Méthode à créer
      'averageWeight': _getAverageWeight(_selectedAnimalType),
      'origin': _localiteCtrl.text,
      'housingType': _getHousingType(_selectedAnimalType),
      'buildingDimensions': _calculateBuildingDimensions(int.parse(_quantityCtrl.text), _selectedAnimalType),
      'budget': _calculateBudget(int.parse(_quantityCtrl.text), _selectedAnimalType),
    };

    // Naviguer vers AnalyticsView avec les données
    Get.toNamed('/analytics', arguments: formattedData);

    Get.snackbar(
      '✅ Succès',
      'Planning généré avec succès !',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

  } catch (e) {
    Get.snackbar(
      '❌ Erreur',
      'Erreur inattendue: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
    print('Erreur lors de la génération: $e');
  } finally {
    setState(() {
      _isGenerating = false;
    });
  }
}

// Méthodes auxiliaires à ajouter dans la classe _GeneratePlanningViewState

int _calculateInitialAge() {
  // Calculer l'âge initial basé sur le type d'animal
  switch (_selectedAnimalType) {
    case 'volailles':
      return 1; // Commencer avec des poussins d'une semaine
    case 'bovins':
      return 8; // Veaux de 2 mois
    case 'ovins':
    case 'caprins':
      return 4; // Jeunes de 1 mois
    case 'porcins':
      return 6; // Porcelets de 6 semaines
    default:
      return 1;
  }
}

String _getAverageWeight(String animalType) {
  switch (animalType) {
    case 'volailles':
      return '0.1'; // 100g pour poussins
    case 'bovins':
      return '80'; // 80kg pour veaux
    case 'ovins':
      return '15'; // 15kg pour agneaux
    case 'caprins':
      return '12'; // 12kg pour chevreaux
    case 'porcins':
      return '8'; // 8kg pour porcelets
    default:
      return '0.5';
  }
}

String _getHousingType(String animalType) {
  switch (animalType) {
    case 'volailles':
      return 'Poulailler semi-ouvert';
    case 'bovins':
      return 'Étable avec paddock';
    case 'ovins':
    case 'caprins':
      return 'Bergerie avec parcours';
    case 'porcins':
      return 'Porcherie ventilée';
    default:
      return 'Bâtiment standard';
  }
}

String _calculateBuildingDimensions(int quantity, String animalType) {
  double surfacePerAnimal;
  
  switch (animalType) {
    case 'volailles':
      surfacePerAnimal = 0.5; // 0.5 m² par poulet
      break;
    case 'bovins':
      surfacePerAnimal = 8.0; // 8 m² par bovin
      break;
    case 'ovins':
    case 'caprins':
      surfacePerAnimal = 2.0; // 2 m² par ovin/caprin
      break;
    case 'porcins':
      surfacePerAnimal = 1.5; // 1.5 m² par porc
      break;
    default:
      surfacePerAnimal = 1.0;
  }
  
  final totalSurface = (quantity * surfacePerAnimal).ceil();
  return totalSurface.toString();
}

String _calculateBudget(int quantity, String animalType) {
  double costPerAnimal;
  
  switch (animalType) {
    case 'volailles':
      costPerAnimal = 2500; // 2500 F par poulet par mois
      break;
    case 'bovins':
      costPerAnimal = 15000; // 15000 F par bovin par mois
      break;
    case 'ovins':
    case 'caprins':
      costPerAnimal = 5000; // 5000 F par ovin/caprin par mois
      break;
    case 'porcins':
      costPerAnimal = 8000; // 8000 F par porc par mois
      break;
    default:
      costPerAnimal = 3000;
  }
  
  final totalBudget = (quantity * costPerAnimal).round();
  return '${totalBudget.toString()} F CFA/mois';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer un Planning d\'Élevage'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          if (_isListening)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic, size: 16),
                  const SizedBox(width: 4),
                  Text('Écoute: $_currentField'),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Informations Générales
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Informations Générales',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextFieldWithVoice('Nom de l\'élevage', _elevageNomCtrl),
                        const SizedBox(height: 16),
                        
                        _buildSelectField<String>(
                          'Type d\'animal',
                          _selectedAnimalType,
                          _animalTypes,
                          (value) => setState(() => _selectedAnimalType = value!),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextFieldWithVoice('Localité/Région', _localiteCtrl),
                        const SizedBox(height: 16),
                        
                        _buildTextFieldWithVoice('Nombre d\'animaux', _quantityCtrl, isNumber: true),
                        const SizedBox(height: 16),
                        
                        _buildDateField(
                          'Date d\'arrivée des animaux',
                          _selectedDateArrivee,
                          (date) => setState(() => _selectedDateArrivee = date),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Section État Sanitaire
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.health_and_safety, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'État Sanitaire',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSelectField<String>(
                          'Condition à l\'arrivée',
                          _selectedConditionArrivee,
                          Map.fromIterable(_conditionsArrivee, key: (e) => e, value: (e) => e.toUpperCase()),
                          (value) => setState(() => _selectedConditionArrivee = value!),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSelectField<String>(
                          'Statut sanitaire général',
                          _selectedStatutSanitaire,
                          Map.fromIterable(_statutsSanitaires, key: (e) => e, value: (e) => e.toUpperCase()),
                          (value) => setState(() => _selectedStatutSanitaire = value!),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextFieldWithVoice(
                          'Détails sanitaires (optionnel)',
                          _detailsSanitairesCtrl,
                          maxLines: 3,
                          required: false,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Section Configuration
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Configuration',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextFieldWithVoice('ID Utilisateur', _userIdCtrl, required: false),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Bouton de génération
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _generatePlanning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isGenerating
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Génération en cours...',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white),
                              const SizedBox(width: 8),
                              const Text(
                                'Générer le Planning avec IA',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Note informative
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ce planning sera généré par IA en utilisant les meilleures pratiques vétérinaires pour votre région.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}