import 'package:flutter/material.dart';
import 'package:tawakad_app/features/onboarding/ui/pages/splash_page.dart';
import 'package:tawakad_app/features/onboarding/ui/pages/onboarding_questions/onboarding_questions_page.dart';
import '../features/signUp/ui/pages/signUp_page.dart';
import '../features/signUp/ui/pages/verify_email_page.dart';
import '../features/signIn/ui/pages/sign_in_page.dart';
import '../features/signIn/ui/pages/forgot_password_page.dart';
import 'package:tawakad_app/features/home/ui/pages/home_page.dart';
import 'package:tawakad_app/core/app_shell.dart';

class AppRoutes {
  static const onboarding = '/';
  static const signup = '/signup';
  static const verifyEmail = '/verify-email';
  static const signIn = '/signin';
  static const forgotPassword = '/forgot-password';
  static const splashScreen = '/splash';
  static const homePage = '/home';
  static const appShell = '/app-shell';

  static final routes = <String, WidgetBuilder>{
    onboarding: (_) => const OnboardingQuestionsPage(),
    signup: (_) => const SingupPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    signIn: (_) => const SignInPage(),
    forgotPassword: (_) => const ForgotPasswordPage(),
    splashScreen: (_) => const SplashPage(),
    homePage: (_) => const HomePage(),
    appShell: (_) => const AppShell(),
  };
}
