import 'package:flutter/material.dart';
// -----------------------------------------------------------------------------
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth/email_auth_service.dart';
import '../../../core/services/auth/google_auth_service.dart';
// -----------------------------------------------------------------------------

class SignInFlowProvider extends ChangeNotifier {
// -----------------------------------------------------------------------------
  final EmailAuthService _emailAuthService = EmailAuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
// -----------------------------------------------------------------------------

  // ---------- Controllers ----------
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ---------- Internal state ----------
  String _email = '';
  String _password = '';

  bool _emailSubmitAttempted = false;
  bool _passwordSubmitAttempted = false;

// -----------------------------------------------------------------------------
  bool _isLoading = false; // حالة الزر
  // ---------- Server-side error ----------
  String? _emailServerError;
  String? _passwordServerError;
// -----------------------------------------------------------------------------

  // ---------- Getters ----------
  String get email => _email;
  String get password => _password;
// -----------------------------------------------------------------------------
  String? get emailServerError => _emailServerError;
  String? get passwordServerError => _passwordServerError;
  bool get isLoading => _isLoading;
// -----------------------------------------------------------------------------

  // ---------- Validation Getters ----------
  String? get emailError {
    if (!_emailSubmitAttempted) return null;
    if (_email.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
    if (!_validateEmail(_email)) return 'البريد الإلكتروني غير صالح';
// -----------------------------------------------------------------------------
    if (_emailServerError != null) return _emailServerError;
// -----------------------------------------------------------------------------
    return null;
  }

  String? get passwordError {
    if (!_passwordSubmitAttempted) return null;
    if (_password.isEmpty) return 'يرجى إدخال كلمة المرور';
// -----------------------------------------------------------------------------
    if (_passwordServerError != null) return _passwordServerError;
// -----------------------------------------------------------------------------
    return null;
  }
// -----------------------------------------------------------------------------
  bool get emailInvalid => _emailSubmitAttempted && (_email.isEmpty || !_validateEmail(_email) || _emailServerError != null);
  bool get passwordInvalid => _passwordSubmitAttempted && (_password.isEmpty || _passwordServerError != null);
// -----------------------------------------------------------------------------
  // ---------- Setters ----------
  void setEmail(String value) {
    _email = value.trim();
// -----------------------------------------------------------------------------
    _emailServerError = null;
// -----------------------------------------------------------------------------
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
// -----------------------------------------------------------------------------
    _passwordServerError = null;
// -----------------------------------------------------------------------------
    notifyListeners();
  }

  // ---------- Validation ----------
  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // ---------- Submit ----------
// -----------------------------------------------------------------------------
  Future<bool> signInWithEmail() async {
    _emailSubmitAttempted = true;
    _passwordSubmitAttempted = true;

    _email = emailController.text.trim();
    _password = passwordController.text;

    _emailServerError = null;
    _passwordServerError = null;

    notifyListeners();

    if (emailInvalid || passwordInvalid) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _emailAuthService.signInWithEmail(
        email: _email,
        password: _password,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _emailServerError = 'البريد الإلكتروني غير مسجل';
      } else if (e.code == 'wrong-password') {
        _passwordServerError = 'كلمة المرور غير صحيحة';
      } else if (e.code == 'invalid-credential') {
        _passwordServerError = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else if (e.code == 'email-not-verified') {
        _emailServerError = 'يرجى التحقق من بريدك الإلكتروني والنقر على رابط التفعيل';
      } else {
        _passwordServerError = 'حدث خطأ أثناء تسجيل الدخول، حاول مرة أخرى';
      }
      return false;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
  Future<bool> signInWithGoogle() async {
    _emailServerError = null;
    _passwordServerError = null;
    _isLoading = true;

    notifyListeners();

    try {
      await _googleAuthService.signInWithGoogle();

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _emailServerError = 'هذا البريد مسجل بطريقة مختلفة، قم بتسجيل الدخول المناسب';
      } else if (e.code == 'sign-in-cancelled') {
        return false;
      } else {
        _passwordServerError = 'فشل تسجيل الدخول باستخدام Google';
      }
      return false;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
// -----------------------------------------------------------------------------

  // ---------- Reset ----------
  void reset() {
    _email = '';
    _password = '';
// -----------------------------------------------------------------------------
    _emailServerError = null;
    _passwordServerError = null;
// -----------------------------------------------------------------------------
    emailController.clear();
    passwordController.clear();

    _emailSubmitAttempted = false;
    _passwordSubmitAttempted = false;

    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
