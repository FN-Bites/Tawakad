// 💊 medication_page.dart — قائمة الأدوية

import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/features/settings&/ui/pages/add_medication_page.dart';
import 'package:tawakad_app/features/settings&/ui/widgets/medication_card.dart';
import 'package:tawakad_app/features/settings&/ui/widgets/settings_ui.dart';

class MedicationPage extends StatelessWidget {
  const MedicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: settingsPageBackground(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SettingsPageHeader(
                  title: 'الأدوية',
                  action: AppLiquidButtons.iconWithLabel(
                    icon: Icons.add,
                    label: 'إضافة دواء',
                    fillColor: AppColors.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const AddMedicationPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'أدويتي',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8A8A8E),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: const [
                      MedicationCard(
                        name: 'Panadol',
                        intakeTimes: ['8:00 ص', '2:00 م', '9:00 م'],
                        autoAdd: true,
                      ),
                      SizedBox(height: 14),
                      MedicationCard(
                        name: 'Vitamin D',
                        intakeTimes: ['9:00 م'],
                        autoAdd: true,
                      ),
                    ],
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
