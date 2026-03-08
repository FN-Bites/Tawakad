import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/user_service.dart';

class CreateNewPasswordFlowProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Controllers
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // State
  String _password = '';
  String _confirmPassword = '';

  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasMinLength = false;
  bool _hasSpecialChar = false;

  String? serverError;
  bool isLoading = false;
  bool codeValid = false;
  String? email;
  String? userId;
  String? codeError;

  String get password => _password;
  String get confirmPassword => _confirmPassword;

  String? get passwordError {
    if (_password.isEmpty) return 'يرجى إدخال كلمة المرور';
    if (!_validatePassword(_password)) return 'كلمة المرور لا تتوافق مع الشروط';
    if (serverError != null) return serverError;
    return null;
  }

  String? get confirmPasswordError {
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

  bool _validatePassword(String password) {
    return _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasMinLength &&
        _hasSpecialChar;
  }

  bool get passwordInvalid =>
      _password.isEmpty || !_validatePassword(_password) || serverError != null;
  bool get confirmPasswordInvalid =>
      _confirmPassword != _password || _confirmPassword.isEmpty;

  void setPassword(String value) {
    _password = value;
    serverError = null;
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

  bool get isButtonEnabled {
    return _validatePassword(_password) &&
        _confirmPassword == _password &&
        !isLoading;
  }

  Future<void> verifyResetCode(String code) async {
    try {
      final userEmail = await _auth.verifyPasswordResetCode(code);
      email = userEmail;
      userId = await _userService.getUserIdByEmail(userEmail);
      codeValid = true;
      codeError = null;
    } on FirebaseAuthException catch (e) {
      codeValid = false;
      if (e.code == 'expired-action-code') {
        codeError = 'انتهت صلاحية رابط إعادة التعيين';
      } else if (e.code == 'invalid-action-code') {
        codeError = 'رابط إعادة التعيين غير صالح';
      } else {
        codeError = 'تعذر التحقق من رابط إعادة التعيين';
      }
    }
    notifyListeners();
  }

  Future<bool> submit({
    required String oobCode,
  }) async {
    if (!isButtonEnabled) return false;
    isLoading = true;
    serverError = null;
    notifyListeners();
    try {
      await _userService.checkPasswordReuse(
        userId: userId!,
        newPassword: _password,
      );
      await _auth.confirmPasswordReset(
        code: oobCode,
        newPassword: _password,
      );
      await _userService.updatePasswordHistory(
        userId: userId!,
        newPassword: _password,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e.toString().contains('PASSWORD_ALREADY_USED')) {
        serverError = 'لا يمكن استخدام كلمة مرور تم استخدامها سابقاً';
      } else {
        serverError = 'حدث خطأ غير متوقع أثناء تعيين كلمة المرور';
      }
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
