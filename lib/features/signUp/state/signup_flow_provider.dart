import 'package:flutter/material.dart';

class SignupFlowProvider extends ChangeNotifier {
  SignupFlowProvider({required int totalSteps}) : _totalSteps = totalSteps;

  final int _totalSteps;
  int _currentStep = 1;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // State variables
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  // Validation flags
  bool _emailSubmitAttempted = false;
  bool _passwordSubmitAttempted = false;
  bool _confirmPasswordSubmitAttempted = false;

  // Password strength indicators
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasMinLength = false;
  bool _hasSpecialChar = false;

  int get totalSteps => _totalSteps;
  int get currentStep => _currentStep;

  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;

  // Error getters
  String? get emailError => _emailSubmitAttempted && _validateEmail(_email)
      ? null
      : (_emailSubmitAttempted && _email.trim().isEmpty
          ? 'البريد الإلكتروني مطلوب'
          : null);

  String? get passwordError =>
      _passwordSubmitAttempted && !_validatePassword(_password)
          ? '  كلمة المرور يجب أن تتبع الشروط المذكوره'
          : null;

  String? get confirmPasswordError => _confirmPasswordSubmitAttempted &&
          (_confirmPassword != _password || _confirmPassword.isEmpty)
      ? 'كلمة المرور غير متطابقة'
      : null;

  // Password strength getters
  bool get hasUppercase => _hasUppercase;
  bool get hasLowercase => _hasLowercase;
  bool get hasNumber => _hasNumber;
  bool get hasMinLength => _hasMinLength;
  bool get hasSpecialChar => _hasSpecialChar;

  bool get emailInvalid =>
      _emailSubmitAttempted &&
      (_email.trim().isEmpty || !_validateEmail(_email));
  bool get passwordInvalid =>
      _passwordSubmitAttempted && !_validatePassword(_password);
  bool get confirmPasswordInvalid =>
      _confirmPasswordSubmitAttempted &&
      (_confirmPassword != _password || _confirmPassword.isEmpty);

  void setEmail(String value) {
    _email = value;
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
    _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
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

  void submitRegisterStep() {
    _emailSubmitAttempted = true;
    _passwordSubmitAttempted = true;
    _confirmPasswordSubmitAttempted = true;

    _email = emailController.text.trim();
    _password = passwordController.text;
    _confirmPassword = confirmPasswordController.text;

    _updatePasswordStrength(_password);

    notifyListeners();

    if (emailInvalid || passwordInvalid || confirmPasswordInvalid) return;

    _goToStep(_currentStep + 1);
  }

  void nextFromEmailStep() {
    _emailSubmitAttempted = true;
    notifyListeners();

    if (emailInvalid) return;

    _goToStep(_currentStep + 1);
  }

  void nextFromPasswordStep() {
    _passwordSubmitAttempted = true;
    notifyListeners();

    if (passwordInvalid) return;

    _goToStep(_currentStep + 1);
  }

  void back() {
    if (_currentStep <= 1) return;
    _goToStep(_currentStep - 1);
  }

  void _goToStep(int step) {
    final clamped = step.clamp(1, _totalSteps);
    if (clamped == _currentStep) return;

    _currentStep = clamped;
    notifyListeners();
  }

  void reset() {
    _currentStep = 1;
    _email = '';
    _password = '';
    _confirmPassword = '';

    emailController.text = '';
    passwordController.text = '';
    confirmPasswordController.text = '';

    _emailSubmitAttempted = false;
    _passwordSubmitAttempted = false;
    _confirmPasswordSubmitAttempted = false;

    _hasUppercase = false;
    _hasLowercase = false;
    _hasNumber = false;
    _hasMinLength = false;
    _hasSpecialChar = false;

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
