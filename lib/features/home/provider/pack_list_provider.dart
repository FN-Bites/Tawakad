import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tawakad_app/core/services/firestore_service.dart';
import 'package:tawakad_app/features/rewards/provider/reward_provider.dart';
import '../model/pack_list.dart';

class PackListProvider extends ChangeNotifier {
  final List<PackList> _lists = [];
  final FirestoreService _service = FirestoreService();
  StreamSubscription<User?>? _authSub;

  final Map<String, Future<void>> _checkLocks = {};

  RewardProvider? rewardProvider;

  Function(String listId, String? newTime, DateTime? newDate)? onTimeChanged;

  PackListProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        fetchLists();
      } else {
        _lists.clear();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  // ───────── READ ─────────
  List<PackList> get lists => List.unmodifiable(_lists);

  Future<void> fetchLists() async {
    final docs = await _service.fetchLists();
    _lists.clear();
    for (var doc in docs) {
      _lists.add(PackList.fromMap(doc.data(), doc.id));
    }
    notifyListeners();
  }

  // ───────── CREATE ─────────
  Future<void> createList({
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
  }) async {
    final data = {
      'title': title,
      'iconPath': iconPath,
      'colorValue': color.value,
      'isFavorite': isFavorite,
      'items': items,
      'date': date != null ? Timestamp.fromDate(date) : null,
      'time': time,
      'event': event,
      'repeat': repeat,
      'repeatDays': repeatDays,
      'isShared': isShared,
      'checkedIndices': [],
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'userId': _service.userId ?? '',
    };

    await _service.createList(data);
    await fetchLists();
  }

  // ───────── DELETE ─────────
  Future<void> removeList(String id) async {
    await _service.removeList(id);
    _lists.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  // ───────── UPDATE LIST ─────────
  Future<void> editList({
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
  }) async {
    final data = {
      'title': title,
      'iconPath': iconPath,
      'colorValue': color.value,
      'isFavorite': isFavorite,
      'date': date != null ? Timestamp.fromDate(date) : null,
      'time': time,
      'event': event,
      'repeat': repeat,
      'repeatDays': repeatDays,
      'isShared': isShared,
    };

    await _service.editList(id, data);

    final index = _lists.indexWhere((l) => l.id == id);
    if (index != -1) {
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
      onTimeChanged?.call(id, time, date);
    }
  }

  // ───────── FAVORITE ─────────
  Future<void> toggleFavorite(String id) async {
    final index = _lists.indexWhere((l) => l.id == id);
    if (index == -1) return;

    final newValue = !_lists[index].isFavorite;
    await _service.toggleFavorite(id, newValue);

    _lists[index] = _lists[index].copyWith(isFavorite: newValue);
    notifyListeners();
  }

  // ───────── ITEMS CRUD ─────────

  Future<void> addItem(String listId, String item) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index == -1) return;

    final currentItems = _lists[index].items;
    await _service.addItem(listId, currentItems, item);

    _lists[index] = _lists[index].copyWith(
      items: List<String>.from(currentItems)..add(item),
    );
    notifyListeners();
  }

  Future<void> renameItem(String listId, int itemIndex, String newName) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index == -1) return;

    final currentItems = _lists[index].items;
    await _service.renameItem(listId, currentItems, itemIndex, newName);

    final updated = List<String>.from(currentItems)..[itemIndex] = newName;
    _lists[index] = _lists[index].copyWith(items: updated);
    notifyListeners();
  }

  Future<void> removeItem(String listId, String item) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index == -1) return;

    final currentItems = _lists[index].items;
    await _service.removeItem(listId, currentItems, item);

    _lists[index] = _lists[index].copyWith(
      items: List<String>.from(currentItems)..remove(item),
    );
    notifyListeners();
  }

  Future<void> removeItemAt(String listId, int itemIndex) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index == -1) return;

    final currentItems = _lists[index].items;
    await _service.removeItemAt(listId, currentItems, itemIndex);

    _lists[index] = _lists[index].copyWith(
      items: List<String>.from(currentItems)..removeAt(itemIndex),
    );
    notifyListeners();
  }

  Future<void> toggleItemChecked(String listId, int itemIndex) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index == -1) return;

    final currentChecked = _lists[index].checkedIndices;
    await _service.toggleItemChecked(
        listId, currentChecked.toList(), itemIndex);

    final updated = Set<int>.from(currentChecked);
    if (updated.contains(itemIndex)) {
      updated.remove(itemIndex);
    } else {
      updated.add(itemIndex);
    }

    _lists[index] = _lists[index].copyWith(checkedIndices: updated);

    // ── Reward hook ───────────────────────────────────────────────────────
    final list = _lists[index];
    if (list.items.isNotEmpty && updated.length == list.items.length) {
      rewardProvider?.onListCompleted();
    }
    // ─────────────────────────────────────────────────────────────────────

    notifyListeners();
  }

  // ───────── CHECK ITEM BY NAME ─────────
  Future<void> checkItemByName(String listId, String itemName) async {
    final previous = _checkLocks[listId] ?? Future.value();
    late Future<void> current;
    current = previous.then((_) => _checkItemByNameLocked(listId, itemName));
    _checkLocks[listId] = current;

    await current;
    if (_checkLocks[listId] == current) {
      _checkLocks.remove(listId);
    }
  }

  Future<void> _checkItemByNameLocked(String listId, String itemName) async {
    final listIndex = _lists.indexWhere((l) => l.id == listId);
    if (listIndex == -1) return;

    final items = _lists[listIndex].items;
    final itemIndex = items.indexWhere(
      (item) => item.toLowerCase().trim() == itemName.toLowerCase().trim(),
    );

    if (itemIndex == -1) {
      debugPrint('checkItemByName: "$itemName" not found in "$listId"');
      return;
    }

    final currentChecked = Set<int>.from(_lists[listIndex].checkedIndices);
    if (currentChecked.contains(itemIndex)) {
      debugPrint('checkItemByName: "$itemName" already checked');
      return;
    }

    currentChecked.add(itemIndex);
    await _service.toggleItemChecked(
        listId, currentChecked.toList(), itemIndex);

    _lists[listIndex] =
        _lists[listIndex].copyWith(checkedIndices: currentChecked);
    notifyListeners();

    debugPrint('checkItemByName: "$itemName" marked as checked ✓');
  }

  // ───────── HELPERS ─────────

  String? listTime(String listId) {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index == -1) return null;
    return _lists[index].time;
  }

  DateTime? listDate(String listId) {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index == -1) return null;
    return _lists[index].date;
  }
}
