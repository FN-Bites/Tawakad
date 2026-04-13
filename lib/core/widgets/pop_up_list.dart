import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_overlays.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

class GlassPopUpList extends StatefulWidget {
  final String title;
  final List<String> options;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final Color circleColor;

  const GlassPopUpList({
    super.key,
    required this.title,
    required this.options,
    required this.initialValue,
    required this.onChanged,
    required this.icon,
    required this.circleColor,
  });

  @override
  State<GlassPopUpList> createState() => _GlassPopUpListState();
}

class _GlassPopUpListState extends State<GlassPopUpList>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _animCtrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _progress = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _removeOverlay();
    _animCtrl.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  void _toggle() => _isOpen ? _close() : _open();

  void _open() {
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    _animCtrl.forward(from: 0);
    if (mounted) setState(() => _isOpen = true);
  }

  Future<void> _close() async {
    await _animCtrl.reverse();
    _removeOverlay();
    if (mounted) setState(() => _isOpen = false);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _select(int index) {
    widget.onChanged(widget.options[index]);
    _close();
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final rowWidth = renderBox.size.width;
    final isDark = _isDark;

    return OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            width: rowWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 8),
              child: FadeTransition(
                opacity: _progress,
                child: ScaleTransition(
                  scale: Tween(begin: 0.90, end: 1.0).animate(_progress),
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: AppGlassDropdown(
                        items: widget.options
                            .map((o) => GlassDropdownItem(label: o))
                            .toList(),
                        selectedIndex: widget.options
                            .indexOf(widget.initialValue)
                            .clamp(0, widget.options.length - 1),
                        accentColor: widget.circleColor,
                        onItemTap: _select,
                        header: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: widget.circleColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(widget.icon,
                                  color: Colors.white, size: 13),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isDark ? AppDarkColors.textPrimary : Colors.black87;
    final subColor =
        _isDark ? AppDarkColors.placeholder : const Color(0xFFAAAAAA);

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: widget.circleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 12),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const Spacer(),
            Text(
              widget.initialValue,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: subColor,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: subColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
