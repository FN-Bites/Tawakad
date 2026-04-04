import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SearchRive extends StatefulWidget {
  const SearchRive({
    super.key,
    this.fit = Fit.contain,
    this.alignment = Alignment.center,
  });

  final Fit fit;
  final Alignment alignment;

  @override
  State<SearchRive> createState() => _SearchInRiveState();
}

class _SearchInRiveState extends State<SearchRive> {
  late final FileLoader _fileLoader = FileLoader.fromAsset(
    'assets/animation/searchin.riv',
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
              'Search animation failed:\n${state.error}',
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
