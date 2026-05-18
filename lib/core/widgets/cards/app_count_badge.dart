import 'dart:ui';
import 'package:flutter/material.dart';

class AppCountBadge extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isCompleted;

  const AppCountBadge({
    super.key,
    required this.label,
    this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isCompleted
                  ? const Color.fromARGB(255, 160, 218, 168).withOpacity(0.70)
                  : Colors.white.withOpacity(0.18),
              border: Border.all(
                color: isCompleted
                    ? Colors.green.withOpacity(0.5)
                    : Colors.white.withOpacity(0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCompleted) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.greenAccent,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'مكتملة',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
