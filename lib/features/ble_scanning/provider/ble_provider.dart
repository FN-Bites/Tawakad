import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ble_item.dart';

class BleProvider extends ChangeNotifier {
  final Map<String, BleItem> _devices = {};
  final List<BleItem> _savedItems = [];

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  Timer? _uiTimer;
  Timer? _watchdog;

  bool _scanning = false;
  bool _checkMode = false;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  final Map<String, String> _mappings = {};

  static const String _prefMapPrefix = 'ble_mapping_';
  static const String _prefMappedItems = 'ble_mapped_items';

  bool get scanning => _scanning;
  bool get checkMode => _checkMode;
  BluetoothAdapterState get adapterState => _adapterState;
  Map<String, String> get mappings => Map.unmodifiable(_mappings);
  List<BleItem> get savedItems => List.unmodifiable(_savedItems);

  List<BleItem> get deviceList => _devices.values.toList()
    ..sort((a, b) => b.smoothedRssi.compareTo(a.smoothedRssi));

  String? mappedDeviceId(String itemName) => _mappings[itemName];

  bool isItemPresent(String itemName, DateTime now) {
    final deviceId = _mappings[itemName];
    if (deviceId == null) return false;
    return _devices[deviceId]?.isPresent(now) ?? false;
  }

  BleItem? deviceForItem(String itemName) {
    final deviceId = _mappings[itemName];
    if (deviceId == null) return null;
    return _devices[deviceId];
  }

  BleProvider() {
    _loadPrefs();
    _listenAdapter();
    _listenScan();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_scanning) notifyListeners();
    });
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _adapterSub?.cancel();
    _uiTimer?.cancel();
    _watchdog?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  // ── Saved Items ──────────────────────────────────────────

  void addSavedItem(BleItem item) {
    _savedItems.add(item);
    notifyListeners();
  }

  void removeSavedItem(String deviceId) {
    _savedItems.removeWhere((i) => i.deviceId == deviceId);
    notifyListeners();
  }

  void toggleFavorite(String deviceId) {
    final index = _savedItems.indexWhere((i) => i.deviceId == deviceId);
    if (index == -1) return;
    _savedItems[index] = _savedItems[index].copyWith(
      isFavorite: !_savedItems[index].isFavorite,
    );
    notifyListeners();
  }

  // ── Prefs ────────────────────────────────────────────────

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final mappedItems = prefs.getStringList(_prefMappedItems) ?? [];
    for (final itemName in mappedItems) {
      final deviceId = prefs.getString('$_prefMapPrefix$itemName');
      if (deviceId != null) _mappings[itemName] = deviceId;
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefMappedItems, _mappings.keys.toList());
    for (final entry in _mappings.entries) {
      await prefs.setString('$_prefMapPrefix${entry.key}', entry.value);
    }
  }

  // ── BLE ──────────────────────────────────────────────────

  void _listenAdapter() {
    _adapterSub = FlutterBluePlus.adapterState.listen((s) {
      _adapterState = s;
      notifyListeners();
    });
  }

  void _listenScan() {
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final now = DateTime.now();
      for (final r in results) {
        if (r.rssi == 127 || r.rssi == -127 || r.rssi == 0) continue;
        final id = r.device.remoteId.str;
        final name = _resolveName(r);
        final existing = _devices[id];
        final smoothed = existing == null
            ? r.rssi.toDouble()
            : existing.smoothedRssi * (1 - kRssiAlpha) + r.rssi * kRssiAlpha;
        _devices[id] = BleItem(
          deviceId: id,
          name: name,
          rssi: r.rssi,
          smoothedRssi: smoothed,
          lastSeen: now,
          iconPath: '',
          colorValue: 0xFF1F8EFA,
        );
      }
      notifyListeners();
    });
  }

  String _resolveName(ScanResult r) {
    final adv = r.advertisementData.advName.trim();
    final pn = r.device.platformName.trim();
    if (adv.isNotEmpty) return adv;
    if (pn.isNotEmpty) return pn;
    return '(Unknown)';
  }

  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return true;
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    return !statuses.values.any((s) => s.isDenied || s.isPermanentlyDenied);
  }

  Future<void> startScan({bool checkMode = false}) async {
    if (_adapterState != BluetoothAdapterState.on) return;
    if (!await _requestPermissions()) return;
    _scanning = true;
    _checkMode = checkMode;
    _devices.clear();
    notifyListeners();
    try {
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(
        androidUsesFineLocation: true,
        androidScanMode: AndroidScanMode.lowLatency,
        continuousUpdates: true,
        continuousDivisor: 1,
      );
      _startWatchdog();
    } catch (e) {
      debugPrint('Scan start failed: $e');
      _scanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    _watchdog?.cancel();
    try {
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('Scan stop error: $e');
    }
    _scanning = false;
    _checkMode = false;
    _devices.clear();
    notifyListeners();
  }

  void _startWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer.periodic(const Duration(seconds: 6), (_) async {
      if (!_scanning) return;
      if (!FlutterBluePlus.isScanningNow) {
        debugPrint('Watchdog: restarting scan…');
        try {
          await FlutterBluePlus.startScan(
            androidUsesFineLocation: true,
            androidScanMode: AndroidScanMode.lowLatency,
            continuousUpdates: true,
            continuousDivisor: 1,
          );
        } catch (e) {
          debugPrint('Watchdog restart failed: $e');
        }
      }
    });
  }

  void mapItem(String itemName, String deviceId) {
    _mappings[itemName] = deviceId;
    _savePrefs();
    notifyListeners();
  }

  void unmapItem(String itemName) {
    _mappings.remove(itemName);
    _savePrefs();
    notifyListeners();
  }

  void onItemRemoved(String itemName) {
    unmapItem(itemName);
  }
}
