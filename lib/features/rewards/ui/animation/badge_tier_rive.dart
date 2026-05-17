import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

enum BadgeTier { bronze, silver, gold, platinum, diamond }

extension BadgeTierAsset on BadgeTier {
  String get assetPath {
    switch (this) {
      case BadgeTier.bronze:
        return 'assets/animation/badge_bronze.riv';
      case BadgeTier.silver:
        return 'assets/animation/badge_silver.riv';
      case BadgeTier.gold:
        return 'assets/animation/badge_gold.riv';
      case BadgeTier.platinum:
        return 'assets/animation/badge_platinum.riv';
      case BadgeTier.diamond:
        return 'assets/animation/badge_diamond.riv';
    }
  }

  int get requiredCompletions {
    switch (this) {
      case BadgeTier.bronze:
        return 1;
      case BadgeTier.silver:
        return 5;
      case BadgeTier.gold:
        return 15;
      case BadgeTier.platinum:
        return 25;
      case BadgeTier.diamond:
        return 50;
    }
  }
}

class BadgeRiveWidget extends StatefulWidget {
  final BadgeTier tier;
  final double size;

  const BadgeRiveWidget({
    super.key,
    required this.tier,
    this.size = 180,
  });

  @override
  State<BadgeRiveWidget> createState() => _BadgeRiveWidgetState();
}

class _BadgeRiveWidgetState extends State<BadgeRiveWidget> {
  late rive.FileLoader _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = rive.FileLoader.fromAsset(
      widget.tier.assetPath,
      riveFactory: rive.Factory.rive,
    );
  }

  @override
  void didUpdateWidget(BadgeRiveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tier != widget.tier) {
      _fileLoader.dispose();
      _fileLoader = rive.FileLoader.fromAsset(
        widget.tier.assetPath,
        riveFactory: rive.Factory.rive,
      );
    }
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
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (state is rive.RiveFailed) {
            return Center(
              child: Text(
                'Failed: ${state.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is rive.RiveLoaded) {
            return rive.RiveFileWidget(
              file: state.file,
              painter: rive.StateMachinePainter(
                stateMachineName: 'State Machine 1',
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
