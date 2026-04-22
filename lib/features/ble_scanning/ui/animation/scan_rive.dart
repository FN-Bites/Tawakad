import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class BluetoothScanRive extends StatefulWidget {
  const BluetoothScanRive({super.key});

  @override
  State<BluetoothScanRive> createState() => _BluetoothScanRiveState();
}

class _BluetoothScanRiveState extends State<BluetoothScanRive> {
  late final rive.FileLoader fileLoader = rive.FileLoader.fromAsset(
    'assets/animation/bluetooth_scan.riv',
    riveFactory: rive.Factory.rive,
  );

  @override
  void dispose() {
    fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return rive.RiveWidgetBuilder(
      fileLoader: fileLoader,
      builder: (context, state) {
        if (state is rive.RiveLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is rive.RiveFailed) {
          return Center(
            child: Text(
              'Rive failed: ${state.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state is rive.RiveLoaded) {
          return rive.RiveFileWidget(
            file: state.file,
            painter: rive.StateMachinePainter(
              stateMachineName: 'State Machine 1',
              fit: rive.Fit.contain,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
