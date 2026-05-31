import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tawakad_app/firebase_options.dart';
import 'package:tawakad_app/features/signUp/providers/signup_flow_provider.dart';
import 'package:tawakad_app/features/signIn/providers/signIn_flow_provider.dart';
import 'package:tawakad_app/features/signIn/providers/forgotPassword_flow_provider.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  test('Authentication flow blocks unverified sign in', () async {
    final email = 'test_${DateTime.now().millisecondsSinceEpoch}@gmail.com';

    const password = 'Test@123';

    try {
      // =========================
      // Sign Up
      // =========================

      final signupProvider = SignupFlowProvider();

      signupProvider.emailController.text = email;
      signupProvider.passwordController.text = password;
      signupProvider.confirmPasswordController.text = password;

      final signUpResult = await signupProvider.signUpWithEmail([
        'Nujood',
        'Mohammed',
        'Female',
        'Student',
        'No',
      ]);

      print('signUpResult = $signUpResult');

      expect(signUpResult, true);

      // =========================
      // Forgot Password
      // =========================

      final forgotProvider = ForgotPasswordFlowProvider();

      forgotProvider.emailController.text = email;

      final forgotResult = await forgotProvider.sendPasswordResetEmail();

      print('forgotResult = $forgotResult');

      expect(forgotResult, true);

      // =========================
      // Sign Out
      // =========================

      await FirebaseAuth.instance.signOut();

      // =========================
      // Sign In
      // =========================

      final signInProvider = SignInFlowProvider();

      signInProvider.emailController.text = email;
      signInProvider.passwordController.text = password;

      final signInResult = await signInProvider.signInWithEmail();

      print('signInResult = $signInResult');
      print('emailServerError = ${signInProvider.emailServerError}');
      print('passwordServerError = ${signInProvider.passwordServerError}');

      expect(signInResult, false);
      expect(signInProvider.emailServerError, isNotNull);
      expect(signInProvider.passwordServerError, isNull);
    } finally {
      // =========================
      // Cleanup
      // =========================

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await currentUser.delete();
      }
    }
  });
}
