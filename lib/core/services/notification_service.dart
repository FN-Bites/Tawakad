import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_settings_service.dart';
import '../../features/home/model/pack_list.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _channel = MethodChannel('android_channel');

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final NotificationSettingsService _settings = NotificationSettingsService();

  int _preId(String listId) => (listId.hashCode & 0x3FFFFFFF);
  int _postId(String listId) => ((listId + '__post').hashCode & 0x3FFFFFFF);

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    debugPrint('[Notifications] ✓ init complete, timezone=Asia/Riyadh');
  }

  Future<bool> requestExactAlarmPermission() async {
    return true;
  }

  Future<void> requestIgnoreBatteryOptimization() async {
    if (kIsWeb) {
      return;
    }
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('ignoreBatteryOptimization');
    } catch (e) {
      debugPrint('[Notifications] battery opt error: $e');
    }
  }

  Future<void> _scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    bool isPost = false,
    String listId = '',
  }) async {
    if (Platform.isAndroid) {
      final triggerMs = scheduledTime.millisecondsSinceEpoch;
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      await _channel.invokeMethod('scheduleAlarm', {
        'id': id,
        'title': title,
        'body': body,
        'triggerMs': triggerMs,
        'isPost': isPost,
        'listId': listId,
        'userId': userId,
      });
      debugPrint(
          '[Notifications] AlarmManager scheduled id=$id at $scheduledTime');
    } else {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _cancelAlarm(int id) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('cancelAlarm', {'id': id});
    } else {
      await _plugin.cancel(id);
    }
  }

  Future<void> cancelForList(String listId) async {
    await _cancelAlarm(_preId(listId));
    await _cancelAlarm(_postId(listId));
  }

  Future<void> syncNotifications(PackList list) async {
    debugPrint('[Notifications] ══════════════════════════════════════');
    debugPrint('[Notifications] syncNotifications → "${list.title}"');
    debugPrint('[Notifications] id=${list.id}');
    debugPrint('[Notifications] date=${list.date}');
    debugPrint('[Notifications] time=${list.time}');

    await cancelForList(list.id);

    final bool listsEnabled = await _settings.isListsEnabled();
    final bool appEnabled = await _settings.isAppEnabled();
    debugPrint(
        '[Notifications] appEnabled=$appEnabled, listsEnabled=$listsEnabled');

    if (!listsEnabled || !appEnabled) {
      debugPrint('[Notifications] ✗ BLOCKED by settings');
      return;
    }

    if (list.date == null || list.time == null) {
      debugPrint('[Notifications] ✗ BLOCKED: date or time is null');
      return;
    }

    final tz.TZDateTime? scheduled =
        _buildScheduledDateTime(list.date!, list.time!);
    if (scheduled == null) {
      debugPrint('[Notifications] ✗ BLOCKED: could not parse datetime');
      return;
    }

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    debugPrint('[Notifications] now      = $now');
    debugPrint('[Notifications] scheduled= $scheduled');

    final tz.TZDateTime preFire =
        scheduled.subtract(const Duration(minutes: 1));
    final tz.TZDateTime postFire = scheduled.add(const Duration(minutes: 1));
    debugPrint(
        '[Notifications] preFire  = $preFire  isAfter=${preFire.isAfter(now)}');
    debugPrint(
        '[Notifications] postFire = $postFire isAfter=${postFire.isAfter(now)}');

    if (preFire.isAfter(now)) {
      try {
        await _scheduleAlarm(
          id: _preId(list.id),
          title: '${list.title} 🎒',
          body: 'اقترب موعد قائمتك، قم بالبدء في التجهيز.',
          scheduledTime: preFire,
          isPost: false,
          listId: list.id,
        );
        debugPrint(
            '[Notifications] ✓ PRE  scheduled at $preFire  (id=${_preId(list.id)})');
      } catch (e) {
        debugPrint('[Notifications] ✗ PRE  FAILED: $e');
      }
    } else {
      debugPrint('[Notifications] ✗ PRE  skipped — time already passed');
    }

    if (postFire.isAfter(now)) {
      try {
        await _scheduleAlarm(
          id: _postId(list.id),
          title: '${list.title} ⚠️ ',
          body: 'يبدو أنك نسيت بعض العناصر في قائمتك!',
          scheduledTime: postFire,
          isPost: true,
          listId: list.id,
        );
        debugPrint(
            '[Notifications] ✓ POST scheduled at $postFire (id=${_postId(list.id)})');
      } catch (e) {
        debugPrint('[Notifications] ✗ POST FAILED: $e');
      }
    } else {
      debugPrint('[Notifications] ✗ POST skipped — time already passed');
    }

    debugPrint('[Notifications] ══════════════════════════════════════');
  }

  tz.TZDateTime? _buildScheduledDateTime(DateTime date, String time) {
    try {
      final List<String> parts = time.split(':');
      if (parts.length < 2) return null;
      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      return tz.TZDateTime(
          tz.local, date.year, date.month, date.day, hour, minute);
    } catch (e) {
      debugPrint('[Notifications] Failed to parse time "$time": $e');
      return null;
    }
  }
}
