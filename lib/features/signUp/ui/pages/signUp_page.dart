import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/Sign.dart';
import '../../state/signup_flow_provider.dart';

class SingupPage extends StatelessWidget {
  const SingupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<SignupFlowProvider>();

    return AuthScaffold(
      currentStep: 3,
      totalSteps: 5,
      title: 'إنشاء حساب جديد',
      primaryButtonText: 'إنشاء حساب',
      onPrimaryPressed: flow.submitRegisterStep,
      bottomPrefixText: 'لديك حساب؟ ',
      bottomActionText: 'قم بتسجيل الدخول',

      child: RegisterStepContent(
        emailController: flow.emailController,
        passwordController: flow.passwordController,
        confirmPasswordController: flow.confirmPasswordController,
        emailError: flow.emailError,
        passwordError: flow.passwordError,
        confirmPasswordError: flow.confirmPasswordError,
        onEmailChanged: flow.setEmail,
        onPasswordChanged: flow.setPassword,
        onConfirmPasswordChanged: flow.setConfirmPassword,
        hasUppercase: flow.hasUppercase,
        hasLowercase: flow.hasLowercase,
        hasNumber: flow.hasNumber,
        hasMinLength: flow.hasMinLength,
        hasSpecialChar: flow.hasSpecialChar,
      ),
      //onBottomActionPressed: flow.goToLogin,
    );
  }
}
