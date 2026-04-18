import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_overlays.dart';

class AppSwipeToDelete extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final String dialogTitle;
  final String dialogMessage;
  final String confirmLabel;
  final String cancelLabel;

  const AppSwipeToDelete({
    super.key,
    required this.child,
    required this.onDelete,
    this.dialogTitle = 'حذف',
    this.dialogMessage = 'هل أنت متأكد أنك تريد الحذف؟',
    this.confirmLabel = 'حذف',
    this.cancelLabel = 'إلغاء',
  });

  @override
  State<AppSwipeToDelete> createState() => _AppSwipeToDeleteState();
}

class _AppSwipeToDeleteState extends State<AppSwipeToDelete>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  static const double _buttonSize = 52.0;
  static const double _revealWidth = _buttonSize + 16.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: _revealWidth).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta == null) return;
    if (details.primaryDelta! < 0 && _controller.value == 0) return;
    final delta = details.primaryDelta! / _revealWidth;
    _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_controller.value > 0.4 || velocity > 300) {
      _controller.animateTo(1.0, curve: Curves.easeOut);
    } else {
      _controller.animateTo(0.0, curve: Curves.easeOut);
    }
  }

  void _close() => _controller.animateTo(0.0, curve: Curves.easeOut);

  Future<void> _confirmDelete() async {
    _close();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: AppGlassDialog(
          title: widget.dialogTitle,
          message: widget.dialogMessage,
          primaryLabel: widget.confirmLabel,
          secondaryLabel: widget.cancelLabel,
          isPrimaryDestructive: true,
          onPrimaryPressed: () => Navigator.pop(ctx, true),
          onSecondaryPressed: () => Navigator.pop(ctx, false),
        ),
      ),
    );
    if (confirmed == true) widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: SizedBox(
                width: _buttonSize,
                height: _buttonSize,
                child: GestureDetector(
                  onTap: _confirmDelete,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 0, 0),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(13),
                    child: Image.asset(
                      'assets/icons/trash.png',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(_slideAnimation.value, 0),
              child: child,
            ),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
