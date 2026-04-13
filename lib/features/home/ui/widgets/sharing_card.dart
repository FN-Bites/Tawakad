import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tawakad_app/core/widgets/toggle_button.dart';

class SharingCard extends StatefulWidget {
  final bool initialSharing;
  final String title;
  final List<String> Function() getItems;

  const SharingCard({
    super.key,
    required this.title,
    required this.getItems,
    this.initialSharing = false,
  });

  @override
  State<SharingCard> createState() => SharingCardState();
}

class SharingCardState extends State<SharingCard> {
  bool _sharingEnabled = false;
  bool get sharingEnabled => _sharingEnabled;

  @override
  void initState() {
    super.initState();
    _sharingEnabled = widget.initialSharing;
  }

  String _buildShareText() {
    final items = widget.getItems();
    final itemsText = items.isEmpty
        ? '  • لا توجد عناصر'
        : items.map((item) => '  • $item').join('\n');

    return '''
     ${widget.title} 📋
    ${'─' * 30}
    $itemsText
    ${'─' * 30}
    ''';
  }

  Future<void> _handleSharing(bool value) async {
    setState(() => _sharingEnabled = value);
    if (!value) return;

    await SharePlus.instance.share(
      ShareParams(
        text: _buildShareText(),
        subject: widget.title,
        title: 'مشاركة القائمة',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ToggleRowWidget(
        icon: Icons.people_alt_rounded,
        label: 'المشاركة',
        value: _sharingEnabled,
        onChanged: _handleSharing,
      ),
    );
  }
}
