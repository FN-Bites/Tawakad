import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/animation/scanning_rive.dart';
import 'package:tawakad_app/features/ble_scanning/ui/animation/ble_tag_rive.dart';

class HowToUseSheet extends StatelessWidget {
  const HowToUseSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const HowToUseSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final subtleColor = theme.colorScheme.onSurface.withOpacity(0.45);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subtleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'المسح التلقائي',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: subtleColor),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المسح التلقائي',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'المسح التلقائي يستخدم تقنية BLE (البلوتوث منخفض الطاقة) '
                        'للتحقق من أغراضك بشكل تلقائي بدون الحاجة لفتح التطبيق أو التحقق بشكل يدوي. '
                        'يقوم التطبيق بالتحقق من أغراضك الموجودة معك قبل مغادرتك للمكان الذي تتجه إليه، '
                        'ويعطيك تنبيه في حال نسيان أي غرض.',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: textColor),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(
                        height: 220,
                        child: ScanningRive(),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'طريقة الاستخدام',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'عند البحث عن "BLE Tags" ستجد أنها تتوفر بأشكال وأحجام مختلفة، '
                        'ويمكنك اختيار ما يناسب أغراضك.',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: textColor),
                      ),
                      const SizedBox(height: 16),
                      _StepTile(
                        number: '١',
                        text: 'اشترِ وسم BLE المناسب لك.',
                        theme: theme,
                        textColor: textColor,
                      ),
                      _StepTile(
                        number: '٢',
                        text: 'ألصق الوسم على الغرض أو علّقه حسب نوع الغرض.',
                        theme: theme,
                        textColor: textColor,
                      ),
                      _StepTile(
                        number: '٣',
                        text: 'فعّل البلوتوث في هاتفك.',
                        theme: theme,
                        textColor: textColor,
                      ),
                      _StepTile(
                        number: '٤',
                        text: 'افتح التطبيق واضغط على "إضافة غرض".',
                        theme: theme,
                        textColor: textColor,
                      ),
                      _StepTile(
                        number: '٥',
                        text:
                            'بعد إتمام الحفظ، سيتم حفظ الغرض وبدء التحقق منه تلقائيًا.',
                        theme: theme,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(
                        height: 220,
                        child: BleTagRive(),
                      ),
                      const SizedBox(height: 32),
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

class _StepTile extends StatelessWidget {
  final String number;
  final String text;
  final ThemeData theme;
  final Color textColor;

  const _StepTile({
    required this.number,
    required this.text,
    required this.theme,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
