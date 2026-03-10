import 'package:flutter/material.dart';
import '../features/signUp/ui/pages/signUp_page.dart';
import '../features/verifyEmail/ui/pages/verify_email_page.dart';
import '../features/verifyEmail/ui/pages/email_verified_success_page.dart';
import '../features/singIn/ui/pages/sing_in_page.dart';
import '../features/forgotPassword/ui/pages/forgot_password_page.dart';
import '../features/createNewPassword/ui/pages/create_new_password_page.dart';
import 'package:tawakad_app/features/onboarding/ui/pages/splash_page.dart';
import 'package:tawakad_app/features/onboarding/ui/pages/onboarding_questions/onboarding_questions_page.dart';
// -----------------------------------------------------------------------------
import 'package:tawakad_app/features/singIn/ui/pages/auth_success_page.dart';
// -----------------------------------------------------------------------------

class AppRoutes {
  static const onboarding = '/';
  static const signup = '/signup';
  static const verifyEmail = '/verify-email';
  static const emailVerifiedSuccess = '/email-verified-success';
  static const signIn = '/signin';
  static const forgetPassword = '/forget-password';
  static const createNewPassword = '/create-new-password';
  static const splashScreen = '/splash';
// -----------------------------------------------------------------------------
  static const authSuccess = '/auth-success';
// -----------------------------------------------------------------------------

  static final routes = <String, WidgetBuilder>{
    onboarding: (_) => const OnboardingQuestionsPage(),
    signup: (_) => const SingupPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    emailVerifiedSuccess: (_) => const EmailVerifiedSuccessPage(),
    signIn: (_) => const SignInPage(),
    forgetPassword: (_) => const ForgetPasswordPage(),
    createNewPassword: (_) => const CreateNewPasswordPage(),
    splashScreen: (_) => const SplashPage(),
// -----------------------------------------------------------------------------
    authSuccess: (_) => const AuthSuccessPage(),
// -----------------------------------------------------------------------------
  };
}
