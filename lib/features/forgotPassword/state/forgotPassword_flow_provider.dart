import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordFlowProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  String _email = '';
  bool _emailSubmitAttempted = false;

  bool _isLoading = false;
  String? _serverError;

  bool _isButtonEnabled = true;
  int _resendSeconds = 30;
  Timer? _timer;

  String get email => _email;
  String? get serverError => _serverError;
  bool get isLoading => _isLoading;
  bool get isButtonEnabled => _isButtonEnabled;
  int get resendSeconds => _resendSeconds;

  String? get emailError {
    if (!_emailSubmitAttempted) return null;
    if (_email.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
    if (!_validateEmail(_email)) return 'صيغة البريد الإلكتروني غير صحيحة';
    if (_serverError != null) return _serverError;
    return null;
  }

  bool get emailInvalid => _emailSubmitAttempted && (_email.isEmpty || !_validateEmail(_email) || _serverError != null);

  void setEmail(String value) {
    _email = value.trim();
    _serverError = null;
    notifyListeners();
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<bool> sendPasswordResetEmail() async {
    _emailSubmitAttempted = true;
    _email = emailController.text.trim();

    _serverError = null;
    notifyListeners();

    if (emailInvalid) return false;

    _isLoading = true;
    notifyListeners();

    try {
      
      await _auth.sendPasswordResetEmail(
        email: _email,
      );

      _startResendTimer();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _serverError = 'هذا البريد الإلكتروني غير مسجل مسبقا';
      } else {
        _serverError = 'تعذر إرسال البريد حالياً، حاول مرة أخرى';
      }
      return false;
    } catch (e) {
      _serverError = 'حدث خطأ غير متوقع';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startResendTimer() {
    _isButtonEnabled = false;
    _resendSeconds = 30;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        _isButtonEnabled = true;
        timer.cancel();
        notifyListeners();
      } else {
        _resendSeconds--;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
