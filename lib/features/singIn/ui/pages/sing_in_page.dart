import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/features/singIn/ui/widgets/sing_in_content.dart';
import 'package:tawakad_app/features/singIn/ui/widgets/sing_in_scaffold.dart';
import '../../state/signIn_flow_provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<SignInFlowProvider>();

    return SignInScaffold(
      onBack: () => Navigator.maybePop(context),

      title: 'تسجيل الدخول',

      forgotPasswordText: 'هل نسيت كلمة المرور؟',
      onForgotPasswordPressed: () => Navigator.pushReplacementNamed(context, '/forget-password'),

      primaryButtonText: 'تسجيل الدخول',
      onPrimaryPressed: flow.isLoading
          ? null
          : () async {
              final success = await flow.signInWithEmail();
              if (success && context.mounted) {
                Navigator.pushReplacementNamed(context, '/auth-success');
              }
            },

      onGooglePressed: flow.isLoading
          ? null
          : () async {
              final success = await flow.signInWithGoogle();
              if (success && context.mounted) {
                Navigator.pushReplacementNamed(context, '/auth-success');
              }
            },

      bottomPrefixText: 'ليس لديك حساب؟ ',
      bottomActionText: 'قم بإنشاء حساب جديد',
      onBottomActionPressed: () => Navigator.pushReplacementNamed(context, '/'),

      child: SignInContent(
        emailController: flow.emailController, 
        passwordController: flow.passwordController, 
        emailError: flow.emailError, 
        passwordError: flow.passwordError, 
        emailServerError: flow.emailServerError, 
        passwordServerError: flow.passwordServerError,
        onEmailChanged: flow.setEmail, 
        onPasswordChanged: flow.setPassword, 
      ),    
    );
  }
}
