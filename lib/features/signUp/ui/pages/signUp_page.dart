import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../signUp/state/signup_flow_provider.dart';
import '../../../onboarding/state/onboarding_flow_provider.dart';
import '../../../signUp/ui/widgets/sign_up_content.dart';
import '../../../signUp/ui/widgets/sign_up_scaffold.dart';

class SingupPage extends StatelessWidget {
  const SingupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<SignupFlowProvider>();
    final onboardingFlow = context.read<OnboardingFlowProvider>();

    return SignUpScaffold(
      onBack: () => Navigator.pushReplacementNamed(context, '/'),
      title: 'إنشاء حساب جديد',
      primaryButtonText: 'إنشاء حساب',
      onPrimaryPressed: flow.isLoading
          ? null
          : () async {
              final success =
                  await flow.signUpWithEmail(onboardingFlow.answers);
              if (success && context.mounted) {
                Navigator.pushReplacementNamed(context, '/verify-email');
              }
            },
      onGooglePressed: flow.isLoading
          ? null
          : () async {
              final success =
                  await flow.signInWithGoogle(onboardingFlow.answers);
              if (success && context.mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
      bottomPrefixText: 'لديك حساب؟ ',
      bottomActionText: 'قم بتسجيل الدخول',
      onBottomActionPressed: () =>
          Navigator.pushReplacementNamed(context, '/signin'),
      child: SignUpContent(
        emailController: flow.emailController,
        passwordController: flow.passwordController,
        confirmPasswordController: flow.confirmPasswordController,
        emailError: flow.emailError,
        passwordError: flow.passwordError,
        confirmPasswordError: flow.confirmPasswordError,
        registrationError: flow.registrationError,
        onEmailChanged: flow.setEmail,
        onPasswordChanged: flow.setPassword,
        onConfirmPasswordChanged: flow.setConfirmPassword,
        hasUppercase: flow.hasUppercase,
        hasLowercase: flow.hasLowercase,
        hasNumber: flow.hasNumber,
        hasMinLength: flow.hasMinLength,
        hasSpecialChar: flow.hasSpecialChar,
        isPasswordEmpty: flow.password.isEmpty,
      ),
    );
  }
}
