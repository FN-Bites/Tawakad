import 'package:flutter/material.dart';

import '../features/onboarding/ui/pages/onboarding_page.dart';
import '../features/signUp/ui/pages/signUp_page.dart';
import '../features/signUp/ui/pages/verify_email_page.dart';
import '../features/signUp/ui/pages/email_verified_success_page.dart';
import '../features/singIn/ui/pages/sing_in_page.dart';

// صفحات الاساسية بعد ربط فاير بيس )
import '../features/singIn/ui/pages/forget_the_password.dart';
import '../features/singIn/ui/pages/create_new_password.dart';

// صفحات الاختبار
import '../features/reset_password/ui/pages/test_forget_the_password_page.dart';
import '../features/reset_password/ui/pages/test_create_new_password_page.dart';

class AppRoutes {
  static const onboarding = '/';
  static const signup = '/signup';
  static const verifyEmail = '/verify-email';
  static const emailVerifiedSuccess = '/email-verified-success';
  static const signIn = '/signin';

  // الاساسية
  static const forgetPassword = '/forget-password';
  static const createNewPassword = '/create-new-password';

  // اختبار)
  static const testForgetPassword = '/test-forget-password';
  static const testCreateNewPassword = '/test-create-new-password';

  static final routes = <String, WidgetBuilder>{
    onboarding: (_) => const OnboardingPage(),
    signup: (_) => const SignupPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    emailVerifiedSuccess: (_) => const EmailVerifiedSuccessPage(),
    signIn: (_) => const SignInPage(),

    // الاساسية
    forgetPassword: (_) => const ForgetThePasswordPage(),
    createNewPassword: (_) => const CreateNewPasswordPage(),

    // اختبار
    testForgetPassword: (_) => const TestForgetThePasswordPage(),
    testCreateNewPassword: (_) => const TestCreateNewPasswordPage(),
  };
}
