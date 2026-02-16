import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes.dart';
import 'features/onboarding/state/onboarding_flow_provider.dart';
import 'features/singUp/state/singup_flow_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OnboardingFlowProvider(totalSteps: 4),
        ),
        ChangeNotifierProvider(
          create: (_) => SignupFlowProvider(totalSteps: 3),
        ),
      ],
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
      //initialRoute: AppRoutes.onboarding,
      initialRoute: AppRoutes.signup,
    );
  }
}
