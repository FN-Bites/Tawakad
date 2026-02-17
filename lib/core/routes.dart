import 'package:flutter/material.dart';
import '../features/onboarding/ui/pages/onboarding_page.dart';
import '../features/signUp/ui/pages/signUp_page.dart';

class AppRoutes {
  static const onboarding = '/';
  static const signup = '/signup';

  static final routes = <String, WidgetBuilder>{
    onboarding: (_) => const OnboardingPage(),
    signup: (_) => const SingupPage(),
  };
}
