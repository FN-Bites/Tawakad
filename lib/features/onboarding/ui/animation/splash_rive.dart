import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SplashRiveBuilder extends StatefulWidget {
  const SplashRiveBuilder({super.key});

  @override
  State<SplashRiveBuilder> createState() => _SplashRiveBuilderState();
}

class _SplashRiveBuilderState extends State<SplashRiveBuilder> {
  late final FileLoader fileLoader = FileLoader.fromAsset(
    'assets/animation/splash.riv',
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
      builder: (context, state) => switch (state) {
        RiveLoading() => const Center(child: CircularProgressIndicator()),
        RiveFailed() => Center(
            child: Text(
              'Rive failed: ${state.error}',
              textAlign: TextAlign.center,
            ),
          ),
        RiveLoaded() => RiveWidget(
            controller: state.controller,
            fit: Fit.contain,
          ),
      },
    );
  }
}
