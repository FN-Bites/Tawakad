import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RadioOption extends StatefulWidget {
  final String label;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  final bool hasError;

  const RadioOption({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  State<RadioOption> createState() => _RadioOptionState();
}

class _RadioOptionState extends State<RadioOption> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.value == widget.groupValue;

    Color background = AppColors.surface;

    if (widget.hasError && !selected) {
      background = AppColors.fieldErrorFill;
    }

    if (_hovered || _pressed) {
      background = Color.alphaBlend(
        Colors.black.withOpacity(_pressed ? 0.06 : 0.03),
        background,
      );
    }

    final borderColor = widget.hasError
        ? AppColors.fieldErrorBorder
        : (selected ? AppColors.primary : AppColors.fieldBorder);

    final borderWidth = (selected || widget.hasError) ? 2.0 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => widget.onChanged(widget.value),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Radio<String>(
                  value: widget.value,
                  groupValue: widget.groupValue,
                  onChanged: widget.onChanged,
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity:
                      const VisualDensity(horizontal: -2, vertical: -2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
