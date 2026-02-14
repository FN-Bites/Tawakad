import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes.dart';
import 'features/onboarding/state/onboarding_flow_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => OnboardingFlowProvider(totalSteps: 4),
      child: const TawakadApp(),
    ),
  );
}

class TawakadApp extends StatelessWidget {
  const TawakadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.namePage,
    );
  }
}
