import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailFlowProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _checkTimer;
  Timer? _countdownTimer;

  static const int _initialSeconds = 30;

  int _secondsRemaining = _initialSeconds;
  bool _canResend = true;
  bool _isEmailVerified = false;

  int get secondsRemaining => _secondsRemaining;
  bool get canResend => _canResend;
  bool get isEmailVerified => _isEmailVerified;

  String get email => _auth.currentUser?.email ?? '';

  VerifyEmailFlowProvider() {
    _startCountdown();
    _startEmailVerificationCheck();
  }

  void _startCountdown() {
    _secondsRemaining = _initialSeconds;
    _canResend = false;
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (secondsRemaining == 0) {
          timer.cancel();
          _canResend = true;
          notifyListeners();
        } else {
          _secondsRemaining--;
          notifyListeners();
        }
      },
    );
  }

  void _startEmailVerificationCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkEmailVerified(),
    );
  }

  Future<void> _checkEmailVerified() async {
    await _auth.currentUser!.reload();
    final user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      _checkTimer?.cancel();
      _countdownTimer?.cancel();

      _isEmailVerified = true;
      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser!.sendEmailVerification();

    _startCountdown();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
