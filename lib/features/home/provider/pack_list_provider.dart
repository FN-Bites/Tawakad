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
  void updateList(PackList updated) {
    final index = _lists.indexWhere((l) => l.id == updated.id);
    if (index == -1) return;
    _lists[index] = updated;
    notifyListeners();
  }

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
}
