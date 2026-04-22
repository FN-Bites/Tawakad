import 'package:flutter/material.dart';

import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/ble_scanning/provider/map_ble_item_provider.dart';
import 'rssi_bars.dart';

class BleDeviceCard extends StatelessWidget {
  final ScannedDevice device;
  final bool isSelected;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;

  const BleDeviceCard({
    super.key,
    required this.device,
    required this.isSelected,
    required this.isDark,
    required this.accent,
    required this.onTap,
  });

  Color _rssiColor(double rssi) {
    if (rssi >= -60) return Colors.green.shade600;
    if (rssi >= -75) return Colors.orange.shade600;
    return Colors.red.shade400;
  }

  int _rssiBars(double rssi) {
    if (rssi >= -55) return 4;
    if (rssi >= -65) return 3;
    if (rssi >= -75) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppDarkColors.surface : Colors.white;
    final bars = _rssiBars(device.smoothedRssi);
    final rssiClr = _rssiColor(device.smoothedRssi);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.08) : cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? accent
                : isDark
                    ? AppDarkColors.fieldBorder
                    : const Color(0xFFE5E5EA),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // ── Selection circle ─────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? accent : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? accent
                            : isDark
                                ? AppDarkColors.placeholder
                                : const Color(0xFFB0B0B8),
                        width: 1.8,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // ── Bluetooth icon ───────────────────────────────────
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accent.withOpacity(0.12)
                          : isDark
                              ? AppDarkColors.fieldBorder
                              : const Color(0xFFF0F0F5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bluetooth_rounded,
                      size: 18,
                      color: isSelected
                          ? accent
                          : isDark
                              ? AppDarkColors.icon
                              : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Name + ID ────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? accent
                                : isDark
                                    ? AppDarkColors.textPrimary
                                    : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          device.id.length > 17
                              ? device.id.substring(0, 17).toUpperCase()
                              : device.id.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: isDark
                                ? AppDarkColors.placeholder
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── RSSI + bars ──────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${device.smoothedRssi.round()} dBm',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: device.isFresh ? rssiClr : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RssiBars(bars: bars, color: rssiClr),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
