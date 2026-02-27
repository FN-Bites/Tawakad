import 'package:flutter/material.dart';
import '../ui/pages/forget_the_password.dart';
import '../ui/pages/create_new_password.dart';

class SignInFlowProvider extends ChangeNotifier {
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

  bool _isButtonEnabled = true; // حالة الزر

  // ---------- Server-side error ----------
  String? _serverError;

  // ---------- Getters ----------
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String? get serverError => _serverError;
  bool get isButtonEnabled => _isButtonEnabled;

  // ---------- Password strength ----------
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasMinLength = false;
  bool _hasSpecialChar = false;

  // ---------- Validation Getters ----------
  String? get emailError {
    if (!_emailSubmitAttempted) return null;
    if (_email.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!_validateEmail(_email)) return 'البريد الإلكتروني غير صالح';
    return null;
  }

  String? get passwordError {
    if (!_passwordSubmitAttempted) return null;
    if (_password.isEmpty) return 'كلمة المرور مطلوبة';
    return null;
  }

  String? get confirmPasswordError {
    if (!_confirmPasswordSubmitAttempted) return null;
    if (_confirmPassword.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (_confirmPassword != _password) return 'كلمة المرور غير متطابقة';
    return null;
  }

// ---------- Getters for password strength ----------
  bool get hasUppercase => _hasUppercase;
  bool get hasLowercase => _hasLowercase;
  bool get hasNumber => _hasNumber;
  bool get hasMinLength => _hasMinLength;
  bool get hasSpecialChar => _hasSpecialChar;

  bool get emailInvalid =>
      _emailSubmitAttempted && (_email.isEmpty || !_validateEmail(_email));
  bool get passwordInvalid => _passwordSubmitAttempted && _password.isEmpty;
  bool get confirmPasswordInvalid =>
      _confirmPasswordSubmitAttempted &&
      (_confirmPassword.isEmpty || _confirmPassword != _password);

  // ---------- Setters ----------
  void setEmail(String value) {
    _email = value.trim();
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

  void clearServerError() {
    _serverError = null;
    notifyListeners();
  }

  void _updatePasswordStrength(String password) {
    _hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    _hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    _hasNumber = RegExp(r'[0-9]').hasMatch(password);
    _hasMinLength = password.length >= 8;
    _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>-_]').hasMatch(password);
  }

  // ---------- Validation ----------
  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isTestMode = true;
  // ---------- Submit ----------
  void submit(BuildContext context) {
    if (!_isButtonEnabled) return;

    _isButtonEnabled = false;
    _emailSubmitAttempted = true;
    _passwordSubmitAttempted = true;
    _confirmPasswordSubmitAttempted = true;
    _serverError = null;

    _email = emailController.text.trim();
    _password = passwordController.text;
    _confirmPassword = confirmPasswordController.text;
    notifyListeners();

    // تحقق من صحة الحقول
    if (emailInvalid || passwordInvalid || confirmPasswordInvalid) {
      Future.delayed(const Duration(seconds: 30), () {
        _isButtonEnabled = true;
        notifyListeners();
      });
      return;
    }

    if (isTestMode) {
      const testEmail = 'test@example.com';
      const testPassword = '123456';

      if (_email != testEmail) {
        _serverError = 'البريد الإلكتروني غير مسجل';
      } else if (_password != testPassword) {
        _serverError = 'كلمة السر غير صحيحة';
      } else {
        print("نسخة تجريبية: الانتقال مباشرة لصفحة إعادة التعيين");

        // ✅ هنا استخدام context الممرر من Widget
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => const CreateNewPasswordPage(),
          ),
        );
      }
    } else {
      // نسخة Firebase لاحقًا
    }

    Future.delayed(const Duration(seconds: 30), () {
      _isButtonEnabled = true;
      notifyListeners();
    });

    notifyListeners();
  }

  // ---------- Reset ----------
  void reset() {
    _email = '';
    _password = '';
    _confirmPassword = '';
    _serverError = null;

    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    _emailSubmitAttempted = false;
    _passwordSubmitAttempted = false;
    _confirmPasswordSubmitAttempted = false;

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
