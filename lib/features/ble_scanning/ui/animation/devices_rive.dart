import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class DevicesRive extends StatefulWidget {
  final bool isDark;

  const DevicesRive({super.key, this.isDark = false});

  @override
  State<DevicesRive> createState() => _DevicesRiveState();
}

class _DevicesRiveState extends State<DevicesRive> {
  late rive.FileLoader fileLoader;

  @override
  void initState() {
    super.initState();
    _initLoader();
  }

  void _initLoader() {
    fileLoader = rive.FileLoader.fromAsset(
      widget.isDark
          ? 'assets/animation/devices_dark.riv'
          : 'assets/animation/devices.riv',
      riveFactory: rive.Factory.rive,
    );
  }

  @override
  void didUpdateWidget(DevicesRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      fileLoader.dispose();
      _initLoader();
      setState(() {});
    }
  }

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
          return const Center(child: CircularProgressIndicator());
        }
        if (state is rive.RiveFailed) {
          return Center(
            child: Text('Rive failed: ${state.error}',
                textAlign: TextAlign.center),
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
