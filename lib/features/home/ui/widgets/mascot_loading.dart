import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/animation/mascot_rive.dart';

class MascotLoading extends StatefulWidget {
  final Future<void>? workFuture;
  final VoidCallback? onDone;

  const MascotLoading({
    super.key,
    this.workFuture,
    this.onDone,
  });

  @override
  State<MascotLoading> createState() => _MascotLoadingState();
}

class _MascotLoadingState extends State<MascotLoading> {
  static const _minDuration = Duration(milliseconds: 3000);

  @override
  void initState() {
    super.initState();
    _waitAndDone();
  }

  Future<void> _waitAndDone() async {
    final futures = <Future<void>>[
      Future.delayed(_minDuration),
      if (widget.workFuture != null) widget.workFuture!,
    ];
    await Future.wait(futures);
    if (mounted) widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 220,
            height: 220,
            child: MascotRive(state: MascotState.chat),
          ),
          const SizedBox(height: 40),
          Text(
            'جاري تجهيز الاقتراحات…',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppDarkColors.placeholder
                      : const Color(0xFF8A8A8E),
                ),
          ),
        ],
      ),
    );
  }
}
