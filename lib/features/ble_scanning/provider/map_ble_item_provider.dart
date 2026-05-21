import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

const double kRssiAlpha = 0.08;
const Duration kFreshWindow = Duration(seconds: 6);

class ScannedDevice {
  final String id;
  final String name;
  final int rawRssi;
  double smoothedRssi;
  DateTime lastSeen;
  final int discoveryOrder;

  ScannedDevice({
    required this.id,
    required this.name,
    required this.rawRssi,
    required this.smoothedRssi,
    required this.lastSeen,
    required this.discoveryOrder,
  });

  bool get isFresh => DateTime.now().difference(lastSeen) <= kFreshWindow;
}

class MapBleItemProvider extends ChangeNotifier {
  final Map<String, ScannedDevice> _devices = {};
  int _nextOrder = 0;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  bool _scanning = false;

  Timer? _watchdog;

  BluetoothAdapterState get adapterState => _adapterState;
  bool get scanning => _scanning;
  bool get isBluetoothOn => _adapterState == BluetoothAdapterState.on;

  ScannedDevice? deviceById(String id) => _devices[id];

  List<ScannedDevice> get sortedDevices {
    final list = _devices.values.toList()
      ..sort((a, b) => a.discoveryOrder.compareTo(b.discoveryOrder));
    return list;
  }

  MapBleItemProvider() {
    _listenAdapter();
    _listenScan();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _adapterSub?.cancel();
    _watchdog?.cancel();
    stopScan();
    super.dispose();
  }

  // ── Reset ──────────────────────────────────────────────────────────────

  void reset() {
    _devices.clear();
    _nextOrder = 0;
    _scanning = false;
    notifyListeners();
  }

  // ── Adapter listener ───────────────────────────────────────────────────

  void _listenAdapter() {
    _adapterSub = FlutterBluePlus.adapterState.listen((s) {
      _adapterState = s;
      notifyListeners();
    });
  }

  // ── Scan results listener ──────────────────────────────────────────────

  void _listenScan() {
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final now = DateTime.now();
      bool anyNew = false;

      for (final r in results) {
        if (r.rssi == 127 || r.rssi == -127 || r.rssi == 0) continue;

        final id = r.device.remoteId.str;
        final name = _resolveName(r);
        final ex = _devices[id];

        if (ex == null) {
          _devices[id] = ScannedDevice(
            id: id,
            name: name,
            rawRssi: r.rssi,
            smoothedRssi: r.rssi.toDouble(),
            lastSeen: now,
            discoveryOrder: _nextOrder++,
          );
          anyNew = true;
        } else {
          ex
            ..smoothedRssi =
                ex.smoothedRssi * (1 - kRssiAlpha) + r.rssi * kRssiAlpha
            ..lastSeen = now;
        }
      }

      if (anyNew) notifyListeners();
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

  Future<void> startScan() async {
    if (!isBluetoothOn) return;
    if (!await _requestPermissions()) return;

    _devices.clear();
    _nextOrder = 0;
    _scanning = true;
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
    } catch (_) {}
    _scanning = false;
    notifyListeners();
  }

  void _startWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer.periodic(const Duration(seconds: 6), (_) async {
      if (!_scanning) return;
      if (!FlutterBluePlus.isScanningNow) {
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
}
