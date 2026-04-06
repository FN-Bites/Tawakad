import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/toggle_button.dart';

class SharingCard extends StatefulWidget {
  const SharingCard({super.key});

  @override
  State<SharingCard> createState() => SharingCardState();
}

class SharingCardState extends State<SharingCard> {
  bool _sharingEnabled = false;
  bool get sharingEnabled => _sharingEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ToggleRowWidget(
        icon: Icons.people_alt_rounded,
        label: 'المشاركة',
        value: _sharingEnabled,
        onChanged: (v) => setState(() => _sharingEnabled = v),
      ),
    );
  }
}
