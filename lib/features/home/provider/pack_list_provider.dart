import 'package:flutter/material.dart';
import '../model/pack_list.dart';

class PackListProvider extends ChangeNotifier {
  final List<PackList> _lists = [];

  /// BleItemProvider registers here to react to list time changes.
  void Function(String listId, String? newTime, DateTime? newDate)?
      onTimeChanged;

  // ─── Read ────────────────────────────────────────────────
  List<PackList> get lists => List.unmodifiable(_lists);

  // ─── Create ──────────────────────────────────────────────
  void addList(PackList list) {
    _lists.add(list);
    notifyListeners();
  }

  void createList({
    required String title,
    required String iconPath,
    required Color color,
    required bool isFavorite,
    List<String> items = const [],
    DateTime? date,
    String? time,
    String? event,
    bool repeat = false,
    List<int> repeatDays = const [],
    bool isShared = false,
  }) {
    _lists.add(PackList.create(
      userId: 'local',
      title: title,
      iconPath: iconPath,
      color: color,
      items: items,
      date: date,
      time: time,
      event: event,
      repeat: repeat,
      repeatDays: repeatDays,
      isShared: isShared,
      isFavorite: isFavorite,
    ));
    notifyListeners();
  }

  // ─── Delete ──────────────────────────────────────────────
  void removeList(String id) {
    _lists.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  // ─── Update ──────────────────────────────────────────────
  void editList({
    required String id,
    required String title,
    required String iconPath,
    required Color color,
    required bool isFavorite,
    DateTime? date,
    String? time,
    String? event,
    bool repeat = false,
    List<int> repeatDays = const [],
    bool isShared = false,
  }) {
    final index = _lists.indexWhere((l) => l.id == id);
    if (index == -1) return;

    final old = _lists[index];
    final timeChanged = old.time != time || old.date != date;

    _lists[index] = old.copyWith(
      title: title,
      iconPath: iconPath,
      colorValue: color.value,
      isFavorite: isFavorite,
      date: date,
      time: time,
      event: event,
      repeat: repeat,
      repeatDays: repeatDays,
      isShared: isShared,
    );

    if (timeChanged && time != null) {
      // Auto-uncheck items if the new scheduled time is in the future.
      final newFireTime = _resolveFireTime(time, date);
      if (newFireTime != null && newFireTime.isAfter(DateTime.now())) {
        _lists[index] = _lists[index].copyWith(checkedIndices: {});
      }

      // Notify BleItemProvider to cancel the old schedule and set a new one.
      onTimeChanged?.call(id, time, date);
    }

    notifyListeners();
  }

  // ─── Like ─────────────────────────────────────────────────
  void toggleFavorite(String id) {
    final index = _lists.indexWhere((l) => l.id == id);
    if (index == -1) return;
    _lists[index] =
        _lists[index].copyWith(isFavorite: !_lists[index].isFavorite);
    notifyListeners();
  }

  // ─── Items ────────────────────────────────────────────────
  void addItem(String listId, String item) {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index == -1) return;
    final updated = List<String>.from(_lists[index].items)..add(item);
    _lists[index] = _lists[index].copyWith(items: updated);
    notifyListeners();
  }

  void removeItem(String listId, String item) {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index == -1) return;
    final updated = List<String>.from(_lists[index].items)..remove(item);
    _lists[index] = _lists[index].copyWith(items: updated);
    notifyListeners();
  }

  // ─── Items extended ───────────────────────────────────────
  void renameItem(String listId, int index, String newName) {
    final i = _lists.indexWhere((l) => l.id == listId);
    if (i == -1) return;
    final updated = List<String>.from(_lists[i].items);
    updated[index] = newName;
    _lists[i] = _lists[i].copyWith(items: updated);
    notifyListeners();
  }

  void removeItemAt(String listId, int index) {
    final i = _lists.indexWhere((l) => l.id == listId);
    if (i == -1) return;
    final updated = List<String>.from(_lists[i].items)..removeAt(index);
    final updatedChecked = _lists[i]
        .checkedIndices
        .where((idx) => idx != index)
        .map((idx) => idx > index ? idx - 1 : idx)
        .toSet();
    _lists[i] =
        _lists[i].copyWith(items: updated, checkedIndices: updatedChecked);
    notifyListeners();
  }

  void toggleItemChecked(String listId, int index) {
    final i = _lists.indexWhere((l) => l.id == listId);
    if (i == -1) return;
    final current = Set<int>.from(_lists[i].checkedIndices);
    if (current.contains(index)) {
      current.remove(index);
    } else {
      current.add(index);
    }
    _lists[i] = _lists[i].copyWith(checkedIndices: current);
    notifyListeners();
  }

  void checkItemByName(String listId, String itemName) {
    final i = _lists.indexWhere((l) => l.id == listId);
    if (i == -1) return;

    final itemIndex = _lists[i].items.indexOf(itemName);
    if (itemIndex == -1) return;

    final current = Set<int>.from(_lists[i].checkedIndices);
    if (current.contains(itemIndex)) return;

    current.add(itemIndex);
    _lists[i] = _lists[i].copyWith(checkedIndices: current);
    notifyListeners();
  }

  String? listTime(String listId) {
    try {
      return _lists.firstWhere((l) => l.id == listId).time;
    } catch (_) {
      return null;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────

  /// Resolves the concrete DateTime at which a list will fire.
  /// Returns null if the time string is malformed.
  DateTime? _resolveFireTime(String time, DateTime? date) {
    final parts = time.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    final now = DateTime.now();
    if (date != null) {
      return DateTime(date.year, date.month, date.day, h, m);
    }
    var fire = DateTime(now.year, now.month, now.day, h, m);
    if (fire.isBefore(now)) fire = fire.add(const Duration(days: 1));
    return fire;
  }
}
