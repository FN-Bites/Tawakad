import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

enum MascotState {
  idle,
  error,
  chat,
  noInternet,
  download,
}

class MascotRive extends StatefulWidget {
  final MascotState state;

  const MascotRive({
    super.key,
    this.state = MascotState.idle,
  });

  @override
  State<MascotRive> createState() => _MascotRiveState();
}

class _MascotRiveState extends State<MascotRive> {
  late final rive.FileLoader fileLoader = rive.FileLoader.fromAsset(
    'assets/animation/toki.riv',
    riveFactory: rive.Factory.rive,
  );

  rive.RiveWidgetController? _controller;
  MascotState? _lastState;

  @override
  void initState() {
    super.initState();
    _lastState = widget.state;
  }

  @override
  void didUpdateWidget(covariant MascotRive oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state != _lastState) {
      _lastState = widget.state;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyState(widget.state);
      });
    }
  }

  void _applyState(MascotState state) {
    final sm = _controller?.stateMachine;
    if (sm == null) return;

    sm.boolean('Error')?.value = false;
    sm.boolean('Chat')?.value = false;
    sm.boolean('No Internet')?.value = false;
    sm.number('Download')?.value = 0;
    sm.boolean('Reset')?.value = false;

    switch (state) {
      case MascotState.idle:
        break;
      case MascotState.error:
        sm.boolean('Error')?.value = true;
        break;
      case MascotState.chat:
        sm.boolean('Chat')?.value = true;
        break;
      case MascotState.noInternet:
        sm.boolean('No Internet')?.value = true;
        break;
      case MascotState.download:
        sm.number('Download')?.value = 1;
        break;
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
        if (state is rive.RiveLoading) {
          return const SizedBox.shrink();
        }

        if (state is rive.RiveFailed) {
          return Text(
            'Rive failed: ${state.error}',
            textAlign: TextAlign.center,
          );
        }

        if (state is rive.RiveLoaded) {
          _controller = state.controller;
          _applyState(widget.state);

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
