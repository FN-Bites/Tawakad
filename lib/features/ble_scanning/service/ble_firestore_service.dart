import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BleFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _bleItemsRef() {
    final uid = userId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    return _db.collection('users').doc(uid).collection('ble_items');
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchBleItems() async {
    final snapshot = await _bleItemsRef().get();
    return snapshot.docs;
  }

  Future<void> createBleItem(Map<String, dynamic> data) async {
    await _bleItemsRef().add(data);
  }

  Future<void> editBleItem(String deviceId, Map<String, dynamic> data) async {
    final doc = await _findByDeviceId(deviceId);
    await doc.reference.update(data);
  }

  Future<void> removeBleItem(String deviceId) async {
    final doc = await _findByDeviceId(deviceId);
    await doc.reference.delete();
  }

  Future<void> toggleFavorite(String deviceId, bool isFavorite) async {
    final doc = await _findByDeviceId(deviceId);
    await doc.reference.update({
      'isFavorite': isFavorite,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addListToItem(
    String deviceId,
    List<String> currentListIds,
    String listId,
  ) async {
    final updated = List<String>.from(currentListIds);
    if (!updated.contains(listId)) {
      updated.add(listId);
    }

    final doc = await _findByDeviceId(deviceId);
    await doc.reference.update({
      'listIds': updated,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeListFromItem(
    String deviceId,
    List<String> currentListIds,
    String listId,
  ) async {
    final updated = List<String>.from(currentListIds)..remove(listId);

    final doc = await _findByDeviceId(deviceId);
    await doc.reference.update({
      'listIds': updated,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>> _findByDeviceId(
      String deviceId) async {
    final snapshot = await _bleItemsRef()
        .where('deviceId', isEqualTo: deviceId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      throw Exception('BLE item not found for deviceId: $deviceId');
    }
    return snapshot.docs.first;
  }
}
