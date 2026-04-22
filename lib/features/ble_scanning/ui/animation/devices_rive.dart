import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class DevicesRive extends StatefulWidget {
  const DevicesRive({super.key});

  @override
  State<DevicesRive> createState() => _DevicesRiveState();
}

class _DevicesRiveState extends State<DevicesRive> {
  late final rive.FileLoader fileLoader = rive.FileLoader.fromAsset(
    'assets/animation/devices.riv',
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
            painter: rive.SingleAnimationPainter(
              'Animation 1',
              fit: rive.Fit.contain,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
