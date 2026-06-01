import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tawakad_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late UserCredential userCredential;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final email = 'packlist_${DateTime.now().millisecondsSinceEpoch}@gmail.com';

    userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: 'Test@123',
    );
  });

  test('Packlist CRUD Flow', () async {
    final packlistProvider = PackListProvider();

    await packlistProvider.createList(
      title: 'Integration Test Packlist',
      iconPath: 'assets/icons/travel.png',
      color: Colors.blue,
      isFavorite: false,
      items: ['Passport', 'Phone'],
    );

    // Read
    await packlistProvider.fetchLists();

    final createdPacklist = packlistProvider.lists.firstWhere(
      (p) => p.title == 'Integration Test Packlist',
    );

    expect(
      createdPacklist.title,
      'Integration Test Packlist',
    );

    // Update
    await packlistProvider.editList(
      id: createdPacklist.id,
      title: 'Updated Packlist',
      iconPath: createdPacklist.iconPath,
      color: Color(createdPacklist.colorValue),
      isFavorite: createdPacklist.isFavorite,
    );

    // Reload
    await packlistProvider.fetchLists();

    final updatedPacklist = packlistProvider.lists.firstWhere(
      (p) => p.id == createdPacklist.id,
    );

    expect(
      updatedPacklist.title,
      'Updated Packlist',
    );

    // Delete
    await packlistProvider.removeList(
      createdPacklist.id,
    );

    // Verify deletion
    await packlistProvider.fetchLists();

    expect(
      packlistProvider.lists.any(
        (p) => p.id == createdPacklist.id,
      ),
      false,
    );
  });

  tearDownAll(() async {
    await userCredential.user?.delete();
  });
}
