import 'package:flutter/material.dart';
// -----------------------------------------------------------------------------
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth/email_auth_service.dart';
import '../../../core/services/auth/google_auth_service.dart';
import '../../../core/services/user_service.dart';
// -----------------------------------------------------------------------------

class SignupFlowProvider extends ChangeNotifier {
// -----------------------------------------------------------------------------
  final EmailAuthService _emailAuthService = EmailAuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final UserService _userService = UserService();
// -----------------------------------------------------------------------------

  // ---------- Controllers ----------
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ---------- Internal state ----------
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  bool _emailSubmitAttempted = false;
  bool _passwordSubmitAttempted = false;
  bool _confirmPasswordSubmitAttempted = false;

  // ---------- Password strength ----------
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasMinLength = false;
  bool _hasSpecialChar = false;

// -----------------------------------------------------------------------------
  bool _isLoading = false;
  String? _registrationError;
  bool get isLoading => _isLoading;
  String? get registrationError => _registrationError;
// -----------------------------------------------------------------------------

  // ---------- Getters ----------
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;

  String? get emailError {
    if (!_emailSubmitAttempted) return null;
    if (_email.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
    if (!_validateEmail(_email)) return 'البريد الإلكتروني غير صالح';
// -----------------------------------------------------------------------------
    if (_registrationError != null) return _registrationError;
// -----------------------------------------------------------------------------
    return null;
  }

  String? get passwordError {
    if (!_passwordSubmitAttempted) return null;
    if (_password.isEmpty) return 'يرجى إدخال كلمة المرور';
    if (!_validatePassword(_password)) return 'كلمة المرور لا تتوافق مع الشروط';
    return null;
  }

  String? get confirmPasswordError {
    if (!_confirmPasswordSubmitAttempted) return null;
    if (_confirmPassword.isEmpty) return 'يرجى إدخال تأكيد كلمة المرور';
    if (_confirmPassword != _password)
      return 'كلمة المرور وتأكيدها غير متطابقة';
    return null;
  }

  bool get hasUppercase => _hasUppercase;
  bool get hasLowercase => _hasLowercase;
  bool get hasNumber => _hasNumber;
  bool get hasMinLength => _hasMinLength;
  bool get hasSpecialChar => _hasSpecialChar;

  bool get emailInvalid =>
      _emailSubmitAttempted &&
      (_email.isEmpty || !_validateEmail(_email) || _registrationError != null);
  bool get passwordInvalid =>
      _passwordSubmitAttempted &&
      (_password.isEmpty || !_validatePassword(_password));
  bool get confirmPasswordInvalid =>
      _confirmPasswordSubmitAttempted &&
      (_confirmPassword != _password || _confirmPassword.isEmpty);

  // ---------- Setters ----------
  void setEmail(String value) {
    _email = value.trim();
// -----------------------------------------------------------------------------
    _registrationError = null;
// -----------------------------------------------------------------------------
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _updatePasswordStrength(value);
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  void _updatePasswordStrength(String password) {
    _hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    _hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    _hasNumber = RegExp(r'[0-9]').hasMatch(password);
    _hasMinLength = password.length >= 8;
    _hasSpecialChar = RegExp(r'[^\w\s]').hasMatch(password);
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _validatePassword(String password) {
    return _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasMinLength &&
        _hasSpecialChar;
  }

  // ---------- Submit ----------
// -----------------------------------------------------------------------------
  Future<bool> signUpWithEmail(List<String> onboardingAnswers) async {
    _registrationError = null;

    _emailSubmitAttempted = true;
    _passwordSubmitAttempted = true;
    _confirmPasswordSubmitAttempted = true;

    _email = emailController.text.trim();
    _password = passwordController.text;
    _confirmPassword = confirmPasswordController.text;

    _updatePasswordStrength(_password);
    notifyListeners();

    if (emailInvalid || passwordInvalid || confirmPasswordInvalid) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _emailAuthService.signUpWithEmail(
        email: _email,
        password: _password,
      );

      await _userService.saveUserData(
        user: user,
        password: _password,
        answers: onboardingAnswers,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        _registrationError = 'البريد الإلكتروني مسجل مسبقًا. قم بتسجيل الدخول';
      } else {
        _registrationError = 'حدث خطأ أثناء التسجيل، حاول مرة أخرى';
      }
      return false;
    } catch (_) {
      _registrationError ??= 'حدث خطأ غير متوقع ';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
  Future<bool> signInWithGoogle(List<String> onboardingAnswers) async {
    _registrationError = null;
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _googleAuthService.signInWithGoogle();

      await _userService.saveUserData(
        user: user,
        password: _password,
        answers: onboardingAnswers,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _registrationError =
            'هذا البريد مسجل بطريقة مختلفة، قم بالتسجيل المناسب';
      } else if (e.code == 'sign-in-cancelled') {
        return false;
      } else {
        _registrationError = 'فشل التسجيل باستخدام Google';
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
    _confirmPassword = '';

    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    _emailSubmitAttempted = false;
    _passwordSubmitAttempted = false;
    _confirmPasswordSubmitAttempted = false;

    _hasUppercase = false;
    _hasLowercase = false;
    _hasNumber = false;
    _hasMinLength = false;
    _hasSpecialChar = false;

// -----------------------------------------------------------------------------
    _registrationError = null;
// -----------------------------------------------------------------------------

    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
