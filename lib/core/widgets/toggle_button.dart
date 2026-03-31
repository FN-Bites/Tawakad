import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color circleColor;
  final bool switchValue;
  final ValueChanged<bool> onChanged;
  final Widget? child;

  const ToggleButton({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.circleColor,
    required this.switchValue,
    required this.onChanged,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
  padding: const EdgeInsets.all(2),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: const Color(0xFFF2F2F7), // خلفية iOS
  ),
  child: Transform.scale(
    scale: 0.9,
    child: CupertinoSwitch(
      value: switchValue,
      onChanged: onChanged,
      activeTrackColor: const Color(0xFF34C759),
      trackColor: const Color(0xFFE5E5EA),
    ),
  ),
),
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5E5EA),
                ),
                child: Icon(
                  widgetIcon(icon),
                  color: const Color(0xFF8E8E93),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5AC8FA),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CupertinoSwitch(
                value: switchValue,
                onChanged: onChanged,
                activeTrackColor: const Color(0xFF34C759),
              ),
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: 14),
            child!,
          ],
        ],
      ),
    );
  }

  IconData widgetIcon(IconData value) => value;
}
