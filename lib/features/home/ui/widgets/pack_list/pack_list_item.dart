import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';
import '../buttons/pack_list_item_count_button.dart';

class PackListItem extends StatelessWidget {
  const PackListItem(this.packlist, {super.key});

  final PackList packlist;
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
    final color = packlist.color;
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
                  packlist.iconPath,
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
                    packlist.title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildDateTimeRow(),
                ],
              ),
            ),
            const SizedBox(width: 12),
            PackListItemCountButton(itemCount: packlist.itemCount),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    if (packlist.date == null && packlist.time == null) {
      return const SizedBox.shrink();
    }

    final parts = <String>[];

    if (packlist.date != null) {
      final d = packlist.date!;
      parts.add('${d.year}/${d.month}/${d.day}');
    }

    if (packlist.time != null) {
      parts.add(packlist.time!);
    }

    return Row(
      children: [
        const Icon(
          Icons.access_time_rounded,
          color: Colors.white,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          parts.join('  '),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
