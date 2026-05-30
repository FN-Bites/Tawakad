import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth/email_auth_service.dart';
import '../../../core/services/auth/google_auth_service.dart';
import '../../../core/services/auth/user_service.dart';

class SignInFlowProvider extends ChangeNotifier {
  final EmailAuthService _emailAuthService = EmailAuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final UserService _userService = UserService();

  // ---------- Controllers ----------
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ---------- Internal state ----------
  String _email = '';
  String _password = '';

  bool _emailSubmitAttempted = false;
  bool _passwordSubmitAttempted = false;

  bool _isLoading = false; // حالة الزر

  // ---------- Server-side error ----------
  String? _emailServerError;
  String? _passwordServerError;

  // ---------- Getters ----------
  String get email => _email;
  String get password => _password;
  String? get emailServerError => _emailServerError;
  String? get passwordServerError => _passwordServerError;
  bool get isLoading => _isLoading;

  // ---------- Validation Getters ----------
  String? get emailError {
    if (!_emailSubmitAttempted) return null;
    if (_email.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
    if (_emailServerError != null) return _emailServerError;
    return null;
  }

  String? get passwordError {
    if (!_passwordSubmitAttempted) return null;
    if (_password.isEmpty) return 'يرجى إدخال كلمة المرور';
    if (_passwordServerError != null) return _passwordServerError;
    return null;
  }

  bool get emailInvalid =>
      _emailSubmitAttempted && (_email.isEmpty || _emailServerError != null);
  bool get passwordInvalid =>
      _passwordSubmitAttempted &&
      (_password.isEmpty || _passwordServerError != null);

  // ---------- Setters ----------
  void setEmail(String value) {
    _email = value.trim();
    _emailServerError = null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _passwordServerError = null;
    notifyListeners();
  }

  // ---------- Submit ----------
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

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _userService.updatePasswordHistoryIfChanged(
          uid: user.uid,
          email: _email,
          currentPassword: _password,
        );
      }

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _emailServerError = 'البريد الإلكتروني غير مسجل';
      } else if (e.code == 'wrong-password') {
        _passwordServerError = 'كلمة المرور غير صحيحة';
      } else if (e.code == 'email-not-verified') {
        _emailServerError =
            'يرجى التحقق من بريدك الإلكتروني والنقر على رابط التفعيل';
      } else if (e.code == 'invalid-credential') {
        _emailServerError = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        _passwordServerError = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else {
        _emailServerError = 'حدث خطأ أثناء تسجيل الدخول، حاول مرة أخرى';
        _passwordServerError = 'حدث خطأ أثناء تسجيل الدخول، حاول مرة أخرى';
      }
      return false;
    } catch (_) {
      _emailServerError ??= 'حدث خطأ غير متوقع ';
      _passwordServerError ??= 'حدث خطأ غير متوقع ';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _emailServerError = null;
    _passwordServerError = null;

    _isLoading = true;
    notifyListeners();

    try {
      await _googleAuthService.signInWithGoogle();

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'google-signin-failed') {
        _emailServerError = 'فشل تسجيل الدخول بإستخدام Google';
        _passwordServerError = 'فشل تسجيل الدخول بإستخدام Google';
      }
      return false;
    } catch (_) {
      _emailServerError ??= 'حدث خطأ غير متوقع ';
      _passwordServerError ??= 'حدث خطأ غير متوقع ';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------- Reset ----------
  void reset() {
    _email = '';
    _password = '';

    _emailServerError = null;
    _passwordServerError = null;

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
