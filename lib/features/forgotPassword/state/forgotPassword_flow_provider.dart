import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordFlowProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();

  bool emailInvalid = false;
  String? emailError;
  String? serverError;

  bool isLoading = false;

  bool isButtonEnabled = true;
  int resendSeconds = 30;
  Timer? _timer;

  void setEmail(String value) {
    emailInvalid = false;
    emailError = null;
    serverError = null;
    notifyListeners();
  }

  bool validateEmail() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      emailInvalid = true;
      emailError = 'يرجى إدخال البريد الإلكتروني';
      notifyListeners();
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      emailInvalid = true;
      emailError = 'البريد الإلكتروني غير صالح';
      notifyListeners();
      return false;
    }

    return true;
  }

  // إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail() async {
    serverError = null;

    if (!validateEmail()) return;

    final userEmail = emailController.text.trim();

    try {
      isLoading = true;
      notifyListeners();

      await _auth.sendPasswordResetEmail(
        email: userEmail,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://signupapp-e1252.firebaseapp.com/reset',
          handleCodeInApp: true,
          androidPackageName: 'com.example.tawakad_app',
          androidInstallApp: true,
        ),
      );

      isLoading = false;

      _startResendTimer();

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      isLoading = false;

      if (e.code == 'user-not-found') {
        emailInvalid = true;
        serverError = 'هذا البريد الإلكتروني غير مسجل مسبقا';
      } else {
        serverError = 'تعذر إرسال البريد حالياً، حاول مرة أخرى';
      }

      notifyListeners();
    } catch (e) {
      isLoading = false;
      serverError = 'حدث خطأ غير متوقع';

      notifyListeners();
    }
  }

  // مؤقت إعادة الإرسال
  void _startResendTimer() {
    isButtonEnabled = false;
    resendSeconds = 30;

    notifyListeners();

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      resendSeconds--;

      if (resendSeconds <= 0) {
        isButtonEnabled = true;

        timer.cancel();
      }

      notifyListeners();
    });
  }

  // تنظيف الموارد
  @override
  void dispose() {
    emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
