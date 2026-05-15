import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _listsRef() {
    if (userId == null) {
      throw Exception("User not logged in");
    }

    return _db.collection('users').doc(userId).collection('lists');
  }

  // ───────── LIST CRUD ─────────

  Future<void> createList(Map<String, dynamic> data) async {
    await _listsRef().add(data);
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchLists() async {
    final snapshot = await _listsRef().get();
    return snapshot.docs;
  }

  Future<void> editList(String listId, Map<String, dynamic> data) async {
    await _listsRef().doc(listId).update(data);
  }

  Future<void> removeList(String listId) async {
    await _listsRef().doc(listId).delete();
  }

  Future<void> toggleFavorite(String listId, bool isFavorite) async {
    await _listsRef().doc(listId).update({'isFavorite': isFavorite});
  }

  // ───────── ITEMS ─────────

  Future<void> _updateItems(String listId, List items) async {
    await _listsRef().doc(listId).update({'items': items});
  }

  Future<void> addItem(String listId, List items, String newItem) async {
    final updated = List.from(items)..add(newItem);
    await _updateItems(listId, updated);
  }

  Future<void> renameItem(
      String listId, List items, int index, String newName) async {
    final updated = List.from(items);
    updated[index] = newName;
    await _updateItems(listId, updated);
  }

  Future<void> removeItem(String listId, List items, String item) async {
    final updated = List.from(items)..remove(item);
    await _updateItems(listId, updated);
  }

  Future<void> removeItemAt(String listId, List items, int index) async {
    final updated = List.from(items)..removeAt(index);
    await _updateItems(listId, updated);
  }

  Future<void> toggleItemChecked(
    String listId,
    List currentChecked,
    int index,
  ) async {
    final updated = Set.from(currentChecked);

    if (updated.contains(index)) {
      updated.remove(index);
    } else {
      updated.add(index);
    }

    await _listsRef().doc(listId).update({'checkedIndices': updated.toList()});
  }
}
