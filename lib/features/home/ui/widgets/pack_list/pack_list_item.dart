import 'package:flutter/material.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';
import '../buttons/pack_list_item_count_button.dart';
import 'package:tawakad_app/features/home/ui/pages/pack_list_items_page.dart';

class PackListItem extends StatelessWidget {
  const PackListItem(this.packlist, {super.key});

  final PackList packlist;

  String _toArabicNumerals(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < western.length; i++) {
      input = input.replaceAll(western[i], arabic[i]);
    }
    return input;
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return _toArabicNumerals(time);
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return _toArabicNumerals(time);

    final period = hour < 12 ? 'ص' : 'م';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '${_toArabicNumerals(hour12.toString())}:${_toArabicNumerals(minuteStr)} $period';
  }

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
            PackListItemCountButton(
              itemCount: packlist.itemCount,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PackListItemsPage(listId: packlist.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    if (packlist.date == null && packlist.time == null) {
      return const SizedBox.shrink();
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
          packlist.time != null ? _formatTime(packlist.time!) : '',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
