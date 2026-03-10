import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularRevealRoute<T> extends PageRouteBuilder<T> {
  CircularRevealRoute({
    required Widget page,
    this.centerAlignment = Alignment.center,
    this.duration = const Duration(milliseconds: 700),
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;

                final center = centerAlignment.alongSize(size);
                final maxRadius = math.sqrt(
                  math.pow(math.max(center.dx, size.width - center.dx), 2) +
                      math.pow(math.max(center.dy, size.height - center.dy), 2),
                );

                return ClipPath(
                  clipper: _CircularRevealClipper(
                    center: center,
                    radius: Tween<double>(begin: 0, end: maxRadius)
                        .animate(curved)
                        .value,
                  ),
                  child: child,
                );
              },
            );
          },
        );

  final Alignment centerAlignment;
  final Duration duration;
}

class _CircularRevealClipper extends CustomClipper<Path> {
  _CircularRevealClipper({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant _CircularRevealClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
