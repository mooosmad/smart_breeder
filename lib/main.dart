import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_breeder/core/theme/app_theme.dart';
import 'package:smart_breeder/core/routes/app_routes.dart';
import 'package:smart_breeder/core/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SmartBreederApp());
}

class SmartBreederApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SmartBreeder',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('fr', 'FR'),
    );
  }
}