import 'dart:ui';
import 'package:flutter/material.dart';

class PackListItemCountButton extends StatelessWidget {
  const PackListItemCountButton({
    super.key,
    required this.itemCount,
    this.onTap,
  });

  final int itemCount;
  final VoidCallback? onTap;

  String _toArabicNumerals(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < western.length; i++) {
      input = input.replaceAll(western[i], arabic[i]);
    }
    return input;
  }

  String _itemLabel() {
    if (itemCount == 1) return '${_toArabicNumerals('1')} غرض واحد';
    if (itemCount == 2) return '${_toArabicNumerals('2')} غرضان';
    if (itemCount <= 10)
      return '${_toArabicNumerals(itemCount.toString())} أغراض';
    return '${_toArabicNumerals(itemCount.toString())} غرض';
  }

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
              color: Colors.white.withOpacity(0.18),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 2),
                Text(
                  _itemLabel(),
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
            ),
          ),
        ),
      ),
    );
  }
}
