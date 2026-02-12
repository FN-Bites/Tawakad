import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes.dart';

void main() {
  runApp(const TawakadApp());
}

class TawakadApp extends StatelessWidget {
  const TawakadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tawakad',

      // App theme
      theme: AppTheme.light(),

      // Global RTL
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      // Navigation system
      initialRoute: AppRoutes.authEntry,
      routes: AppRoutes.routes,
    );
  }
}
