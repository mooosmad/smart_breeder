// lib/views/analytics_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_breeder/controllers/anilytics_controller.dart';


class AnalyticsView extends StatelessWidget {
  final AnalyticsController controller = Get.find();

  AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats cards
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Animaux', '${controller.totalAnimals.value}', Icons.pets, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Coût Mensuel', '${controller.totalCost.value.toStringAsFixed(0)} F', Icons.attach_money, Colors.green)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Vaccinations', '${controller.scheduledVaccinations.value}', Icons.medical_services, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Alertes', '${controller.healthAlerts.value}', Icons.warning, Colors.red)),
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
                        'Évolution des Coûts',
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
                                spots: controller.costData.map((point) => FlSpot(point.x, point.y)).toList(),
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
                            sections: controller.animalDistribution.entries.map((entry) {
                              return PieChartSectionData(
                                value: entry.value.toDouble(),
                                title: '${entry.key}\n${entry.value}',
                                color: _getColorForAnimalType(entry.key),
                                radius: 80,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        
              const SizedBox(height: 24),
        
              // Prochaines tâches
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prochaines Tâches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...controller.upcomingTasks.map((task) => _buildTaskTile(task)).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
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

  Widget _buildTaskTile(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: _getPriorityColor(task['priority']), width: 4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getTaskIcon(task['type']),
            color: _getPriorityColor(task['priority']),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  task['description'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            task['dueDate'],
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static Color _getColorForAnimalType(String type) {
    switch (type.toLowerCase()) {
      case 'poulets':
        return Colors.orange;
      case 'bovins':
        return Colors.brown;
      case 'ovins':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  static Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'haute':
        return Colors.red;
      case 'medium':
      case 'moyenne':
        return Colors.orange;
      case 'low':
      case 'basse':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static IconData _getTaskIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.medical_services;
      case 'alimentation':
        return Icons.restaurant;
      case 'controle':
        return Icons.search;
      default:
        return Icons.task;
    }
  }
}
