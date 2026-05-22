import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';

class ItemsCard extends StatefulWidget {
  final Color accentColor;
  final String? listId;

  const ItemsCard({
    super.key,
    required this.accentColor,
    this.listId,
  });

  @override
  State<ItemsCard> createState() => ItemsCardState();
}

class ItemsCardState extends State<ItemsCard> {
  final TextEditingController _itemController = TextEditingController();
  final FocusNode _itemFocusNode = FocusNode();
  final List<String> _localItems = [];
  bool _isAddingItem = false;

  List<String> get items => List<String>.unmodifiable(_localItems);

  @override
  void dispose() {
    _itemController.dispose();
    _itemFocusNode.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _itemController.text.trim();
    if (text.isEmpty) {
      setState(() => _isAddingItem = false);
      return;
    }
    if (widget.listId != null) {
      context.read<PackListProvider>().addItem(widget.listId!, text);
    } else {
      setState(() => _localItems.add(text));
    }
    _itemController.clear();
    setState(() => _isAddingItem = false);
  }

  void _removeItem(String item) {
    if (widget.listId != null) {
      context.read<PackListProvider>().removeItem(widget.listId!, item);
    } else {
      setState(() => _localItems.remove(item));
    }
  }

  void _startAdding() {
    _itemController.clear();
    setState(() => _isAddingItem = true);
    Future.delayed(
      const Duration(milliseconds: 50),
      _itemFocusNode.requestFocus,
    );
  }

  void addItemByName(String name) {
    if (widget.listId != null) {
      context.read<PackListProvider>().addItem(widget.listId!, name);
    } else {
      setState(() => _localItems.add(name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final cardColor = colorScheme.surface;
    final textColor = isDark ? Colors.white : Colors.black87;
    final dividerColor =
        isDark ? const Color(0xFF2A2A3E) : const Color(0xFFE5E5EA);
    final dashedCircleColor =
        isDark ? const Color(0xFF555568) : const Color(0xFFB0B0B8);
    final hintColor = isDark ? const Color(0xFF888899) : Colors.black38;

    final items = widget.listId != null
        ? context
            .watch<PackListProvider>()
            .lists
            .firstWhere((l) => l.id == widget.listId)
            .items
        : _localItems;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ...items.map(
            (item) => Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _removeItem(item),
                        child: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: dividerColor,
                  indent: 18,
                  endIndent: 18,
                ),
              ],
            ),
          ),
          if (_isAddingItem)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _addItem,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _itemController,
                      focusNode: _itemFocusNode,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اسم الغرض',
                        hintTextDirection: TextDirection.rtl,
                        hintStyle: TextStyle(color: hintColor),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: true,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _addItem(),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: _startAdding,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CustomPaint(
                    size: const Size(26, 26),
                    painter: _DashedCirclePainter(color: dashedCircleColor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    const dashCount = 12;
    const dashAngle = 3.14159 * 2 / dashCount;
    const gapFraction = 0.4;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle * (1 - gapFraction),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
