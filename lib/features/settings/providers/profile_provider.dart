// 🔄 profile_provider.dart — حالة الملف الشخصي + الإعدادات (Firebase)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tawakad_app/core/services/notification_settings_service.dart';
import 'package:tawakad_app/core/services/user_service.dart';
import 'package:tawakad_app/features/settings/models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    UserService? userService,
    NotificationSettingsService? notificationService,
  })  : _userService = userService ?? UserService(),
        _notificationService =
            notificationService ?? NotificationSettingsService();

  final UserService _userService;
  final NotificationSettingsService _notificationService;

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  bool _darkMode = false;
  bool _shareData = false;
  bool _notificationsEnabled = true;
  String _appLanguage = 'ar';

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController medicationController = TextEditingController();

  String? _gender;
  String? _status;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get darkMode => _darkMode;
  bool get shareData => _shareData;
  bool get notificationsEnabled => _notificationsEnabled;
  String get appLanguage => _appLanguage;
  String? get gender => _gender;
  String? get status => _status;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = 'يجب تسجيل الدخول أولاً';
        _profile = null;
        return;
      }

      final data = await _userService.getUserDocument(user.uid);
      _profile = UserProfile.fromFirestore(
        uid: user.uid,
        email: user.email ?? '',
        data: data,
      );

      usernameController.text =
          _profile!.displayName == 'اسم المستخدم' ? '' : _profile!.displayName;
      medicationController.text = _profile!.medicationNotes ?? '';
      _gender = _profile!.gender;
      _status = _profile!.status;

      final notificationState = await _notificationService.loadState();
      _notificationsEnabled = notificationState.appEnabled;
    } catch (_) {
      _error = 'تعذّر تحميل الملف الشخصي';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setGender(String? value) {
    _gender = value;
    notifyListeners();
  }

  void setStatus(String? value) {
    _status = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setShareData(bool value) {
    _shareData = value;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setAppLanguage(String value) {
    _appLanguage = value;
    notifyListeners();
  }

  Future<bool> updateEmail(String newEmail, String password) async {
    final user = FirebaseAuth.instance.currentUser;
    final current = _profile;
    if (user == null || current == null || user.email == null) return false;

    final trimmed = newEmail.trim();
    if (trimmed.isEmpty || trimmed == user.email) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(trimmed);

      await _userService.updateUserEmail(uid: user.uid, email: trimmed);
      _profile = current.copyWith(email: trimmed);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = switch (e.code) {
        'wrong-password' => 'كلمة المرور غير صحيحة',
        'invalid-email' => 'البريد غير صالح',
        'email-already-in-use' => 'البريد مستخدم مسبقاً',
        _ => 'تعذّر تحديث البريد',
      };
      return false;
    } catch (_) {
      _error = 'تعذّر تحديث البريد';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return false;

    if (newPassword.length < 8) {
      _error = 'كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل';
      notifyListeners();
      return false;
    }

    if (currentPassword == newPassword) {
      _error = 'كلمة المرور الجديدة يجب أن تختلف عن الحالية';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      await _userService.updatePasswordHistoryIfChanged(
        uid: user.uid,
        email: user.email!,
        currentPassword: newPassword,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _error = switch (e.code) {
        'wrong-password' => 'كلمة المرور الحالية غير صحيحة',
        'weak-password' => 'كلمة المرور الجديدة ضعيفة جداً',
        'requires-recent-login' => 'سجّل الدخول مجدداً ثم حاول مرة أخرى',
        _ => 'تعذّر تغيير كلمة المرور',
      };
      return false;
    } catch (_) {
      _error = 'تعذّر تغيير كلمة المرور';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> save() async {
    final user = FirebaseAuth.instance.currentUser;
    final current = _profile;
    if (user == null || current == null) return false;

    _isSaving = true;
    notifyListeners();

    try {
      final nameParts = usernameController.text.trim().split(RegExp(r'\s+'));
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final updated = current.copyWith(
        firstName: firstName,
        lastName: lastName,
        gender: _gender,
        status: _status,
        medicationNotes: medicationController.text.trim(),
      );

      await _userService.updateUserProfile(
        uid: user.uid,
        answers: updated.toAnswers(),
        medicationNotes: updated.medicationNotes,
      );

      _profile = updated;
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    usernameController.dispose();
    medicationController.dispose();
    super.dispose();
  }
}
