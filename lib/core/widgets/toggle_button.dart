import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToggleRowWidget extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;
  final VoidCallback? onSubtitleTap;

  const ToggleRowWidget({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.onSubtitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: const Color(0xFF1F8EFA), size: 20),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              if (subtitle != null)
                GestureDetector(
                  onTap: onSubtitleTap,
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Color(0xFF1F8EFA),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }
}
