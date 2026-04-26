import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/ble_scanning/model/ble_item.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_provider.dart';
import 'package:tawakad_app/features/ble_scanning/ui/pages/create_ble_item.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';

class BleItemDetailPage extends StatelessWidget {
  final BleItem item;
  final VoidCallback? onItemSaved;

  const BleItemDetailPage({
    super.key,
    required this.item,
    this.onItemSaved,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allLists = context.watch<PackListProvider>().lists;
    final ble = context.watch<BleProvider>();
    final liveDevice = ble.deviceById(item.deviceId);
    final deviceName =
        (liveDevice?.name.isNotEmpty == true) ? liveDevice!.name : item.name;

    final affiliated =
        allLists.where((l) => item.listIds.contains(l.id)).toList();

    final bgColor = isDark ? AppDarkColors.background : const Color(0xFFF1F4F8);
    final cardBg = isDark ? AppDarkColors.surface : Colors.white;
    final textColor = isDark ? AppDarkColors.textPrimary : Colors.black87;
    final subColor =
        isDark ? AppDarkColors.placeholder : const Color(0xFF8A8A8E);
    final divColor =
        isDark ? AppDarkColors.fieldBorder : const Color(0xFFEEEEF0);
    final closeBtnBg = isDark ? AppDarkColors.surface : const Color(0xFFF0F0F3);
    final closeBtnIconColor = isDark ? AppDarkColors.icon : Colors.black87;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close button (right in RTL = visual right)
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: closeBtnBg,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(isDark ? 0.3 : 0.07),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: closeBtnIconColor,
                          size: 22,
                        ),
                      ),
                    ),
                    // Title
                    Text(
                      'تفاصيل الغرض',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark ? AppDarkColors.textPrimary : null,
                          ),
                    ),
                    // Edit pill button (left in RTL = visual left)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateBleItemPage(
                            existing: item,
                            // Pass onItemSaved directly — do NOT wrap it with
                            // a Navigator.maybePop here. BleReminderPage owns
                            // the full navigation after the edit cycle completes
                            // and will pop back to the BLE page on its own.
                            onItemSaved: onItemSaved,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F8EFA),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1F8EFA).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'تعديل الغرض',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable content ───────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Item header card ─────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(isDark ? 0.25 : 0.07),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: item.color.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: item.color,
                                child: Image.asset(
                                  item.iconPath,
                                  width: 32,
                                  height: 32,
                                  color: Colors.white,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.category_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                  if (item.isFavorite) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.star_rounded,
                                            size: 13,
                                            color: Colors.amber.shade500),
                                        const SizedBox(width: 4),
                                        Text(
                                          'مفضّل',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.amber.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ── Device info ──────────────────────────────
                      _SectionTitle('معلومات الجهاز', subColor),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(isDark ? 0.25 : 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _InfoTile(
                              icon: Icons.bluetooth_rounded,
                              iconColor: const Color(0xFF1F8EFA),
                              label: 'اسم الجهاز',
                              value: deviceName,
                              textColor: textColor,
                              subColor: subColor,
                              divColor: divColor,
                            ),
                            _InfoTile(
                              icon: Icons.fingerprint_rounded,
                              iconColor: subColor,
                              label: 'معرّف الجهاز',
                              value: item.deviceId,
                              mono: true,
                              textColor: textColor,
                              subColor: subColor,
                              divColor: divColor,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ── Reminder info ────────────────────────────
                      if (item.reminderMinutesBefore != null) ...[
                        _SectionTitle('الفحص التلقائي', subColor),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(isDark ? 0.25 : 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _InfoTile(
                            icon: Icons.alarm_rounded,
                            iconColor: item.color,
                            label: 'وقت الفحص',
                            value: item.reminderMinutesBefore == 0
                                ? 'عند الوقت تماماً'
                                : 'قبل ${item.reminderMinutesBefore} دقيقة',
                            textColor: textColor,
                            subColor: subColor,
                            divColor: divColor,
                            isLast: true,
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],

                      // ── Affiliated lists ─────────────────────────
                      _SectionTitle('القوائم المرتبطة', subColor),
                      const SizedBox(height: 10),
                      if (affiliated.isEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'لا توجد قوائم مرتبطة',
                              style: TextStyle(color: subColor, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(isDark ? 0.25 : 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: affiliated.asMap().entries.map((entry) {
                              final i = entry.key;
                              final list = entry.value;
                              final isLast = i == affiliated.length - 1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: list.color,
                                          child: Image.asset(
                                            list.iconPath,
                                            width: 18,
                                            height: 18,
                                            color: Colors.white,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                              Icons.list_alt_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            list.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                        if (list.time != null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 12,
                                                color: subColor,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                list.time!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: subColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                        color: divColor),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 28),
                    ],
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

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionTitle(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color textColor;
  final Color subColor;
  final Color divColor;
  final bool mono;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.textColor,
    required this.subColor,
    required this.divColor,
    this.mono = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: subColor),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: mono ? 'monospace' : null,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 16, endIndent: 16, color: divColor),
      ],
    );
  }
}
