import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:tawakad_app/features/ble_scanning/service/ble_firestore_service.dart';
import '../model/ble_item.dart';
import 'ble_provider.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';

class _ScheduleEntry {
  final BleItem item;
  final String listId;
  final String checklistItemName;
  final int minutesBefore;
  final DateTime? listDate;
  Timer? timer;

  _ScheduleEntry({
    required this.item,
    required this.listId,
    required this.checklistItemName,
    required this.minutesBefore,
    this.listDate,
  });
}

String _scheduleKey(String deviceId, String listId) => '$deviceId|$listId';

class BleItemProvider extends ChangeNotifier {
  BleProvider _ble;
  final PackListProvider _packLists;
  final BleFirestoreService _service = BleFirestoreService();

  final List<BleItem> _savedItems = [];
  final Map<String, String> _mappings = {};
  final Map<String, _ScheduleEntry> _schedules = {};

  final Map<String, Future<void>> _activeBatches = {};

  StreamSubscription<User?>? _authSub;

  void Function(String checklistItemName, String listId, bool isPresent)?
      onAutoScanResult;

  List<BleItem> get savedItems => List.unmodifiable(_savedItems);
  //Map<String, String> get mappings => Map.unmodifiable(_mappings);
  Map<String, String> get mappings => Map.unmodifiable({
        for (final item in _savedItems)
          item.name: item.mappedDeviceId ?? item.deviceId,
        ..._mappings,
      });

  String? mappedDeviceId(String itemName) {
    final saved = _findByName(itemName);
    return saved?.mappedDeviceId ?? _mappings[itemName];
  }

  bool isItemPresent(String itemName) {
    final deviceId = mappedDeviceId(itemName);
    if (deviceId == null) return false;
    return _ble.isDevicePresent(deviceId);
  }

  BleItem? deviceForItem(String itemName) {
    final deviceId = mappedDeviceId(itemName);
    if (deviceId == null) return null;
    return _ble.deviceById(deviceId);
  }

  BleItemProvider(this._ble, this._packLists) {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        _clearState();
        return;
      }
      await fetchBleItems();
    });

    _packLists.onTimeChanged = (listId, newTime, newDate) {
      _rescheduleForList(listId, newTime, newDate);
    };
  }

  void updateBle(BleProvider ble) {
    _ble = ble;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    for (final e in _schedules.values) {
      e.timer?.cancel();
    }
    super.dispose();
  }

  // ── Saved items ───────────────────────────────────────────────────────

  Future<void> fetchBleItems() async {
    if (_packLists.lists.isEmpty) {
      await _packLists.fetchLists();
    }
    final docs = await _service.fetchBleItems();
    _savedItems.clear();
    for (final doc in docs) {
      _savedItems.add(BleItem.fromMap(doc.data()));
    }
    _mappings.clear();
    _restoreSchedulesFromSavedItems();
    notifyListeners();
  }

  Future<void> addSavedItem(BleItem item) async {
    final data = {
      ...item.toMap(),
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'userId': _service.userId ?? '',
    };

    await _service.createBleItem(data);
    _savedItems.add(item);
    _mappings.remove(item.name);
    notifyListeners();
  }

  Future<void> updateSavedItem(BleItem updated) async {
    final data = {
      ...updated.toMap(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    await _service.editBleItem(updated.deviceId, data);
    final index = _savedItems.indexWhere((i) => i.deviceId == updated.deviceId);
    if (index == -1) {
      _savedItems.add(updated);
    } else {
      _savedItems[index] = updated;
    }

    _mappings.remove(updated.name);
    notifyListeners();
  }

  Future<void> removeSavedItem(String bleIdentifier) async {
    final item = _findByDeviceId(bleIdentifier);
    if (item == null) return;

    await _service.removeBleItem(item.deviceId);
    _savedItems.removeWhere((i) => i.deviceId == item.deviceId);
    final keysToRemove = _schedules.keys
        .where((k) => k.startsWith('${item.deviceId}|'))
        .toList();
    for (final k in keysToRemove) {
      _schedules[k]?.timer?.cancel();
      _schedules.remove(k);
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String bleIdentifier) async {
    final item = _findByDeviceId(bleIdentifier);
    if (item == null) return;

    final updatedValue = !item.isFavorite;
    await _service.toggleFavorite(item.deviceId, updatedValue);
    final index = _savedItems.indexWhere((i) => i.deviceId == item.deviceId);
    if (index != -1) {
      _savedItems[index] = _savedItems[index].copyWith(
        isFavorite: updatedValue,
      );
      notifyListeners();
    }
  }

  // ── Multi-list helpers ────────────────────────────────────────────────

  Future<void> addListToItem(String deviceId, String listId) async {
    final item = _findByDeviceId(deviceId);
    if (item == null) return;

    final current = List<String>.from(item.listIds);
    if (current.contains(listId)) return;

    await _service.addListToItem(item.deviceId, current, listId);
    current.add(listId);
    final index = _savedItems.indexWhere((i) => i.deviceId == item.deviceId);
    if (index != -1) {
      _savedItems[index] = _savedItems[index].copyWith(listIds: current);
      notifyListeners();
    }
  }

  Future<void> removeListFromItem(String deviceId, String listId) async {
    final item = _findByDeviceId(deviceId);
    if (item == null) return;

    final current = List<String>.from(item.listIds)..remove(listId);
    await _service.removeListFromItem(item.deviceId, item.listIds, listId);
    final index = _savedItems.indexWhere((i) => i.deviceId == item.deviceId);
    if (index != -1) {
      _savedItems[index] = _savedItems[index].copyWith(listIds: current);
      notifyListeners();
    }
    cancelSchedule(deviceId, listId);
  }

  // ── Mappings ──────────────────────────────────────────────────────────

  void mapItem(String itemName, String deviceId) {
    _mappings[itemName] = deviceId;
    notifyListeners();
  }

  void unmapItem(String itemName) {
    _mappings.remove(itemName);
    notifyListeners();
  }

  // ── Auto-scan scheduling ──────────────────────────────────────────────

  void scheduleAutoScan({
    required BleItem item,
    required String listId,
    required String checklistItemName,
    required int minutesBefore,
    String? listTime,
    DateTime? fireAt,
    DateTime? listDate,
  }) {
    debugPrint('scheduleAutoScan called: ${item.name}, listId=$listId, '
        'listTime=$listTime, fireAt=$fireAt, listDate=$listDate, '
        'minutesBefore=$minutesBefore');

    final key = _scheduleKey(item.deviceId, listId);
    _schedules[key]?.timer?.cancel();

    final target = fireAt ??
        (listTime != null
            ? _nextFireTime(listTime, minutesBefore, listDate)
            : null);

    if (target == null) {
      debugPrint(
          'scheduleAutoScan: no target time for ${item.name}@$listId, skipping.');
      return;
    }

    final delay = target.difference(DateTime.now());
    if (delay.isNegative) {
      debugPrint(
          'scheduleAutoScan: target is in the past for ${item.name}@$listId, skipping.');
      return;
    }

    debugPrint('scheduleAutoScan: ${item.name}@$listId fires in '
        '${delay.inMinutes}m ${delay.inSeconds % 60}s '
        '(date: $listDate, checklistItem: $checklistItemName)');

    final entry = _ScheduleEntry(
      item: item,
      listId: listId,
      checklistItemName: checklistItemName,
      minutesBefore: minutesBefore,
      listDate: listDate,
    );
    entry.timer = Timer(delay, () => _onTimerFired(entry, listTime));
    _schedules[key] = entry;
  }

  void cancelSchedule(String itemDeviceId, [String? listId]) {
    if (listId != null) {
      final key = _scheduleKey(itemDeviceId, listId);
      _schedules[key]?.timer?.cancel();
      _schedules.remove(key);
    } else {
      final keys =
          _schedules.keys.where((k) => k.startsWith('$itemDeviceId|')).toList();
      for (final k in keys) {
        _schedules[k]?.timer?.cancel();
        _schedules.remove(k);
      }
    }
  }

  // ── Reschedule on time edit ───────────────────────────────────────────

  void _rescheduleForList(
    String listId,
    String? newTime,
    DateTime? newDate,
  ) {
    final affected =
        _savedItems.where((item) => item.listIds.contains(listId)).toList();

    for (final item in affected) {
      cancelSchedule(item.deviceId, listId);

      if (newTime == null) continue;

      final existing = _schedules[_scheduleKey(item.deviceId, listId)];
      final checklistItemName = existing?.checklistItemName ?? item.name;
      final minutesBefore =
          existing?.minutesBefore ?? item.reminderMinutesBefore ?? 0;

      scheduleAutoScan(
        item: item,
        listId: listId,
        checklistItemName: checklistItemName,
        minutesBefore: minutesBefore,
        listTime: newTime,
        listDate: newDate,
      );

      debugPrint(
          'Rescheduled ${item.name}@$listId for new time $newTime (date: $newDate)');
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────

  Future<void> _onTimerFired(_ScheduleEntry fired, String? listTime) async {
    final listId = fired.listId;
    if (_activeBatches.containsKey(listId)) {
      debugPrint('Auto-scan: late arrival ${fired.item.name}@$listId, '
          'waiting for running batch then probing solo.');
      await _activeBatches[listId];
      final result = await _ble.probeMultipleDevices(
        [fired.item.deviceId],
        listenDuration: const Duration(seconds: 20),
      );
      final present = result[fired.item.deviceId] ?? false;
      debugPrint('Auto-scan (late) result for ${fired.item.name}@$listId: '
          '${present ? "PRESENT ✓" : "ABSENT ✗"}');
      onAutoScanResult?.call(fired.checklistItemName, listId, present);
      if (fired.listDate == null) _reschedule(fired, listTime);
      return;
    }

    if (_ble.adapterState != BluetoothAdapterState.on) {
      debugPrint('Auto-scan: adapter off, aborting.');
      if (fired.listDate == null) _reschedule(fired, listTime);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final dueEntries =
        _schedules.values.where((e) => e.listId == listId).toList();

    debugPrint('Auto-scan: batching ${dueEntries.length} device(s) for '
        'list $listId → ${dueEntries.map((e) => e.item.name).join(", ")}');

    final batchFuture = _runBatchProbe(dueEntries, listTime);
    _activeBatches[listId] = batchFuture;
    try {
      await batchFuture;
    } finally {
      _activeBatches.remove(listId);
    }
  }

  Future<void> _runBatchProbe(
      List<_ScheduleEntry> entries, String? listTime) async {
    final deviceIds = entries.map((e) => e.item.deviceId).toList();

    final results = await _ble.probeMultipleDevices(
      deviceIds,
      listenDuration: const Duration(seconds: 20),
    );

    for (final entry in entries) {
      final present = results[entry.item.deviceId] ?? false;

      debugPrint('Auto-scan result for ${entry.item.name}@${entry.listId}: '
          '${present ? "PRESENT ✓" : "ABSENT ✗"}');

      onAutoScanResult?.call(entry.checklistItemName, entry.listId, present);

      if (entry.listDate == null) {
        _reschedule(entry, listTime);
      } else {
        debugPrint('Auto-scan: one-shot complete for '
            '${entry.item.name}@${entry.listId}, not rescheduling.');
      }
    }
  }

  void _reschedule(_ScheduleEntry entry, String? listTime) {
    if (entry.listDate != null) return;
    if (listTime == null) return;

    final next = _nextFireTime(listTime, entry.minutesBefore, null);
    if (next == null) return;

    final key = _scheduleKey(entry.item.deviceId, entry.listId);
    final newEntry = _ScheduleEntry(
      item: entry.item,
      listId: entry.listId,
      checklistItemName: entry.checklistItemName,
      minutesBefore: entry.minutesBefore,
      listDate: null,
    );
    newEntry.timer = Timer(next.difference(DateTime.now()),
        () => _onTimerFired(newEntry, listTime));
    _schedules[key] = newEntry;
  }

  DateTime? _nextFireTime(String listTime, int minutesBefore,
      [DateTime? listDate]) {
    final parts = listTime.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;

    final now = DateTime.now();

    if (listDate != null) {
      var fire = DateTime(listDate.year, listDate.month, listDate.day, h, m)
          .subtract(Duration(minutes: minutesBefore));
      if (fire.isBefore(now)) fire = fire.add(const Duration(days: 1));
      return fire;
    }

    var fire = DateTime(now.year, now.month, now.day, h, m)
        .subtract(Duration(minutes: minutesBefore));
    if (fire.isBefore(now)) fire = fire.add(const Duration(days: 1));
    return fire;
  }

  void _restoreSchedulesFromSavedItems() {
    for (final entry in _schedules.values) {
      entry.timer?.cancel();
    }
    _schedules.clear();

    for (final item in _savedItems) {
      final minutesBefore = item.reminderMinutesBefore;
      if (minutesBefore == null) continue;

      for (final listId in item.listIds) {
        final list = _findListById(listId);
        if (list == null || list.time == null) continue;

        scheduleAutoScan(
          item: item,
          listId: listId,
          checklistItemName: item.name,
          minutesBefore: minutesBefore,
          listTime: list.time,
          listDate: list.date,
        );
      }
    }
  }

  BleItem? _findByDeviceId(String deviceId) {
    try {
      return _savedItems.firstWhere((item) => item.deviceId == deviceId);
    } catch (_) {
      return null;
    }
  }

  BleItem? _findByName(String itemName) {
    try {
      return _savedItems.firstWhere((item) => item.name == itemName);
    } catch (_) {
      return null;
    }
  }

  PackList? _findListById(String listId) {
    try {
      return _packLists.lists.firstWhere((list) => list.id == listId);
    } catch (_) {
      return null;
    }
  }

  void _clearState() {
    _savedItems.clear();
    _mappings.clear();
    for (final entry in _schedules.values) {
      entry.timer?.cancel();
    }
    _schedules.clear();
    notifyListeners();
  }
}
