import 'package:flutter/material.dart';

class RightToLeftPageTransitionsBuilder extends PageTransitionsBuilder {
  const RightToLeftPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.isFirst) return child;

    final tween = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
