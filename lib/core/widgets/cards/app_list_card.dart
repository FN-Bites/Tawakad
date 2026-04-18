import 'package:flutter/material.dart';

class AppListCard extends StatelessWidget {
  final Color color;
  final String iconPath;
  final String title;
  final Widget? subtitle;
  final Widget? trailing;
  const AppListCard({
    super.key,
    required this.color,
    required this.iconPath,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  LinearGradient _buildGradient(Color base) {
    final hsl = HSLColor.fromColor(base);
    final lighter =
        hsl.withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0)).toColor();
    final darker =
        hsl.withLightness((hsl.lightness - 0.08).clamp(0.0, 1.0)).toColor();
    return LinearGradient(
      colors: [lighter, darker],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _buildGradient(color);
    final shadow = color.withOpacity(0.4);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                width: 48,
                height: 48,
                color: Colors.white.withOpacity(0.2),
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  iconPath,
                  color: Colors.white,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.list_alt_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    subtitle!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
