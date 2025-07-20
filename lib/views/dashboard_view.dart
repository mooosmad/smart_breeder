import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartBreeder'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Get.toNamed('/notifications'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cards statistiques
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Animaux',
                      '1,250',
                      Icons.pets,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Alertes',
                      '3',
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Vaccinations',
                      '12',
                      Icons.medical_services,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Dépenses',
                      '45,000 F',
                      Icons.money_sharp,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Actions rapides
              Text(
                'Actions Rapides',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    'Chat IA',
                    Icons.chat,
                    Colors.teal,
                    () => Get.toNamed('/chat'),
                  ),
                  _buildActionCard(
                    'Plannings',
                    Icons.analytics,
                    Colors.orange,
                    () => Get.toNamed('/analytics'),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Section Plannings Récents
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Plannings Récents',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/analytics'),
                    child: Text(
                      'Voir tout',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPlanningCard(
                'Planning Poulets de Chair - Lot A',
                '500 sujets - Semaine 8',
                'Vaccination prévue dans 2 jours',
                Icons.schedule,
                Colors.green,
              ),
              _buildPlanningCard(
                'Planning Poules Pondeuses - Bât B',
                '300 poules - Ponte active',
                'Contrôle sanitaire prévu',
                Icons.egg,
                Colors.orange,
              ),
              
              const SizedBox(height: 24),
              
              // Prochaines tâches
              Text(
                'Prochaines Tâches',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTaskCard('Vaccination - Lot A', '2 jours', Icons.medical_services),
              _buildTaskCard('Pesée - Poulets', '5 jours', Icons.monitor_weight),
              _buildTaskCard('Contrôle sanitaire', '1 semaine', Icons.health_and_safety),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningCard(String title, String subtitle, String status, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String title, String delay, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Dans $delay',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}