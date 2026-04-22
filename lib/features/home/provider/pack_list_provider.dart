import 'package:flutter/material.dart';
import '../model/pack_list.dart';

class PackListProvider extends ChangeNotifier {
  final List<PackList> _lists = [];

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
    _lists[index] = _lists[index].copyWith(
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
    notifyListeners();
  }

  // ─── Like ──────────────────────────────────────────────
  void toggleFavorite(String id) {
    final index = _lists.indexWhere((l) => l.id == id);
    if (index == -1) return;
    _lists[index] =
        _lists[index].copyWith(isFavorite: !_lists[index].isFavorite);
    notifyListeners();
  }

  // ─── Items ───────────────────────────────────────────────
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

  // ─── Items extended ──────────────────────────────────────
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

  /// Called by the BLE auto-scan: finds [itemName] inside [listId] and
  /// marks it as checked.  If it is already checked nothing changes.
  /// If [itemName] is not found the call is silently ignored.
  void checkItemByName(String listId, String itemName) {
    final i = _lists.indexWhere((l) => l.id == listId);
    if (i == -1) return;

    final itemIndex = _lists[i].items.indexOf(itemName);
    if (itemIndex == -1) return; // item not in this list

    final current = Set<int>.from(_lists[i].checkedIndices);
    if (current.contains(itemIndex)) return; // already checked — no-op

    current.add(itemIndex);
    _lists[i] = _lists[i].copyWith(checkedIndices: current);
    notifyListeners();
  }

  /// Returns the scheduled time string ("HH:mm") for a list, or null.
  String? listTime(String listId) {
    try {
      return _lists.firstWhere((l) => l.id == listId).time;
    } catch (_) {
      return null;
    }
  }
}
