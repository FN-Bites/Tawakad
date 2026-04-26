import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/ble_scanning/model/ble_item.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_item_provider.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';

class BleReminderPage extends StatefulWidget {
  final BleItem item;
  final String listId;
  final String checklistItemName;
  final VoidCallback? onItemSaved;
  final bool isEditing;

  const BleReminderPage({
    super.key,
    required this.item,
    required this.listId,
    required this.checklistItemName,
    this.onItemSaved,
    this.isEditing = false,
  });

  @override
  State<BleReminderPage> createState() => _BleReminderPageState();
}

class _BleReminderPageState extends State<BleReminderPage> {
  static const List<int> _minuteOptions = [5, 10, 15, 20, 25, 30];

  int _selected = 0;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _accent => widget.item.color;

  /// Converts a Western Arabic integer to Eastern Arabic-Indic numeral string.
  String _toArabicNumerals(int number) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) {
      final idx = western.indexOf(d);
      return idx != -1 ? eastern[idx] : d;
    }).join();
  }

  @override
  void initState() {
    super.initState();
    _selected = widget.item.reminderMinutesBefore ?? 0;
  }

  void _save() {
    final bleItems = context.read<BleItemProvider>();
    final packLists = context.read<PackListProvider>();

    final updatedItem = widget.item.copyWith(
      reminderMinutesBefore: _selected,
    );

    if (widget.isEditing) {
      bleItems.updateSavedItem(updatedItem);
    } else {
      bleItems.addSavedItem(updatedItem);
    }

    final targetListIds =
        updatedItem.listIds.isNotEmpty ? updatedItem.listIds : [widget.listId];

    for (final listId in targetListIds) {
      final list = packLists.lists.firstWhere(
        (l) => l.id == listId,
        orElse: () => packLists.lists.firstWhere((l) => l.id == widget.listId),
      );
      final listTime = list.time;
      if (listTime != null) {
        bleItems.scheduleAutoScan(
          item: updatedItem,
          listId: listId,
          checklistItemName: widget.checklistItemName,
          minutesBefore: _selected,
          listTime: listTime,
          listDate: list.date,
        );
      }
    }

    widget.onItemSaved?.call();
    final navigator = Navigator.of(context);
    if (widget.isEditing) {
      navigator.pop(); // ReminderPage
      navigator.pop(); // MapBleItemPage
      navigator.pop(); // DetailPage
    } else {
      navigator.pop(); // ReminderPage
      navigator.pop(); // MapBleItemPage
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listTime = context.watch<PackListProvider>().listTime(widget.listId);
    final bgColor =
        _isDark ? AppDarkColors.background : const Color(0xFFF1F4F8);
    final cardBg = _isDark ? AppDarkColors.surface : Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'توقيت الفحص التلقائي',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _isDark ? AppDarkColors.textPrimary : null,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          iconColor:
                              _isDark ? AppDarkColors.icon : Colors.black87,
                          bg: _isDark
                              ? AppDarkColors.surface
                              : const Color(0xFFF0F0F3),
                          onTap: () => Navigator.maybePop(context),
                        ),
                        _CircleBtn(
                          icon: Icons.check_rounded,
                          iconColor: Colors.white,
                          bg: _accent,
                          onTap: _save,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isDark ? 0.2 : 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: _accent,
                        child: Image.asset(
                          widget.item.iconPath,
                          width: 30,
                          height: 30,
                          color: Colors.white,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.category_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.checklistItemName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _isDark
                                    ? AppDarkColors.textPrimary
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 13,
                                  color: listTime != null
                                      ? _accent
                                      : Colors.orange.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  listTime != null
                                      ? 'وقت القائمة: $listTime'
                                      : 'القائمة ليس لها وقت محدد',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: listTime != null
                                        ? _accent
                                        : Colors.orange.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'متى يتم فحص الغرض تلقائياً؟',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isDark
                          ? AppDarkColors.placeholder
                          : const Color(0xFF8A8A8E),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    listTime != null
                        ? 'سيبدأ الفحص تلقائياً في الوقت المحدد.\n'
                            'إذا كانت الإشارة قريبة، سيتم تحديد الغرض تلقائياً ✓'
                        : 'أضف وقتاً للقائمة لتفعيل الفحص التلقائي.\n'
                            'يمكنك حفظ التفضيل الآن وسيعمل عند إضافة الوقت.',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: _isDark
                          ? AppDarkColors.placeholder
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _ExactTimeCard(
                  accent: _accent,
                  listTime: listTime,
                  isSelected: _selected == 0,
                  isDark: _isDark,
                  cardBg: cardBg,
                  onTap: () => setState(() => _selected = 0),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'أو قبل الوقت بـ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isDark
                          ? AppDarkColors.placeholder
                          : const Color(0xFF8A8A8E),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: _minuteOptions.length,
                  itemBuilder: (ctx, i) {
                    final mins = _minuteOptions[i];
                    final isSelected = _selected == mins;
                    // Eastern Arabic-Indic numeral
                    final arabicNum = _toArabicNumerals(mins);
                    // 5 and 10 are plural → دقايق, others → دقيقة
                    final label =
                        (mins == 5 || mins == 10) ? 'دقايق قبل' : 'دقيقة قبل';
                    return GestureDetector(
                      onTap: () => setState(() => _selected = mins),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        decoration: BoxDecoration(
                          color: isSelected ? _accent : cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? _accent
                                : _isDark
                                    ? AppDarkColors.fieldBorder
                                    : const Color(0xFFE5E5EA),
                            width: isSelected ? 0 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _accent.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(_isDark ? 0.2 : 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              arabicNum,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : _isDark
                                        ? AppDarkColors.textPrimary
                                        : Colors.black87,
                              ),
                            ),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.85)
                                    : _isDark
                                        ? AppDarkColors.placeholder
                                        : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExactTimeCard extends StatelessWidget {
  final Color accent;
  final String? listTime;
  final bool isSelected;
  final bool isDark;
  final Color cardBg;
  final VoidCallback onTap;

  const _ExactTimeCard({
    required this.accent,
    required this.listTime,
    required this.isSelected,
    required this.isDark,
    required this.cardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? accent : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accent
                : isDark
                    ? AppDarkColors.fieldBorder
                    : const Color(0xFFE5E5EA),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.alarm_rounded,
                size: 22,
                color: isSelected ? Colors.white : accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عند الوقت تماماً',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? AppDarkColors.textPrimary
                              : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    listTime != null
                        ? 'الفحص يبدأ عند الساعة $listTime'
                        : 'عند الوقت المحدد للقائمة',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : isDark
                              ? AppDarkColors.placeholder
                              : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? AppDarkColors.placeholder
                          : const Color(0xFFB0B0B8),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, color: accent, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final VoidCallback onTap;

  const _CircleBtn({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
