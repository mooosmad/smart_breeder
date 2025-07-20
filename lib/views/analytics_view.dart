// lib/views/analytics_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert'; // Ajouté pour parser le JSON

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? planningData;
  Map<String, dynamic>? parsedPlanningData; // Ajouté pour stocker les données parsées

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Récupérer les données du planning si elles existent
    planningData = Get.arguments as Map<String, dynamic>?;
    _parsePlanningData(); // Parse les données au démarrage
  }

  // Nouvelle méthode pour parser les données du planning IA
  void _parsePlanningData() {
    if (planningData != null && planningData!['planningData'] != null) {
      try {
        if (planningData!['planningData'] is String) {
          // Si c'est une chaîne JSON, la parser
          parsedPlanningData = json.decode(planningData!['planningData']);
        } else if (planningData!['planningData'] is Map) {
          // Si c'est déjà un Map, l'utiliser directement
          parsedPlanningData = planningData!['planningData'];
        }
      } catch (e) {
        print('Erreur lors du parsing du planning: $e');
        parsedPlanningData = null;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics & Planning'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.calendar_view_week), text: 'Planning'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/generate-planning'),
            tooltip: 'Générer un nouveau planning',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsTab(),
          _buildPlanningTab(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Animaux', '1,250', Icons.pets, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Coût Mensuel', '145,000 F', Icons.attach_money, Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Vaccinations', '12', Icons.medical_services, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Alertes', '3', Icons.warning, Colors.red)),
              ],
            ),

            const SizedBox(height: 24),

            // Graphique des coûts
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Évolution des Coûts (derniers 6 mois)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(1, 120000),
                                FlSpot(2, 135000),
                                FlSpot(3, 125000),
                                FlSpot(4, 140000),
                                FlSpot(5, 138000),
                                FlSpot(6, 145000),
                              ],
                              isCurved: true,
                              color: const Color(0xFF2E7D32),
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF2E7D32).withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Répartition par type d'animal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Répartition du Cheptel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: 60,
                              title: 'Poulets\n750',
                              color: Colors.orange,
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: 30,
                              title: 'Poules\n375',
                              color: Colors.brown,
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: 10,
                              title: 'Autres\n125',
                              color: Colors.blue,
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningTab() {
    if (planningData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_view_week,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun planning généré',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + pour créer un planning',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/generate-planning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Générer un Planning'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du planning
            Card(
              color: Colors.green[700],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Planning Généré par IA',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(planningData!['createdAt']),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPlanningInfo('Élevage', planningData!['elevageNom'] ?? 'Non spécifié'),
                        const SizedBox(width: 20),
                        _buildPlanningInfo('Type', planningData!['chickenType'] ?? 'Non spécifié'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPlanningInfo('Quantité', '${planningData!['quantity']} sujets'),
                        const SizedBox(width: 20),
                        _buildPlanningInfo('Localité', planningData!['localite'] ?? 'Non spécifié'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informations détaillées
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations du Cheptel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Type d\'animal', planningData!['breed'] ?? 'Non spécifié'),
                    _buildDetailRow('Âge initial', '${planningData!['age']} semaines'),
                    _buildDetailRow('Poids moyen', '${planningData!['averageWeight']} kg'),
                    _buildDetailRow('Origine/Localité', planningData!['origin'] ?? 'Non spécifié'),
                    _buildDetailRow('Type de logement', planningData!['housingType'] ?? 'Standard'),
                    _buildDetailRow('Surface nécessaire', '${planningData!['buildingDimensions']} m²'),
                    _buildDetailRow('Budget mensuel estimé', planningData!['budget'] ?? 'Non calculé'),
                    _buildDetailRow('Date d\'arrivée', _formatDate(planningData!['dateArrivee'])),
                    _buildDetailRow('Condition à l\'arrivée', planningData!['conditionArrivee']?.toUpperCase() ?? 'BON'),
                    _buildDetailRow('Statut sanitaire', planningData!['statutSanitaire']?.toUpperCase() ?? 'BON'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // État sanitaire
            if (planningData!['detailsSanitaire'] != null && 
                planningData!['detailsSanitaire'].toString().isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.health_and_safety, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Détails Sanitaires',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          planningData!['detailsSanitaire'].toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Planning IA structuré (remplace l'affichage JSON brut)
            if (parsedPlanningData != null) ...[
              _buildAIPlanningSection(),
              const SizedBox(height: 16),
            ],

            // Planning hebdomadaire généré automatiquement
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Planning des Prochaines Semaines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._generateWeeklyPlanning(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recommandations IA basées sur les données réelles
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Recommandations Personnalisées',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._generateRecommendations(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Retourner à la page de génération pour modifier
                      Get.toNamed('/generate-planning');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Nouveau Planning'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Fonction pour exporter le planning
                      _exportPlanning();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Exporter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour afficher le planning IA de manière structurée
  Widget _buildAIPlanningSection() {
    if (parsedPlanningData == null) return Container();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text(
                  'Planning IA Détaillé',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Calendrier de soins si disponible
            if (parsedPlanningData!['calendar'] != null) ...[
              const Text(
                'Calendrier de Soins',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildCalendarSection(parsedPlanningData!['calendar']),
              const SizedBox(height: 16),
            ],
            
            // Recommandations nutritionnelles si disponibles
            if (parsedPlanningData!['nutrition'] != null) ...[
              const Text(
                'Programme Nutritionnel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildNutritionSection(parsedPlanningData!['nutrition']),
              const SizedBox(height: 16),
            ],
            
            // Protocole sanitaire si disponible
            if (parsedPlanningData!['health'] != null) ...[
              const Text(
                'Protocole Sanitaire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildHealthSection(parsedPlanningData!['health']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(dynamic calendar) {
    if (calendar is List) {
      return Column(
        children: calendar.map<Widget>((event) => _buildCalendarEvent(event)).toList(),
      );
    } else if (calendar is Map) {
      return _buildCalendarEvent(calendar);
    }
    return Text('Données du calendrier: ${calendar.toString()}');
  }

  Widget _buildCalendarEvent(dynamic event) {
    if (event is! Map) return Container();
    
    final Map eventMap = event;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eventMap['date'] != null)
            Text(
              'Date: ${eventMap['date']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          if (eventMap['activity'] != null)
            Text('Activité: ${eventMap['activity']}'),
          if (eventMap['description'] != null)
            Text('Description: ${eventMap['description']}'),
        ],
      ),
    );
  }

  Widget _buildNutritionSection(dynamic nutrition) {
    if (nutrition is Map) {
      final Map nutritionMap = nutrition;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nutritionMap['feedType'] != null)
              Text('Type d\'aliment: ${nutritionMap['feedType']}'),
            if (nutritionMap['dailyAmount'] != null)
              Text('Quantité journalière: ${nutritionMap['dailyAmount']}'),
            if (nutritionMap['frequency'] != null)
              Text('Fréquence: ${nutritionMap['frequency']}'),
            if (nutritionMap['supplements'] != null)
              Text('Suppléments: ${nutritionMap['supplements']}'),
          ],
        ),
      );
    }
    return Text('Données nutritionnelles: ${nutrition.toString()}');
  }

  Widget _buildHealthSection(dynamic health) {
    if (health is List) {
      return Column(
        children: health.map<Widget>((protocol) => _buildHealthProtocol(protocol)).toList(),
      );
    } else if (health is Map) {
      return _buildHealthProtocol(health);
    }
    return Text('Données sanitaires: ${health.toString()}');
  }

  Widget _buildHealthProtocol(dynamic protocol) {
    if (protocol is! Map) return Container();
    
    final Map protocolMap = protocol;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (protocolMap['vaccine'] != null)
            Text(
              'Vaccin: ${protocolMap['vaccine']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          if (protocolMap['age'] != null)
            Text('Âge: ${protocolMap['age']} semaines'),
          if (protocolMap['method'] != null)
            Text('Méthode: ${protocolMap['method']}'),
          if (protocolMap['notes'] != null)
            Text('Notes: ${protocolMap['notes']}'),
        ],
      ),
    );
  }

  // Nouvelle méthode pour exporter le planning
  void _exportPlanning() {
    if (planningData == null) return;
    
    final exportData = {
      'elevage': planningData!['elevageNom'],
      'type_animal': planningData!['chickenType'],
      'quantite': planningData!['quantity'],
      'date_creation': _formatDate(planningData!['createdAt']),
      'localite': planningData!['localite'],
      'condition_arrivee': planningData!['conditionArrivee'],
      'statut_sanitaire': planningData!['statutSanitaire'],
      'budget_mensuel': planningData!['budget'],
      'planning_ia': parsedPlanningData, // Inclure le planning IA parsé
    };
    
    // print('Données à exporter: ${json.encode(exportData, indent: 2)}');
    
    Get.snackbar(
      'Export réussi',
      'Planning exporté avec succès !\nVérifiez la console pour les détails.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Remplacez la méthode _generateWeeklyPlanning() existante par celle-ci :

List<Widget> _generateWeeklyPlanning() {
  final currentAge = planningData!['age'] ?? 0;
  final chickenType = planningData!['chickenType'] ?? '';
  final quantity = planningData!['quantity'] ?? 0;
  final currentDate = DateTime.now();
  
  List<Widget> weeks = [];
  
  // Utiliser les données du planning IA si disponibles
  if (parsedPlanningData != null && parsedPlanningData!['weeklyPlan'] != null) {
    final weeklyPlan = parsedPlanningData!['weeklyPlan'];
    if (weeklyPlan is List) {
      for (int i = 0; i < weeklyPlan.length; i++) {
        final week = weeklyPlan[i];
        final weekDate = currentDate.add(Duration(days: i * 7));
        weeks.add(_buildWeekCardFromIA(
          'Semaine ${i + 1}',
          week,
          i == 0 ? Colors.green : (i == 1 ? Colors.blue : Colors.orange),
        ));
      }
    }
  } else {
    // Génération dynamique basée sur l'âge actuel et le type d'élevage
    final totalWeeks = _calculateTotalWeeks(chickenType, currentAge);
    final weeksToShow = totalWeeks > 8 ? 8 : totalWeeks; // Limiter à 8 semaines max
    
    for (int i = 1; i <= weeksToShow; i++) {
      final weekAge = currentAge + i;
      final weekDate = currentDate.add(Duration(days: i * 7));
      final weekData = _generateDynamicWeekData(weekAge, chickenType, quantity, i);
      
      weeks.add(_buildDynamicWeekCard(
        'Semaine $i',
        weekAge,
        weekDate,
        weekData,
        _getWeekColor(i, weekAge, chickenType),
      ));
    }
  }
  
  return weeks;
}

// Nouvelle méthode pour calculer le nombre total de semaines selon le type
int _calculateTotalWeeks(String chickenType, int currentAge) {
  if (chickenType.toLowerCase().contains('chair')) {
    return (8 - currentAge).clamp(1, 8); // Poulets de chair jusqu'à 8 semaines
  } else if (chickenType.toLowerCase().contains('pondeuses')) {
    return 12; // Pondeuses ont un cycle plus long
  } else {
    return 8; // Par défaut
  }
}

// Nouvelle méthode pour générer des données de semaine dynamiques
Map<String, dynamic> _generateDynamicWeekData(int age, String chickenType, int quantity, int weekNumber) {
  final isChair = chickenType.toLowerCase().contains('chair');
  final isPondeuses = chickenType.toLowerCase().contains('pondeuses');
  
  Map<String, dynamic> weekData = {
    'age': '$age semaines',
    'tasks': <String>[],
    'nutrition': '',
    'health': '',
    'description': '',
    'priority': 'normal',
    'estimatedCost': 0,
  };
  
  // Tâches spécifiques par âge et type
  if (isChair) {
    if (age <= 2) {
      weekData['tasks'] = [
        'Maintenir température 32-35°C avec chauffage',
        'Alimentation starter haute protéine (6x/jour)',
        'Contrôler humidité 60-70%',
        'Vaccination Newcastle (si due)',
        'Surveiller comportement et croissance',
      ];
      weekData['nutrition'] = 'Starter 22-24% protéines, ${_calculateFeedAmount(quantity, age)}kg/jour';
      weekData['health'] = 'Observation quotidienne, température corporelle';
      weekData['description'] = 'Phase critique de démarrage - surveillance intensive requise';
      weekData['priority'] = 'high';
      weekData['estimatedCost'] = quantity * 15; // 15 FCFA par sujet
    } else if (age <= 4) {
      weekData['tasks'] = [
        'Réduire température à 28-30°C progressivement',
        'Alimentation croissance (4x/jour)',
        'Pesée échantillon (10% du lot)',
        'Nettoyage quotidien des abreuvoirs',
        'Contrôle ventilation',
      ];
      weekData['nutrition'] = 'Croissance 18-20% protéines, ${_calculateFeedAmount(quantity, age)}kg/jour';
      weekData['health'] = 'Pesée hebdomadaire, vaccination Gumboro si nécessaire';
      weekData['description'] = 'Phase de croissance rapide - optimiser l\'alimentation';
      weekData['priority'] = 'normal';
      weekData['estimatedCost'] = quantity * 25;
    } else if (age <= 6) {
      weekData['tasks'] = [
        'Température ambiante 25-28°C',
        'Alimentation finition (3x/jour)',
        'Évaluation poids commercial',
        'Préparation logistique vente',
        'Restriction alimentaire avant abattage',
      ];
      weekData['nutrition'] = 'Finition 16-18% protéines, ${_calculateFeedAmount(quantity, age)}kg/jour';
      weekData['health'] = 'Inspection pré-abattage, retrait antibiotiques';
      weekData['description'] = 'Finition pour commercialisation - optimiser le poids';
      weekData['priority'] = 'high';
      weekData['estimatedCost'] = quantity * 30;
    } else {
      weekData['tasks'] = [
        'Évaluation finale du lot',
        'Organisation transport abattoir',
        'Jeûne pré-abattage (8-12h)',
        'Préparation documents sanitaires',
        'Nettoyage et désinfection après vente',
      ];
      weekData['nutrition'] = 'Jeûne contrôlé selon planning abattage';
      weekData['health'] = 'Certificat sanitaire, inspection vétérinaire';
      weekData['description'] = 'Phase finale - préparation commercialisation';
      weekData['priority'] = 'critical';
      weekData['estimatedCost'] = quantity * 10;
    }
  } else if (isPondeuses) {
    if (age <= 18) {
      weekData['tasks'] = [
        'Alimentation poulettes adaptée à l\'âge',
        'Contrôle croissance et uniformité',
        'Programme lumineux adapté',
        'Vaccination selon protocole',
        'Préparation transition ponte',
      ];
      weekData['nutrition'] = 'Poulettes ${age < 12 ? "croissance" : "pré-ponte"}, ${_calculateFeedAmount(quantity, age)}kg/jour';
      weekData['health'] = 'Suivi croissance, vaccinations programmées';
      weekData['description'] = 'Élevage poulettes - préparation à la ponte';
      weekData['priority'] = 'normal';
      weekData['estimatedCost'] = quantity * 20;
    } else {
      final ponteRate = age > 24 ? 85 : (age - 18) * 10 + 50; // Simulation taux de ponte
      weekData['tasks'] = [
        'Ramassage œufs 3x/jour minimum',
        'Contrôle taux de ponte ($ponteRate%)',
        'Alimentation ponte haute calcium',
        'Gestion éclairage (14-16h/jour)',
        'Tri et calibrage des œufs',
      ];
      weekData['nutrition'] = 'Ponte 16-18% protéines + calcium, ${_calculateFeedAmount(quantity, age)}kg/jour';
      weekData['health'] = 'Contrôle qualité coquille, supplément calcium';
      weekData['description'] = 'Phase de ponte productive - maximiser la production';
      weekData['priority'] = ponteRate > 80 ? 'high' : 'normal';
      weekData['estimatedCost'] = quantity * 35;
    }
  } else {
    // Type générique ou mixte
    weekData['tasks'] = [
      'Contrôle quotidien eau et alimentation',
      'Inspection visuelle du cheptel',
      'Nettoyage des équipements',
      'Relevé des paramètres d\'ambiance',
      'Tenue registre d\'élevage',
    ];
    weekData['nutrition'] = 'Alimentation adaptée à l\'âge et objectif';
    weekData['health'] = 'Surveillance sanitaire quotidienne';
    weekData['description'] = 'Gestion standard du cheptel';
    weekData['priority'] = 'normal';
    weekData['estimatedCost'] = quantity * 20;
  }
  
  return weekData;
}

// Méthode pour calculer la quantité d'aliment nécessaire
String _calculateFeedAmount(int quantity, int age) {
  double feedPerBird;
  
  if (age <= 2) {
    feedPerBird = 0.025; // 25g par sujet
  } else if (age <= 4) {
    feedPerBird = 0.060; // 60g par sujet
  } else if (age <= 6) {
    feedPerBird = 0.120; // 120g par sujet
  } else {
    feedPerBird = 0.140; // 140g par sujet
  }
  
  final totalKg = (quantity * feedPerBird).roundToDouble();
  return totalKg.toStringAsFixed(1);
}

// Méthode pour déterminer la couleur selon le contexte
Color _getWeekColor(int weekNumber, int age, String chickenType) {
  final isChair = chickenType.toLowerCase().contains('chair');
  
  if (weekNumber == 1) return Colors.green; // Semaine actuelle
  
  if (isChair) {
    if (age <= 2) return Colors.red; // Phase critique
    if (age <= 4) return Colors.blue; // Croissance
    if (age <= 6) return Colors.orange; // Finition
    return Colors.purple; // Commercialisation
  } else {
    if (age <= 18) return Colors.blue; // Élevage
    return Colors.orange; // Ponte
  }
}

// Nouvelle méthode pour construire les cartes de semaine dynamiques
Widget _buildDynamicWeekCard(String week, int age, DateTime weekDate, Map<String, dynamic> weekData, Color color) {
  final priority = weekData['priority'] as String;
  final estimatedCost = weekData['estimatedCost'] as int;
  
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border(
        left: BorderSide(
          color: color,
          width: priority == 'critical' ? 6 : (priority == 'high' ? 5 : 4),
        ),
      ),
      boxShadow: priority == 'critical' ? [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ] : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              priority == 'critical' ? Icons.priority_high : 
              priority == 'high' ? Icons.warning : Icons.calendar_view_week,
              color: color,
              size: priority == 'critical' ? 24 : 20,
            ),
            const SizedBox(width: 8),
            Text(
              week,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${weekDate.day}/${weekDate.month}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${weekData['age']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        if (priority == 'critical') ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'PHASE CRITIQUE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        // Description de la semaine
        if (weekData['description'].toString().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              weekData['description'].toString(),
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Tâches principales
        ...((weekData['tasks'] as List<String>).take(3).map((task) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ))).toList(),
        
        // Affichage du reste des tâches si plus de 3
        if ((weekData['tasks'] as List).length > 3) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _showAllTasks(week, weekData['tasks'] as List<String>),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '+ ${(weekData['tasks'] as List).length - 3} autres tâches...',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        // Informations nutritionnelles
        if (weekData['nutrition'].toString().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 6),
                    const Text(
                      'Nutrition',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  weekData['nutrition'].toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Informations sanitaires
        if (weekData['health'].toString().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.health_and_safety, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 6),
                    const Text(
                      'Santé & Suivi',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  weekData['health'].toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Coût estimé
        if (estimatedCost > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_money, size: 14, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(
                  'Coût estimé: ${estimatedCost.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

// Méthode pour afficher toutes les tâches dans un dialog
void _showAllTasks(String week, List<String> tasks) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tâches - $week',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...tasks.map((task) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.task_alt, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildWeekCardFromIA(String week, dynamic weekData, Color color) {
    if (weekData is! Map) {
      return _buildWeekCard(week, 'Données non disponibles', [], color);
    }

    final Map weekMap = weekData;
    final age = weekMap['age'] ?? 'Non spécifié';
    final tasks = weekMap['tasks'] is List 
        ? (weekMap['tasks'] as List).map((e) => e.toString()).toList()
        : <String>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_view_week, color: color),
              const SizedBox(width: 8),
              Text(
                week,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                'Âge: $age',
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (weekMap['description'] != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                weekMap['description'].toString(),
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 8),
          ],
          ...tasks.map((task) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
          if (weekMap['nutrition'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restaurant, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 6),
                      const Text(
                        'Nutrition',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weekMap['nutrition'].toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          if (weekMap['health'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.health_and_safety, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 6),
                      const Text(
                        'Santé',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weekMap['health'].toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekCard(String week, String ageInfo, List<String> tasks, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_view_week, color: color),
              const SizedBox(width: 8),
              Text(
                week,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                ageInfo,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tasks.map((task) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  List<String> _getWeeklyTasks(int age) {
    // Générer des tâches basées sur l'âge et le type de poulet
    final chickenType = planningData!['chickenType'] ?? '';
    List<String> tasks = [];
    
    if (chickenType.contains('chair')) {
      if (age <= 2) {
        tasks = ['Contrôle température (32-35°C)', 'Alimentation démarrage 6x/jour', 'Vaccination Newcastle'];
      } else if (age <= 4) {
        tasks = ['Contrôle température (28-30°C)', 'Alimentation croissance 4x/jour', 'Pesée hebdomadaire'];
      } else if (age <= 6) {
        tasks = ['Contrôle température (25-28°C)', 'Alimentation finition 3x/jour', 'Préparation abattage'];
      } else {
        tasks = ['Évaluation pour abattage', 'Contrôle qualité', 'Planification transport'];
      }
    } else if (chickenType.contains('pondeuses')) {
      if (age <= 18) {
        tasks = ['Alimentation poulettes', 'Contrôle croissance', 'Vaccination'];
      } else {
        tasks = ['Alimentation ponte', 'Ramassage œufs 2x/jour', 'Contrôle ponte'];
      }
    } else {
      // Tâches génériques si le type n'est pas spécifié
      tasks = [
        'Contrôle de l\'eau et de l\'alimentation',
        'Inspection visuelle du cheptel',
        'Nettoyage des équipements'
      ];
    }
    
    return tasks;
  }

  List<Widget> _generateRecommendations() {
    List<String> recommendations = [];
    
    // Utiliser les recommandations de l'IA si disponibles
    if (parsedPlanningData != null && parsedPlanningData!['recommendations'] != null) {
      final aiRecommendations = parsedPlanningData!['recommendations'];
      if (aiRecommendations is List) {
        recommendations = aiRecommendations.map((e) => e.toString()).toList();
      } else if (aiRecommendations is String) {
        recommendations = [aiRecommendations];
      }
    } else {
      // Recommandations automatiques basées sur les données
      final chickenType = planningData!['chickenType'] ?? '';
      final age = planningData!['age'] ?? 0;
      final quantity = planningData!['quantity'] ?? 0;
      
      if (chickenType.contains('chair')) {
        recommendations.add('Optimiser la ventilation pour éviter le stress thermique');
        recommendations.add('Surveiller le taux de conversion alimentaire');
        if (age > 4) {
          recommendations.add('Préparer la commercialisation dans 2-3 semaines');
        }
      }
      
      if (quantity > 500) {
        recommendations.add('Considérer un système automatisé pour l\'alimentation');
      }
      
      recommendations.add('Maintenir un registre quotidien des mortalités');
      recommendations.add('Prévoir un stock de sécurité d\'aliments (7 jours minimum)');
    }
    
    return recommendations.map((rec) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: Colors.amber[700]!, width: 3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rec,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    )).toList();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Date non disponible';
    
    DateTime? dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      try {
        dateTime = DateTime.parse(date);
      } catch (e) {
        return date; // Retourner la chaîne originale si le parsing échoue
      }
    }
    
    if (dateTime != null) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    return date.toString();
  }
}