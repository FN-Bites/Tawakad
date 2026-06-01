import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tawakad_app/firebase_options.dart';
import 'package:tawakad_app/features/ble_scanning/model/ble_item.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_item_provider.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_provider.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final email = 'ble_${DateTime.now().millisecondsSinceEpoch}@gmail.com';

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: 'Test@123',
    );
  });

  test('BLE CRUD Flow', () async {
    final bleProvider = BleProvider();
    final packListProvider = PackListProvider();

    final bleItemProvider = BleItemProvider(bleProvider, packListProvider);

    final testItem = BleItem(
      name: 'Test BLE Device',
      deviceId: 'TEST_DEVICE_001',
      rssi: -60,
      smoothedRssi: -60,
      lastSeen: DateTime.now(),
      listIds: [],
      isFavorite: false,
    );

// Create
    await bleItemProvider.addSavedItem(testItem);

    await bleItemProvider.fetchBleItems();

    expect(
      bleItemProvider.savedItems.any(
        (e) => e.deviceId == testItem.deviceId,
      ),
      true,
    );

// Update
    await bleItemProvider.updateSavedItem(
      testItem.copyWith(
        name: 'Updated BLE Device',
      ),
    );

    await bleItemProvider.fetchBleItems();

    expect(
      bleItemProvider.savedItems.any(
        (e) => e.name == 'Updated BLE Device',
      ),
      true,
    );

// Delete
    await bleItemProvider.removeSavedItem(
      testItem.deviceId,
    );

    await bleItemProvider.fetchBleItems();

    expect(
      bleItemProvider.savedItems.any(
        (e) => e.deviceId == testItem.deviceId,
      ),
      false,
    );
  });

  tearDownAll(() async {
    await FirebaseAuth.instance.currentUser?.delete();
  });
}
