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
    final passwordHash = _generatePasswordHash(password, user.email ?? "");

    await _firestore.collection('users').doc(user.uid).set({
      "uid": user.uid,
      "email": user.email,
      "passwordHistory": [passwordHash],
      "answers": answers,
      "createdAt": Timestamp.now(),
    });
  }

  // Update password history after sign in
  Future<void> updatePasswordHistoryIfChanged({
    required String uid,
    required String email,
    required String currentPassword,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(uid);
      final snapshot = await userDoc.get();

      if (snapshot.exists) {
        List<dynamic> history = snapshot.data()?['passwordHistory'] ?? [];
        final String currentHash =
            _generatePasswordHash(currentPassword, email);

        if (history.isEmpty || history.last != currentHash) {
          history.add(currentHash);

          if (history.length > 5) {
            history = history.sublist(history.length - 5);
          }

          await userDoc.update({
            'passwordHistory': history,
          });
          print("✅ Password history updated successfully in Firestore.");
        }
      }
    } catch (e) {
      print("❌ Error updating password history: $e");
    }
  }

  // Hash password before storing in history
  String _generatePasswordHash(String password, String email) {
    final String salt = email.toLowerCase().trim();
    const String secretKey = "Tawakad_Secure";
    final String combinedData = password + salt + secretKey;
    final bytes = utf8.encode(combinedData);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
