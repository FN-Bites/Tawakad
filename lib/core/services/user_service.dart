import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user data after successful registration
  Future<void> saveUserData({
    required User user,
    required String password,
    required List<String> answers,
  }) async {

    final passwordHash = _generatePasswordHash(password);

    await _firestore.collection('users') .doc(user.uid).set({
        "uid": user.uid,
        "email": user.email,
        "passwordHistory": [passwordHash],
        "answers": answers,
        "createdAt": Timestamp.now(),
    });
  }

  Future<String> getUserIdByEmail(String email) async {
    final query = await _firestore
      .collection('users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

    return query.docs.first.id;
  }

  Future<void> checkPasswordReuse({
    required String userId,
    required String newPassword,
  }) async {

    final docRef = _firestore.collection('users').doc(userId);

    final snapshot = await docRef.get();

    final history = snapshot.data()?['passwordHistory'] ?? [];

    final newHash = _generatePasswordHash(newPassword);

    if (history.contains(newHash)) {
      throw Exception('PASSWORD_ALREADY_USED');
    }
  }

  Future<void> updatePasswordHistory({
    required String userId,
    required String newPassword,
  }) async {

    final docRef = _firestore.collection('users').doc(userId);

    final snapshot = await docRef.get();

    List history = snapshot.data()?['passwordHistory'] ?? [];

    final newHash = _generatePasswordHash(newPassword);

    history.add(newHash);

    if (history.length > 5) {
      history = history.sublist(history.length - 5);
    }

    await docRef.update({
      "passwordHistory": history,
    });
  }

  // Hash password before storing in history
  String _generatePasswordHash (String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
