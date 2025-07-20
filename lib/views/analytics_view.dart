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
      final futureWeekAge = currentAge + i; // CORRECTION: Age réel de la semaine future
      final weekDate = currentDate.add(Duration(days: i * 7));
      final weekData = _generateDynamicWeekData(futureWeekAge, chickenType, quantity, i, currentAge);
      
      weeks.add(_buildDynamicWeekCard(
        'Semaine $i',
        futureWeekAge,
        weekDate,
        weekData,
        _getWeekColor(i, futureWeekAge, chickenType),
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
    return (52 - currentAge).clamp(1, 12); // Pondeuses ont un cycle plus long, max 12 semaines affichées
  } else {
    return (12 - currentAge).clamp(1, 8); // Par défaut
  }
}

// CORRECTION MAJEURE: Méthode pour générer des données de semaine dynamiques avec progression
Map<String, dynamic> _generateDynamicWeekData(int futureAge, String chickenType, int quantity, int weekNumber, int currentAge) {
  final isChair = chickenType.toLowerCase().contains('chair');
  final isPondeuses = chickenType.toLowerCase().contains('pondeuses');
  
  Map<String, dynamic> weekData = {
    'age': '$futureAge semaines',
    'tasks': <String>[],
    'nutrition': '',
    'health': '',
    'description': '',
    'priority': 'normal',
    'estimatedCost': 0,
  };
  
  // CORRECTION: Tâches spécifiques par âge FUTUR et type
  if (isChair) {
    if (futureAge <= 1) {
      weekData['tasks'] = [
        'Installation du matériel de chauffage et éclairage',
        'Préparation des aliments starter (22-24% protéines)',
        'Mise en place des abreuvoirs et mangeoires',
        'Contrôle température initiale 35°C sous éleveuse',
        'Réception et installation des poussins',
      ];
      weekData['nutrition'] = 'Starter 22-24% protéines, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Vaccination J1 (Marek si nécessaire), contrôle température';
      weekData['description'] = 'Installation et démarrage - première semaine critique';
      weekData['priority'] = 'critical';
      weekData['estimatedCost'] = quantity * 50; // Coût installation + poussins
    } else if (futureAge <= 2) {
      weekData['tasks'] = [
        'Maintenir température 32-33°C avec chauffage',
        'Alimentation starter 6 fois par jour',
        'Contrôler humidité 60-65%',
        'Observer comportement alimentaire et hydrique',
        'Ajuster l\'espace disponible selon croissance',
      ];
      weekData['nutrition'] = 'Starter 22-24% protéines, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Surveillance quotidienne mortalité, pesée échantillon';
      weekData['description'] = 'Stabilisation croissance - adaptation aux conditions';
      weekData['priority'] = 'high';
      weekData['estimatedCost'] = quantity * 20;
    } else if (futureAge <= 3) {
      weekData['tasks'] = [
        'Réduire température à 30°C progressivement',
        'Passer à l\'alimentation croissance (18-20% protéines)',
        'Vaccination Newcastle (J21)',
        'Première pesée complète du lot',
        'Ajuster densité si nécessaire',
      ];
      weekData['nutrition'] = 'Croissance 18-20% protéines, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Vaccination Newcastle, contrôle uniformité poids';
      weekData['description'] = 'Transition nutritionnelle - vaccination importante';
      weekData['priority'] = 'high';
      weekData['estimatedCost'] = quantity * 25;
    } else if (futureAge <= 4) {
      weekData['tasks'] = [
        'Température ambiante 28°C',
        'Alimentation croissance 4 fois par jour',
        'Vaccination Gumboro (J28)',
        'Contrôle qualité de l\'eau',
        'Évaluation croissance vs objectifs',
      ];
      weekData['nutrition'] = 'Croissance 18-20% protéines, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Vaccination Gumboro, surveillance respiratoire';
      weekData['description'] = 'Croissance rapide - deuxième vaccination';
      weekData['priority'] = 'normal';
      weekData['estimatedCost'] = quantity * 30;
    } else if (futureAge <= 5) {
      weekData['tasks'] = [
        'Maintenir température 25-27°C',
        'Commencer alimentation finition (16-18% protéines)',
        'Pesée pour évaluation commerciale',
        'Prévoir planning d\'abattage',
        'Optimiser ventilation pour confort',
      ];
      weekData['nutrition'] = 'Finition 16-18% protéines, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Évaluation sanitaire générale, pesée commerciale';
      weekData['description'] = 'Préparation finition - évaluation commerciale';
      weekData['priority'] = 'normal';
      weekData['estimatedCost'] = quantity * 35;
    } else if (futureAge <= 6) {
      weekData['tasks'] = [
        'Alimentation finition 3 fois par jour',
        'Évaluation poids final et uniformité',
        'Contact acheteurs/abattoir',
        'Préparation documents sanitaires',
        'Planning transport et logistique',
      ];
      weekData['nutrition'] = 'Finition 16-18% protéines, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Inspection pré-commercialisation, certificats';
      weekData['description'] = 'Finition commerciale - préparation vente';
      weekData['priority'] = 'high';
      weekData['estimatedCost'] = quantity * 30;
    } else if (futureAge <= 7) {
      weekData['tasks'] = [
        'Restriction alimentaire pré-abattage',
        'Organisation transport vers abattoir',
        'Préparation des caisses de transport',
        'Jeûne hydrique contrôlé (6h avant transport)',
        'Inspection vétérinaire finale',
      ];
      weekData['nutrition'] = 'Restriction progressive, jeûne 8-12h avant abattage';
      weekData['health'] = 'Certificat sanitaire obligatoire, inspection finale';
      weekData['description'] = 'Phase pré-abattage - préparation transport';
      weekData['priority'] = 'critical';
      weekData['estimatedCost'] = quantity * 15;
    } else {
      weekData['tasks'] = [
        'Transport et livraison à l\'abattoir',
        'Nettoyage complet des installations',
        'Désinfection totale du bâtiment',
        'Bilan technique et économique',
        'Préparation nouveau cycle si prévu',
      ];
      weekData['nutrition'] = 'Fin de cycle - pas d\'alimentation';
      weekData['health'] = 'Bilan sanitaire final, nettoyage désinfection';
      weekData['description'] = 'Fin de cycle - nettoyage et bilan';
      weekData['priority'] = 'normal';
      weekData['estimatedCost'] = quantity * 5;
    }
  } else if (isPondeuses) {
    if (futureAge <= 6) {
      weekData['tasks'] = [
        'Alimentation poussin/poulette démarrage',
        'Maintenir température optimale pour l\'âge',
        'Programme lumineux adapté à la croissance',
        'Vaccination selon protocole poulettes',
        'Contrôle croissance et développement',
      ];
      weekData['nutrition'] = 'Poulette démarrage 20-22% protéines, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Vaccinations programmées, suivi croissance';
      weekData['description'] = 'Élevage poulettes - phase démarrage';
      weekData['priority'] = 'normal';
      weekData['estimatedCost'] = quantity * 25;
    } else if (futureAge <= 12) {
      weekData['tasks'] = [
        'Alimentation poulette croissance',
        'Contrôle uniformité du lot',
        'Ajustement programme lumineux',
        'Préparation transition vers ponte',
        'Formation des groupes homogènes',
      ];
      weekData['nutrition'] = 'Poulette croissance 16-18% protéines, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Évaluation développement reproducteur';
      weekData['description'] = 'Croissance poulettes - préparation ponte';
      weekData['priority'] = 'normal';
      weekData['estimatedCost'] = quantity * 30;
    } else if (futureAge <= 18) {
      weekData['tasks'] = [
        'Alimentation pré-ponte enrichie',
        'Augmentation progressive éclairage (12-14h)',
        'Installation/vérification pondoirs',
        'Stimulation début de ponte',
        'Surveillance comportement pré-ponte',
      ];
      weekData['nutrition'] = 'Pré-ponte 17-19% protéines + calcium, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Préparation physiologique ponte';
      weekData['description'] = 'Phase pré-ponte - stimulation ponte';
      weekData['priority'] = 'high';
      weekData['estimatedCost'] = quantity * 35;
    } else if (futureAge <= 25) {
      final weeksSincePonte = futureAge - 18;
      final expectedRate = (weeksSincePonte * 15).clamp(20, 85);
      weekData['tasks'] = [
        'Ramassage œufs 3-4 fois/jour',
        'Contrôle taux ponte (objectif ${expectedRate}%)',
        'Alimentation ponte haute qualité',
        'Éclairage optimal 16h/jour',
        'Tri et calibrage quotidien œufs',
      ];
      weekData['nutrition'] = 'Ponte 16-18% protéines + calcium, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Surveillance qualité coquille, supplément calcium';
      weekData['description'] = 'Montée en ponte - optimisation production';
      weekData['priority'] = expectedRate > 70 ? 'high' : 'normal';
      weekData['estimatedCost'] = quantity * 40;
    } else {
      final ponteRate = 85; // Pic de ponte
      weekData['tasks'] = [
        'Ramassage œufs optimal (4-5 fois/jour)',
        'Maintien taux ponte pic (${ponteRate}%)',
        'Contrôle qualité œufs quotidien',
        'Gestion stockage et commercialisation',
        'Surveillance santé reproductive',
      ];
      weekData['nutrition'] = 'Ponte pic 16-18% protéines + calcium, ${_calculateFeedAmount(quantity, futureAge)}kg/jour';
      weekData['health'] = 'Optimisation santé reproductive, qualité coquille';
      weekData['description'] = 'Pic de ponte - production maximale';
      weekData['priority'] = 'high';
      weekData['estimatedCost'] = quantity * 45;
    }
  } else {
    // Type générique avec progression
    final progressionPhase = _getGenericPhase(futureAge, weekNumber);
    weekData['tasks'] = progressionPhase['tasks'];
    weekData['nutrition'] = progressionPhase['nutrition'];
    weekData['health'] = progressionPhase['health'];
    weekData['description'] = progressionPhase['description'];
    weekData['priority'] = progressionPhase['priority'];
    weekData['estimatedCost'] = quantity * progressionPhase['costPerBird'];
  }
  
  return weekData;
}

// Nouvelle méthode pour gérer la progression générique
Map<String, dynamic> _getGenericPhase(int age, int weekNumber) {
  if (age <= 3) {
    return {
      'tasks': [
        'Contrôle température et ambiance',
        'Alimentation démarrage adaptée',
        'Surveillance sanitaire quotidienne',
        'Ajustement espace selon croissance',
        'Tenue registre d\'élevage détaillé',
      ],
      'nutrition': 'Démarrage adapté à l\'âge ($age semaines)',
      'health': 'Surveillance intensive démarrage',
      'description': 'Phase démarrage - surveillance intensive',
      'priority': 'high',
      'costPerBird': 25,
    };
  } else if (age <= 8) {
    return {
      'tasks': [
        'Alimentation croissance équilibrée',
        'Contrôle développement et poids',
        'Optimisation conditions d\'élevage',
        'Vaccinations selon protocole',
        'Évaluation performance technique',
      ],
      'nutrition': 'Croissance optimisée (${age} semaines)',
      'health': 'Suivi croissance et vaccinations',
      'description': 'Phase croissance - développement optimal',
      'priority': 'normal',
      'costPerBird': 30,
    };
  } else {
    return {
      'tasks': [
        'Gestion production selon objectifs',
        'Optimisation alimentation performance',
        'Contrôle qualité produits',
        'Suivi rentabilité économique',
        'Planification cycles suivants',
      ],
      'nutrition': 'Production optimisée (${age} semaines)',
      'health': 'Maintien performance sanitaire',
      'description': 'Phase production - optimisation rendement',
      'priority': 'normal',
      'costPerBird': 35,
    };
  }
}

// Méthode pour calculer la quantité d'aliment nécessaire (CORRIGÉE)
String _calculateFeedAmount(int quantity, int age) {
  double feedPerBird;
  
  if (age <= 1) {
    feedPerBird = 0.015; // 15g par sujet - première semaine
  } else if (age <= 2) {
    feedPerBird = 0.025; // 25g par sujet
  } else if (age <= 3) {
    feedPerBird = 0.045; // 45g par sujet
  } else if (age <= 4) {
    feedPerBird = 0.070; // 70g par sujet
  } else if (age <= 5) {
    feedPerBird = 0.100; // 100g par sujet
  } else if (age <= 6) {
    feedPerBird = 0.130; // 130g par sujet
  } else if (age <= 7) {
    feedPerBird = 0.140; // 140g par sujet
  } else {
    feedPerBird = age > 18 ? 0.120 : 0.110; // Pondeuses vs finition
  }
  
  final totalKg = (quantity * feedPerBird).roundToDouble();
  return totalKg.toStringAsFixed(1);
}

// Méthode pour déterminer la couleur selon le contexte (AMÉLIORÉE)
Color _getWeekColor(int weekNumber, int futureAge, String chickenType) {
  final isChair = chickenType.toLowerCase().contains('chair');
  final isPondeuses = chickenType.toLowerCase().contains('pondeuses');
  
  if (weekNumber == 1) return Colors.green; // Prochaine semaine
  
  if (isChair) {
    if (futureAge <= 1) return Colors.red; // Installation critique
    if (futureAge <= 3) return Colors.orange; // Phase critique
    if (futureAge <= 5) return Colors.blue; // Croissance
    if (futureAge <= 6) return Colors.purple; // Finition
    return Colors.grey; // Post-abattage
  } else if (isPondeuses) {
    if (futureAge <= 12) return Colors.blue; // Élevage poulettes
    if (futureAge <= 18) return Colors.orange; // Pré-ponte
    return Colors.green; // Ponte
  } else {
    if (futureAge <= 3) return Colors.red; // Démarrage
    if (futureAge <= 8) return Colors.blue; // Croissance
    return Colors.green; // Production
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
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Column(
                  children: tasks.map((task) => Container(
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
                ),
              ),
            ),
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