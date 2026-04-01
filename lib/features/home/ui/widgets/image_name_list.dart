import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

class ImageNameList extends StatelessWidget {
  final List<String> imageNames;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final VoidCallback? onAnyChange;

  const ImageNameList({
    super.key,
    required this.imageNames,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.onAnyChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الأيقونة الدائرية الكبيرة مع ظل خفيف
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundImage: AssetImage(imageNames[0]),
                radius: 64,
                backgroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            // حقل "اسم القائمة"
            TextField(
              controller: controller,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              keyboardType: keyboardType,
              onChanged: (v) {
                onChanged(v);
                onAnyChange?.call();
              },
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintTextDirection: TextDirection.rtl,
                filled: true,
                fillColor: const Color(0xFFEFEFEF),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: border(Colors.transparent, 1),
                focusedBorder: border(AppColors.primary, 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
