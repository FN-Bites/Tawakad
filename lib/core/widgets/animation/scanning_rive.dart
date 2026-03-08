import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class ScanningRive extends StatefulWidget {
  const ScanningRive({super.key});

  @override
  State<ScanningRive> createState() => _ScanningRiveState();
}

class _ScanningRiveState extends State<ScanningRive> {
  late final FileLoader fileLoader = FileLoader.fromAsset(
    'assets/animation/scanning.riv',
    riveFactory: Factory.rive,
  );

  @override
  void dispose() {
    fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: fileLoader,
      builder: (context, state) {
        if (state is RiveLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is RiveFailed) {
          return Center(
            child: Text(
              'Rive failed: ${state.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state is RiveLoaded) {
          return RiveWidget(
            controller: state.controller,
            fit: Fit.contain,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
