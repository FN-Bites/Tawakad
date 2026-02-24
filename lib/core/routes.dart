import 'package:flutter/material.dart';
import '../features/onboarding/ui/pages/onboarding_page.dart';
import '../features/signUp/ui/pages/signUp_page.dart';
import '../features/signUp/ui/pages/verify_email_page.dart';
import '../features/signUp/ui/pages/email_verified_success_page.dart';
import 'package:tawakad_app/features/landing/ui/pages/splash.dart';

class AppRoutes {
  static const onboarding = '/';
  static const signup = '/signup';

  static const verifyEmail = '/verify-email';
  static const emailVerifiedSuccess = '/email-verified-success';

  static const splashScreen = '/splash';

  static final routes = <String, WidgetBuilder>{
    onboarding: (_) => const OnboardingPage(),
    signup: (_) => const SingupPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    emailVerifiedSuccess: (_) => const EmailVerifiedSuccessPage(),
    splashScreen: (_) => const Splash(),
  };
}
