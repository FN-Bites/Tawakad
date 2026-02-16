import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class MascotRive extends StatefulWidget {
  final bool showError;

  const MascotRive({super.key, required this.showError});

  @override
  State<MascotRive> createState() => _MascotRiveState();
}

class _MascotRiveState extends State<MascotRive> {
  late final rive.FileLoader fileLoader = rive.FileLoader.fromAsset(
    'assets/toki.riv',
    riveFactory: rive.Factory.rive,
  );

  rive.RiveWidgetController? _controller;
  bool _last = false;

  @override
  void initState() {
    super.initState();
    _last = widget.showError;
  }

  @override
  void didUpdateWidget(covariant MascotRive oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showError != _last) {
      _last = widget.showError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller?.stateMachine.boolean('Error')?.value = _last;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return rive.RiveWidgetBuilder(
      fileLoader: fileLoader,
      builder: (context, state) {
        if (state is rive.RiveLoading) return const SizedBox.shrink();
        if (state is rive.RiveFailed)
          return Text('Rive failed: ${state.error}');

        if (state is rive.RiveLoaded) {
          _controller = state.controller;
          _controller?.stateMachine.boolean('Error')?.value = widget.showError;

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
