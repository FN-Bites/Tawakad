import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../model/ble_item.dart';
import 'ble_provider.dart';

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

  final List<BleItem> _savedItems = [];
  final Map<String, String> _mappings = {};
  final Map<String, _ScheduleEntry> _schedules = {};

  void Function(String checklistItemName, String listId, bool isPresent)?
      onAutoScanResult;

  static const String _prefMapPrefix = 'ble_mapping_';
  static const String _prefMappedItems = 'ble_mapped_items';

  List<BleItem> get savedItems => List.unmodifiable(_savedItems);
  Map<String, String> get mappings => Map.unmodifiable(_mappings);

  String? mappedDeviceId(String itemName) => _mappings[itemName];

  bool isItemPresent(String itemName) {
    final deviceId = _mappings[itemName];
    if (deviceId == null) return false;
    return _ble.isDevicePresent(deviceId);
  }

  BleItem? deviceForItem(String itemName) {
    final deviceId = _mappings[itemName];
    if (deviceId == null) return null;
    return _ble.deviceById(deviceId);
  }

  BleItemProvider(this._ble) {
    _loadPrefs();
  }

  void updateBle(BleProvider ble) {
    _ble = ble;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final e in _schedules.values) {
      e.timer?.cancel();
    }
    super.dispose();
  }

  // ── Saved items ───────────────────────────────────────────────────────

  void addSavedItem(BleItem item) {
    _savedItems.add(item);
    notifyListeners();
  }

  void updateSavedItem(BleItem updated) {
    final idx = _savedItems.indexWhere((i) => i.deviceId == updated.deviceId);
    if (idx == -1) {
      _savedItems.add(updated);
    } else {
      _savedItems[idx] = updated;
    }
    notifyListeners();
  }

  void removeSavedItem(String deviceId) {
    _savedItems.removeWhere((i) => i.deviceId == deviceId);
    final keysToRemove =
        _schedules.keys.where((k) => k.startsWith('$deviceId|')).toList();
    for (final k in keysToRemove) {
      _schedules[k]?.timer?.cancel();
      _schedules.remove(k);
    }
    notifyListeners();
  }

  void toggleFavorite(String deviceId) {
    final index = _savedItems.indexWhere((i) => i.deviceId == deviceId);
    if (index == -1) return;
    _savedItems[index] = _savedItems[index].copyWith(
      isFavorite: !_savedItems[index].isFavorite,
    );
    notifyListeners();
  }

  // ── Multi-list helpers ────────────────────────────────────────────────

  void addListToItem(String deviceId, String listId) {
    final idx = _savedItems.indexWhere((i) => i.deviceId == deviceId);
    if (idx == -1) return;
    final current = List<String>.from(_savedItems[idx].listIds);
    if (!current.contains(listId)) {
      current.add(listId);
      _savedItems[idx] = _savedItems[idx].copyWith(listIds: current);
      notifyListeners();
    }
  }

  void removeListFromItem(String deviceId, String listId) {
    final idx = _savedItems.indexWhere((i) => i.deviceId == deviceId);
    if (idx == -1) return;
    final current = List<String>.from(_savedItems[idx].listIds)..remove(listId);
    _savedItems[idx] = _savedItems[idx].copyWith(listIds: current);
    cancelSchedule(deviceId, listId);
    notifyListeners();
  }

  // ── Mappings ──────────────────────────────────────────────────────────

  void mapItem(String itemName, String deviceId) {
    _mappings[itemName] = deviceId;
    _savePrefs();
    notifyListeners();
  }

  void unmapItem(String itemName) {
    _mappings.remove(itemName);
    _savePrefs();
    notifyListeners();
  }

  // ── Persistence ───────────────────────────────────────────────────────

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final mappedItems = prefs.getStringList(_prefMappedItems) ?? [];
    for (final itemName in mappedItems) {
      final deviceId = prefs.getString('$_prefMapPrefix$itemName');
      if (deviceId != null) _mappings[itemName] = deviceId;
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefMappedItems, _mappings.keys.toList());
    for (final entry in _mappings.entries) {
      await prefs.setString('$_prefMapPrefix${entry.key}', entry.value);
    }
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
    entry.timer = Timer(delay, () => _runAutoScan(entry, listTime));
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

  // ── Internal ──────────────────────────────────────────────────────────

  Future<void> _runAutoScan(_ScheduleEntry entry, String? listTime) async {
    debugPrint('Auto-scan firing for ${entry.item.name}@${entry.listId} '
        '(checklist: ${entry.checklistItemName})');

    if (_ble.adapterState != BluetoothAdapterState.on) {
      debugPrint('Auto-scan: adapter off, aborting.');
      if (entry.listDate == null) _reschedule(entry, listTime);
      return;
    }

    // Use probeSingleDevice — checks raw RSSI directly, no smoothing drift
    final present = await _ble.probeSingleDevice(
      entry.item.deviceId,
      listenDuration: const Duration(seconds: 15),
    );

    debugPrint('Auto-scan result for ${entry.item.name}@${entry.listId}: '
        '${present ? "PRESENT ✓" : "ABSENT ✗"}');

    onAutoScanResult?.call(entry.checklistItemName, entry.listId, present);

    if (entry.listDate == null) {
      _reschedule(entry, listTime);
    } else {
      debugPrint(
          'Auto-scan: one-shot complete for ${entry.item.name}@${entry.listId}, not rescheduling.');
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
        () => _runAutoScan(newEntry, listTime));
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
      final fire = DateTime(listDate.year, listDate.month, listDate.day, h, m)
          .subtract(Duration(minutes: minutesBefore));
      return fire.isBefore(now) ? null : fire;
    }

    var fire = DateTime(now.year, now.month, now.day, h, m)
        .subtract(Duration(minutes: minutesBefore));
    if (fire.isBefore(now)) fire = fire.add(const Duration(days: 1));
    return fire;
  }
}
