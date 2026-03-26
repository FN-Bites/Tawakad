import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tawakad_app/features/home/ui/pages/pack_list.dart';
import '../buttons/pack_list_icon_badge.dart';
import '../buttons/pack_list_item_count_button.dart';

class PackListItem extends StatelessWidget {
  const PackListItem(this.packlist, {super.key});

  final PackList packlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: packlist.cardTheme.gradient,
        boxShadow: [
          BoxShadow(
            color: packlist.cardTheme.shadowColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const PackListIconBadge(
              icon: Icons.fitness_center_rounded,
              iconColor: Colors.white,
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
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        packlist.formattedDate,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
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
}
