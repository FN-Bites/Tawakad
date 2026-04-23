import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/ble_item.dart';
import '../../../core/services/ble_background_service.dart';

class BleProvider extends ChangeNotifier with WidgetsBindingObserver {
  final Map<String, BleItem> _devices = {};

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  Timer? _uiTimer;

  bool _scanning = false;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  bool get scanning => _scanning;
  BluetoothAdapterState get adapterState => _adapterState;

  List<BleItem> get deviceList => _devices.values.toList()
    ..sort((a, b) => b.smoothedRssi.compareTo(a.smoothedRssi));

  bool isDevicePresent(String deviceId) =>
      _devices[deviceId]?.isPresent(DateTime.now()) ?? false;

  BleItem? deviceById(String deviceId) => _devices[deviceId];

  BleProvider() {
    WidgetsBinding.instance.addObserver(this);
    _listenAdapter();
    _listenScan();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_scanning) notifyListeners();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanSub?.cancel();
    _adapterSub?.cancel();
    _uiTimer?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  // ── App lifecycle ─────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scanning) return;
    if (!Platform.isAndroid) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _handOffToBackground();
      case AppLifecycleState.resumed:
        _reclaimFromBackground();
      default:
        break;
    }
  }

  Future<void> _handOffToBackground() async {
    try {
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
    } catch (_) {}
    await BleBackgroundService.start();
    debugPrint('BleProvider: handed off to background service');
  }

  Future<void> _reclaimFromBackground() async {
    await BleBackgroundService.stop();
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      await FlutterBluePlus.startScan(
        androidUsesFineLocation: true,
        androidScanMode: AndroidScanMode.lowLatency,
        continuousUpdates: true,
        continuousDivisor: 1,
      );
    } catch (e) {
      debugPrint('BleProvider: reclaim scan failed: $e');
    }
    debugPrint('BleProvider: reclaimed scan from background service');
  }

  // ── Scanning ──────────────────────────────────────────────────────────

  Future<void> startScan() async {
    if (_adapterState != BluetoothAdapterState.on) return;
    if (!await _requestPermissions()) return;
    _scanning = true;
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
    } catch (e) {
      debugPrint('Scan start failed: $e');
      _scanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    await BleBackgroundService.stop();
    try {
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('Scan stop error: $e');
    }
    _scanning = false;
    _devices.clear();
    notifyListeners();
  }

  Future<Map<String, bool>> probeMultipleDevices(
    List<String> deviceIds, {
    Duration listenDuration = const Duration(seconds: 20),
  }) async {
    final results = {for (final id in deviceIds) id: false};
    final bestRssi = {for (final id in deviceIds) id: -999};

    if (_adapterState != BluetoothAdapterState.on) {
      debugPrint('probeMultipleDevices: BT adapter is off, aborting.');
      return results;
    }
    if (!await _requestPermissions()) {
      debugPrint('probeMultipleDevices: permissions denied, aborting.');
      return results;
    }

    StreamSubscription<List<ScanResult>>? sub;

    Future<void> cleanup() async {
      await sub?.cancel();
      try {
        if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
      } catch (_) {}
    }

    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final probeStarted = DateTime.now();

      sub = FlutterBluePlus.scanResults.listen((scanResults) {
        for (final r in scanResults) {
          final id = r.device.remoteId.str;
          if (!deviceIds.contains(id)) continue;
          if (r.timeStamp.isBefore(probeStarted)) {
            debugPrint('probeMultipleDevices: skipping stale result for $id');
            continue;
          }

          final rssi = r.rssi;
          if (rssi == 127 || rssi == -127 || rssi == 0) continue;

          if (rssi > (bestRssi[id] ?? -999)) {
            bestRssi[id] = rssi;
            debugPrint('probe: $id best rssi now $rssi');
          }
        }
      });

      await FlutterBluePlus.startScan(
        androidUsesFineLocation: true,
        androidScanMode: AndroidScanMode.lowLatency,
        continuousUpdates: true,
        continuousDivisor: 1,
      );

      debugPrint('probeMultipleDevices: scan started, listening for '
          '${deviceIds.join(", ")} for ${listenDuration.inSeconds}s…');

      await Future.delayed(listenDuration);
    } catch (e) {
      debugPrint('probeMultipleDevices error: $e');
    } finally {
      await cleanup();
    }

    for (final id in deviceIds) {
      results[id] = (bestRssi[id] ?? -999) >= kPresenceRssi;
      debugPrint('probe final: $id rssi=${bestRssi[id]} → '
          '${results[id]! ? "PRESENT ✓" : "ABSENT ✗"}');
    }

    return results;
  }

  // ── Internals ─────────────────────────────────────────────────────────

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
        final existing = _devices[id];
        final smoothed = existing == null
            ? r.rssi.toDouble()
            : existing.smoothedRssi * (1 - kRssiAlpha) + r.rssi * kRssiAlpha;
        _devices[id] = BleItem(
          deviceId: id,
          name: _resolveName(r),
          rssi: r.rssi,
          smoothedRssi: smoothed,
          lastSeen: now,
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
}
