import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Loads and displays the Rive animation for the onboarding lists screen,
class LogoGlitterRive extends StatefulWidget {
  const LogoGlitterRive({super.key});

  @override
  State<LogoGlitterRive> createState() => _LogoGlitterRiveState();
}

class _LogoGlitterRiveState extends State<LogoGlitterRive> {
  late final FileLoader fileLoader = FileLoader.fromAsset(
    'assets/animation/logo_glitter.riv',
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
