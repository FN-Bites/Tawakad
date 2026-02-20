import 'package:flutter/material.dart';
import '../features/onboarding/ui/pages/onboarding_page.dart';
import '../features/signUp/ui/pages/signUp_page.dart';
import '../features/signUp/ui/pages/verify_email_page.dart';
import '../features/signUp/ui/pages/email_verified_success_page.dart';

class AppRoutes {
  static const onboarding = '/';
  static const signup = '/signup';

  static const verifyEmail = '/verify-email';
  static const emailVerifiedSuccess = '/email-verified-success';

  static final routes = <String, WidgetBuilder>{
    onboarding: (_) => const OnboardingPage(),
    signup: (_) => const SingupPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    emailVerifiedSuccess: (_) => const EmailVerifiedSuccessPage(),
  };
}
