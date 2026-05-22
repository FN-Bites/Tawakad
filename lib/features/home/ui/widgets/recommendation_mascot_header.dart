import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/animation/mascot_rive.dart';
import 'package:tawakad_app/core/widgets/mascot_speech_bubble.dart';

class RecommendationMascotHeader extends StatefulWidget {
  const RecommendationMascotHeader({super.key});

  @override
  State<RecommendationMascotHeader> createState() =>
      _RecommendationMascotHeaderState();
}

class _RecommendationMascotHeaderState
    extends State<RecommendationMascotHeader> {
  bool _showBubble = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _showBubble = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Center(
        child: SizedBox(
          width: 250,
          height: 160,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                left: 48,
                top: 0,
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: MascotRive(state: MascotState.idle),
                ),
              ),
              if (_showBubble)
                const Positioned(
                  left: 165,
                  top: 85,
                  child: SizedBox(
                    width: 128,
                    child: MascotSpeechBubble(
                      message: 'هذه اقتراحاتي لك بناءً على قائمتك وحدثك!',
                      isError: false,
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
