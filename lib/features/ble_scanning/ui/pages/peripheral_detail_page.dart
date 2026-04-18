import 'dart:async';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// ─── GATT helpers ────────────────────────────────────────────────────────────

String gssUuid(String code) => '0000$code-0000-1000-8000-00805f9b34fb';

final String gssServBattery = gssUuid('180f');
final String gssCharBatteryLevel = gssUuid('2a19');

const String woodemiSuffix = 'ba5e-f4ee-5ca1-eb1e5e4b1ce0';
const String woodemiServCommand = '57444d01-$woodemiSuffix';
const String woodemiCharCommandRequest = '57444e02-$woodemiSuffix';
const String woodemiCharCommandResponse = woodemiCharCommandRequest;
const int woodemiMtuWuart = 247;

// ─── Page ────────────────────────────────────────────────────────────────────

class PeripheralDetailPage extends StatefulWidget {
  final BluetoothDevice device;

  const PeripheralDetailPage({super.key, required this.device});

  @override
  State<PeripheralDetailPage> createState() => _PeripheralDetailPageState();
}

class _PeripheralDetailPageState extends State<PeripheralDetailPage> {
  // ── Subscriptions ──────────────────────────────────────────────────────
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamSubscription<int>? _mtuSub;
  StreamSubscription<List<int>>? _notifySub;

  // ── Text controllers ───────────────────────────────────────────────────
  final TextEditingController _serviceUUID =
      TextEditingController(text: woodemiServCommand);
  final TextEditingController _characteristicUUID =
      TextEditingController(text: woodemiCharCommandRequest);
  final TextEditingController _binaryCode = TextEditingController(
    text: hex.encode([0x01, 0x0A, 0x00, 0x00, 0x00, 0x01]),
  );

  // ── State ──────────────────────────────────────────────────────────────
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  int _mtu = 23;
  int? _batteryLevel;
  List<BluetoothService> _services = [];
  final List<String> _log = [];

  bool get _isConnected =>
      _connectionState == BluetoothConnectionState.connected;

  @override
  void initState() {
    super.initState();

    _connectionSub =
        widget.device.connectionState.listen((BluetoothConnectionState s) {
      if (!mounted) return;
      setState(() => _connectionState = s);
      _addLog('Connection: $s');
    });

    _mtuSub = widget.device.mtu.listen((int mtu) {
      if (!mounted) return;
      setState(() => _mtu = mtu);
    });

    widget.device.onServicesReset.listen((_) async {
      _addLog('Services reset — rediscovering…');
      await _discoverServices();
    });
  }

  @override
  void dispose() {
    _notifySub?.cancel();
    _connectionSub?.cancel();
    _mtuSub?.cancel();
    _serviceUUID.dispose();
    _characteristicUUID.dispose();
    _binaryCode.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void _addLog(String msg) {
    if (!mounted) return;
    setState(() {
      _log.insert(0, '[${TimeOfDay.now().format(context)}] $msg');
      if (_log.length > 50) _log.removeLast();
    });
  }

  BluetoothCharacteristic? _findCharacteristic(String svcId, String charId) {
    final svcGuid = Guid(svcId);
    final charGuid = Guid(charId);
    for (final svc in _services) {
      if (svc.uuid == svcGuid) {
        for (final c in svc.characteristics) {
          if (c.uuid == charGuid) return c;
        }
      }
    }
    return null;
  }

  // ── BLE actions ────────────────────────────────────────────────────────

  Future<void> _connect() async {
    try {
      await widget.device.connect(
        license: License.free,
        autoConnect: false,
      );
      _addLog('Connected');
    } catch (e) {
      _addLog('Connect error: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await widget.device.disconnect();
      _addLog('Disconnected');
    } catch (e) {
      _addLog('Disconnect error: $e');
    }
  }

  Future<void> _discoverServices() async {
    try {
      final services = await widget.device.discoverServices();
      if (!mounted) return;
      setState(() => _services = services);
      _addLog('Found ${services.length} service(s)');
      for (final svc in services) {
        _addLog('  SVC: ${svc.uuid}');
        for (final c in svc.characteristics) {
          _addLog('    CHR: ${c.uuid}');
        }
      }
    } catch (e) {
      _addLog('Discover error: $e');
    }
  }

  Future<void> _setNotifiable() async {
    final c =
        _findCharacteristic(woodemiServCommand, woodemiCharCommandResponse);
    if (c == null) {
      _addLog('Notify characteristic not found');
      return;
    }

    await _notifySub?.cancel();
    _notifySub = c.onValueReceived.listen((value) {
      _addLog('Notify: ${hex.encode(value)}');
    });
    widget.device.cancelWhenDisconnected(_notifySub!);

    try {
      await c.setNotifyValue(true);
      _addLog('Notifications enabled');
    } catch (e) {
      _addLog('Set notify error: $e');
    }
  }

  Future<void> _send() async {
    final c = _findCharacteristic(
        _serviceUUID.text.trim(), _characteristicUUID.text.trim());
    if (c == null) {
      _addLog('Write characteristic not found');
      return;
    }
    try {
      final value = Uint8List.fromList(hex.decode(_binaryCode.text.trim()));
      await c.write(value, withoutResponse: false);
      _addLog('Write OK: ${hex.encode(value)}');
    } catch (e) {
      _addLog('Write error: $e');
    }
  }

  Future<void> _readBattery() async {
    final c = _findCharacteristic(gssServBattery, gssCharBatteryLevel);
    if (c == null) {
      _addLog('Battery characteristic not found');
      return;
    }
    try {
      final value = await c.read();
      final level = value.isNotEmpty ? value[0] : null;
      if (!mounted) return;
      setState(() => _batteryLevel = level);
      _addLog('Battery: ${level != null ? "$level%" : hex.encode(value)}');
    } catch (e) {
      _addLog('Read battery error: $e');
    }
  }

  Future<void> _requestMtu() async {
    try {
      await widget.device.requestMtu(woodemiMtuWuart);
      _addLog('MTU requested: $woodemiMtuWuart');
    } catch (e) {
      _addLog('MTU error: $e');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.platformName.isNotEmpty
            ? widget.device.platformName
            : widget.device.remoteId.str),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status card ────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatusRow('Connection', _connectionState.name),
                          const SizedBox(height: 4),
                          _StatusRow('MTU', '$_mtu bytes'),
                          if (_batteryLevel != null) ...[
                            const SizedBox(height: 4),
                            _StatusRow('Battery', '$_batteryLevel%'),
                          ],
                          const SizedBox(height: 4),
                          _StatusRow('ID', widget.device.remoteId.str,
                              mono: true),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: _isConnected
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      child: Icon(
                        _isConnected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        color: _isConnected ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Connection buttons ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isConnected ? null : _connect,
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('Connect'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isConnected ? _disconnect : null,
                    icon: const Icon(Icons.link_off, size: 18),
                    label: const Text('Disconnect'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: _isConnected ? _discoverServices : null,
              icon: const Icon(Icons.manage_search, size: 18),
              label: const Text('Discover services'),
            ),
            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: _isConnected ? _setNotifiable : null,
              icon: const Icon(Icons.notifications_active_outlined, size: 18),
              label: const Text('Enable notifications'),
            ),
            const SizedBox(height: 16),

            // ── Write characteristic ───────────────────────────────────
            Text('Write characteristic',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _serviceUUID,
              decoration: const InputDecoration(
                labelText: 'Service UUID',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _characteristicUUID,
              decoration: const InputDecoration(
                labelText: 'Characteristic UUID',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _binaryCode,
              decoration: const InputDecoration(
                labelText: 'Payload (hex)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isConnected ? _send : null,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Send'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isConnected ? _readBattery : null,
                    icon: const Icon(Icons.battery_full, size: 18),
                    label: const Text('Read battery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isConnected ? _requestMtu : null,
              icon: const Icon(Icons.tune, size: 18),
              label: Text('Request MTU ($woodemiMtuWuart)'),
            ),
            const SizedBox(height: 20),

            // ── Log panel ──────────────────────────────────────────────
            Text('Log', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              child: _log.isEmpty
                  ? Text(
                      'No events yet.',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    )
                  : ListView.builder(
                      reverse: false,
                      itemCount: _log.length,
                      itemBuilder: (_, i) => Text(
                        _log[i],
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.green.shade300,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small helpers ────────────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const _StatusRow(this.label, this.value, {this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontFamily: mono ? 'monospace' : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
