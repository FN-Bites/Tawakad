import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';

class PopUpList extends StatefulWidget {
  const PopUpList({
    super.key,
    required this.title,
    required this.options,
    required this.initialValue,
    required this.onChanged,
    this.icon,
    this.imagePath,
    this.iconColor = Colors.white,
    this.circleColor = const Color(0xFF3C8EFF),
  });

  final String title;
  final List<String> options;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final String? imagePath;
  final Color iconColor;
  final Color circleColor;

  @override
  State<PopUpList> createState() => _PopUpListState();
}

class _PopUpListState extends State<PopUpList> {
  late String selectedValue;
  MenuController? _menuController;

  bool get isMenuOpen => _menuController?.isOpen ?? false;
  bool get _hasLeadingVisual => widget.icon != null || widget.imagePath != null;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MenuAnchor(
        controller: _menuController,
        builder: (context, controller, child) {
          _menuController = controller;

          return GestureDetector(
            onTap: () => isMenuOpen ? controller.close() : controller.open(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 76,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: isMenuOpen
                    ? widget.circleColor.withOpacity(0.15)
                    : Colors.white.withOpacity(0.55),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isMenuOpen ? 0.12 : 0.06),
                    blurRadius: isMenuOpen ? 20 : 14,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isMenuOpen ? widget.circleColor : Colors.transparent,
                  width: isMenuOpen ? 2 : 0,
                ),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  if (_hasLeadingVisual) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isMenuOpen
                            ? widget.circleColor.withOpacity(0.8)
                            : widget.circleColor.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(isMenuOpen ? 0.2 : 0.1),
                            blurRadius: isMenuOpen ? 12 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: widget.imagePath != null
                            ? Image.asset(
                                widget.imagePath!,
                                width: 20,
                                height: 20,
                                color: widget.iconColor,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    widget.icon ??
                                        Icons.image_not_supported_outlined,
                                    color: widget.iconColor,
                                    size: 20,
                                  );
                                },
                              )
                            : Icon(
                                widget.icon!,
                                color: widget.iconColor,
                                size: 22,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: isMenuOpen ? Colors.black : Colors.black87,
                    ),
                    child: Text(widget.title),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: isMenuOpen
                            ? Colors.black87
                            : const Color(0xFF8E8E93),
                      ),
                      child: Text(
                        selectedValue,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMenuOpen
                          ? widget.circleColor.withOpacity(0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isMenuOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color:
                          isMenuOpen ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        menuChildren: widget.options.map((option) {
          final selected = option == selectedValue;

          return MenuItemButton(
            onPressed: () {
              setState(() => selectedValue = option);
              widget.onChanged(option);
              _menuController?.close();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: Text(
                      option,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 17,
                        color: selected ? Colors.black : Colors.black87,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 10),
                    Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: widget.circleColor,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
