// main_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_breeder/controllers/navigation_controller.dart';
import 'package:smart_breeder/views/dashboard_view.dart';
import 'package:smart_breeder/views/marketplace_view.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.put(
      NavigationController(),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Obx(() {
        switch (navigationController.currentIndex.value) {
          case 0:
            return DashboardView();
          case 1:
            return const MarketplaceView();
          default:
            return DashboardView();
        }
      }),
            floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/generate-planning'),
        backgroundColor: Colors.green[700],
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text(
          'Générer Planning',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: navigationController.currentIndex.value,
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey,
          onTap: (index) => navigationController.changePage(index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront),
              label: 'Marketplace',
            ),
          ],
        ),
      ),
    );
  }
}
