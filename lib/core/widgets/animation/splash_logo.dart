import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SplashRiveBuilder extends StatefulWidget {
  const SplashRiveBuilder({
    super.key,
    this.delay = const Duration(seconds: 5),
  });

  final Duration delay;

  @override
  State<SplashRiveBuilder> createState() => _SplashRiveBuilderState();
}

class _SplashRiveBuilderState extends State<SplashRiveBuilder> {
  late final FileLoader fileLoader = FileLoader.fromAsset(
    'assets/animation/splash.riv',
    riveFactory: Factory.rive,
  );

  bool _showRive = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      setState(() => _showRive = true);
    });
  }

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
        RiveLoaded() => _showRive
            ? RiveWidget(
                controller: state.controller,
                fit: Fit.contain,
              )
            : const SizedBox.shrink(),
      },
    );
  }
}
