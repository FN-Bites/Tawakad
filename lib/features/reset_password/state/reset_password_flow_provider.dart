import 'dart:async';
import 'package:flutter/material.dart';

class ResetPasswordFlowProvider extends ChangeNotifier {
  // Controllers
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State
  bool _emailSubmitAttempted = false;
  bool _passwordSubmitAttempted = false;

  String? _serverError;

  // زر الإرسال (Cooldown)
  bool _isButtonEnabled = true;
  int _secondsRemaining = 0;
  Timer? _timer;

  bool get isButtonEnabled => _isButtonEnabled;
  int get secondsRemaining => _secondsRemaining;
  String? get serverError => _serverError;

  // -------- Validation --------
  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? get emailError {
    if (!_emailSubmitAttempted) return null;
    final email = emailController.text.trim();
    if (email.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!_validateEmail(email)) return 'البريد الإلكتروني غير صالح';
    if (_serverError != null) return _serverError;
    return null;
  }

  bool get emailInvalid {
    if (!_emailSubmitAttempted) return false;
    final email = emailController.text.trim();
    return email.isEmpty || !_validateEmail(email);
  }

  void clearServerError() {
    _serverError = null;
    notifyListeners();
  }

  String? get passwordError {
    if (!_passwordSubmitAttempted) return null;

    final p1 = newPasswordController.text;
    final p2 = confirmPasswordController.text;

    if (p1.isEmpty) return 'كلمة المرور الجديدة مطلوبة';
    if (p1.length < 6) return 'كلمة المرور قصيرة';
    if (p2.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (p1 != p2) return 'كلمتا المرور غير متطابقتين';
    if (_serverError != null) return _serverError;
    return null;
  }

  bool get passwordInvalid {
    if (!_passwordSubmitAttempted) return false;
    final p1 = newPasswordController.text;
    final p2 = confirmPasswordController.text;
    return p1.isEmpty || p1.length < 6 || p2.isEmpty || p1 != p2;
  }

  // -------- Actions --------

  /// (تجريبي) إرسال رابط/كود إعادة تعيين
  Future<void> sendResetLink() async {
    if (!_isButtonEnabled) return;

    _emailSubmitAttempted = true;
    _serverError = null;
    notifyListeners();

    if (emailInvalid) return;

    _startCooldown(seconds: 30);

    // محاكاة API
    await Future.delayed(const Duration(milliseconds: 700));

    // مثال تجريبي: بريد غير مسجل
    final email = emailController.text.trim();
    if (email != 'test@example.com') {
      _serverError = 'البريد الإلكتروني غير مسجل';
      notifyListeners();
      return;
    }

    // نجاح (تقدرين هنا تنتقلين لصفحة إنشاء كلمة مرور جديدة)
  }

  /// (تجريبي) حفظ كلمة المرور الجديدة
  Future<void> setNewPassword() async {
    _passwordSubmitAttempted = true;
    _serverError = null;
    notifyListeners();

    if (passwordInvalid) return;

    // محاكاة API
    await Future.delayed(const Duration(milliseconds: 700));

    // نجاح: صفري الحالة أو ارجعي لتسجيل الدخول
  }

  void _startCooldown({required int seconds}) {
    _isButtonEnabled = false;
    _secondsRemaining = seconds;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _secondsRemaining--;
      if (_secondsRemaining <= 0) {
        _isButtonEnabled = true;
        t.cancel();
      }
      notifyListeners();
    });
  }

  void reset() {
    _emailSubmitAttempted = false;
    _passwordSubmitAttempted = false;
    _serverError = null;

    emailController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    _timer?.cancel();
    _timer = null;
    _isButtonEnabled = true;
    _secondsRemaining = 0;

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
