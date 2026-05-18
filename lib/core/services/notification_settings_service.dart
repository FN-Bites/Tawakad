import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsService {
  static const _appEnabledKey = 'notifications_app_enabled';
  static const _medicationKey = 'notifications_medication';
  static const _listsKey = 'notifications_lists';
  static const _remindersKey = 'notifications_reminders';

  Future<bool> isAppEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_appEnabledKey) ?? false;
  }

  Future<void> setAppEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appEnabledKey, value);
  }

  Future<bool> isMedicationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_medicationKey) ?? true;
  }

  Future<void> setMedicationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_medicationKey, value);
  }

  Future<bool> isListsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_listsKey) ?? true;
  }

  Future<void> setListsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_listsKey, value);
  }

  Future<bool> isRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_remindersKey) ?? true;
  }

  Future<void> setRemindersEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersKey, value);
  }

  Future<PermissionStatus> systemStatus() => Permission.notification.status;

  Future<bool> isSystemGranted() async {
    final status = await systemStatus();
    return status.isGranted || status.isLimited;
  }

  Future<PermissionStatus> requestSystemPermission() =>
      Permission.notification.request();

  Future<void> openSystemSettings() => openAppSettings();

  Future<NotificationPreferenceState> loadState() async {
    final systemGranted = await isSystemGranted();
    final appEnabled = await isAppEnabled();
    return NotificationPreferenceState(
      systemGranted: systemGranted,
      appEnabled: appEnabled && systemGranted,
      medicationEnabled: await isMedicationEnabled(),
      listsEnabled: await isListsEnabled(),
      remindersEnabled: await isRemindersEnabled(),
      systemStatus: await systemStatus(),
    );
  }
}

class NotificationPreferenceState {
  const NotificationPreferenceState({
    required this.systemGranted,
    required this.appEnabled,
    required this.medicationEnabled,
    required this.listsEnabled,
    required this.remindersEnabled,
    required this.systemStatus,
  });

  final bool systemGranted;
  final bool appEnabled;
  final bool medicationEnabled;
  final bool listsEnabled;
  final bool remindersEnabled;
  final PermissionStatus systemStatus;

  String get statusLabel {
    if (systemStatus.isPermanentlyDenied) return 'مرفوضة من إعدادات الجهاز';
    if (systemStatus.isDenied) return 'غير مفعّلة';
    if (appEnabled) return 'مفعّلة';
    return 'معطّلة داخل التطبيق';
  }
}
