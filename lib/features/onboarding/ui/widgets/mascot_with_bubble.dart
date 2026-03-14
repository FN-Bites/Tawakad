import 'package:flutter/material.dart';
import 'package:tawakad_app/features/onboarding/ui/animation/mascot_rive.dart';
import 'mascot_speech_bubble.dart';

class MascotWithBubble extends StatelessWidget {
  const MascotWithBubble({
    super.key,
    required this.mascotState,
    required this.message,
    this.isError = false,
    this.showBubble = true,
  });

  final MascotState mascotState;
  final String message;
  final bool isError;
  final bool showBubble;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Center(
        child: SizedBox(
          width: 250,
          height: 400,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 48,
                top: 0,
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: MascotRive(state: mascotState),
                ),
              ),
              if (showBubble)
                Positioned(
                  left: 165,
                  top: 85,
                  child: SizedBox(
                    width: 128,
                    child: MascotSpeechBubble(
                      message: message,
                      isError: isError,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
