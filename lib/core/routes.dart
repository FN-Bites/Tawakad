import 'package:flutter/material.dart';
import '../features/onboarding/ui/pages/onboarding_page.dart';

class AppRoutes {
  static const onboarding = '/';

  static final routes = <String, WidgetBuilder>{
    onboarding: (_) => const OnboardingPage(),
  };
}
