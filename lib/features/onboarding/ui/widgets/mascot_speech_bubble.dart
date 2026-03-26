import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

class MascotSpeechBubble extends StatelessWidget {
  const MascotSpeechBubble({
    super.key,
    required this.message,
    this.isError = false,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    if (isError) return const SizedBox.shrink();

    final textStyle = Theme.of(context).textTheme.labelSmall!;

    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.speechBubble,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          topLeft: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(color: AppColors.speechBubble),
        ],
      ),
      child: DefaultTextStyle(
        style: textStyle,
        textAlign: TextAlign.right,
        child: AnimatedTextKit(
          key: ValueKey(message),
          isRepeatingAnimation: false,
          totalRepeatCount: 1,
          animatedTexts: [
            TyperAnimatedText(
              message,
              speed: const Duration(milliseconds: 45),
            ),
          ],
        ),
      ),
    );
  }
}
