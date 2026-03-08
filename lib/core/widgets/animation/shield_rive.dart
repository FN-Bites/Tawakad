import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class ShieldRive extends StatefulWidget {
  const ShieldRive({super.key});

  @override
  State<ShieldRive> createState() => _ShieldRiveState();
}

class _ShieldRiveState extends State<ShieldRive> {
  late final rive.FileLoader fileLoader = rive.FileLoader.fromAsset(
    'assets/animation/shield.riv',
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
        if (state is rive.RiveLoading) return const SizedBox.shrink();
        if (state is rive.RiveFailed) return const SizedBox.shrink();

        if (state is rive.RiveLoaded) {
          return rive.RiveWidget(
            controller: state.controller,
            fit: rive.Fit.contain,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
