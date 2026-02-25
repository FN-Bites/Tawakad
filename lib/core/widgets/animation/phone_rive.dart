import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class PhoneRive extends StatefulWidget {
  const PhoneRive({
    super.key,
    this.fit = Fit.contain,
    this.alignment = Alignment.center,
  });

  final Fit fit;
  final Alignment alignment;

  @override
  State<PhoneRive> createState() => _PhoneRiveState();
}

class _PhoneRiveState extends State<PhoneRive> {
  late final FileLoader _fileLoader = FileLoader.fromAsset(
    'assets/animation/tawakad_phone.riv',
    riveFactory: Factory.rive,
  );

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: _fileLoader,
      builder: (context, state) => switch (state) {
        RiveLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        RiveFailed() => Center(
            child: Text(
              'Phone animation failed:\n${state.error}',
              textAlign: TextAlign.center,
            ),
          ),
        RiveLoaded() => RiveWidget(
            controller: state.controller,
            fit: widget.fit,
          ),
      },
    );
  }
}
