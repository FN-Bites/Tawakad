import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class ListCompletionRiveWidget extends StatefulWidget {
  final double size;

  const ListCompletionRiveWidget({
    super.key,
    this.size = 200,
  });

  @override
  State<ListCompletionRiveWidget> createState() =>
      _ListCompletionRiveWidgetState();
}

class _ListCompletionRiveWidgetState extends State<ListCompletionRiveWidget> {
  late final rive.FileLoader _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = rive.FileLoader.fromAsset(
      'assets/animation/list_complete.riv',
      riveFactory: rive.Factory.rive,
    );
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: rive.RiveWidgetBuilder(
        fileLoader: _fileLoader,
        builder: (context, state) {
          if (state is rive.RiveLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            );
          }

          if (state is rive.RiveFailed) {
            return const Center(
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 80,
              ),
            );
          }

          if (state is rive.RiveLoaded) {
            return rive.RiveFileWidget(
              file: state.file,
              painter: rive.StateMachinePainter(
                stateMachineName: 'MarkStateMachine',
                fit: rive.Fit.contain,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
