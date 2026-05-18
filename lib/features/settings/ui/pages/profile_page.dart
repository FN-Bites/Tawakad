// 👤 profile_page.dart — شاشة الملف الشخصي (جوائز + رابط الإعدادات)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/settings/providers/profile_provider.dart';
import 'package:tawakad_app/features/settings/ui/pages/settings_page.dart';
import 'package:tawakad_app/features/settings/ui/widgets/settings_ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final isDark = settingsIsDark(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: settingsPageBackground(context),
        body: SafeArea(
          child: profile.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  child: Column(
                    children: [
                      SettingsPageHeader(
                        title: 'ملف الشخصي',
                        action: SettingsCircleButton(
                          icon: Icons.settings_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildProfileSection(context, profile, isDark),
                      const SizedBox(height: 32),
                      _sectionTitle(context, 'جوائزي'),
                      const SizedBox(height: 18),
                      _buildBadgesGrid(context, isDark),
                      const SizedBox(height: 36),
                      _sectionTitle(context, 'الجوائز المقفلة'),
                      const SizedBox(height: 18),
                      _buildLockedBadges(isDark),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    ProfileProvider profile,
    bool isDark,
  ) {
    final displayName = profile.profile?.displayName ?? 'اسم المستخدم';
    final email = profile.profile?.email ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: settingsCardColor(context),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF63B3FF), Color(0xFF5B6CFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF63B3FF).withValues(alpha: 0.35),
                  blurRadius: 22,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: TextStyle(
              color:
                  isDark ? AppDarkColors.placeholder : const Color(0xFF8A8A8E),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const LinearGradient(
                colors: [Color(0xFF5E72FF), Color(0xFF55C7FF)],
              ),
            ),
            child: const Text(
              'مستكشف محترف',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (_, index) {
        return _badgeItem(
          context: context,
          isDark: isDark,
          title: 'إنجاز ${index + 1}',
          icon: Icons.emoji_events_rounded,
          colors: [
            const Color(0xFFFFD54F),
            const Color(0xFFFFB300),
          ],
        );
      },
    );
  }

  Widget _buildLockedBadges(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        3,
        (_) => Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: isDark
                ? AppDarkColors.surface.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: Color(0xFF9A9A9A),
            size: 34,
          ),
        ),
      ),
    );
  }

  Widget _badgeItem({
    required BuildContext context,
    required bool isDark,
    required String title,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: settingsCardColor(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 40, color: colors.last),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
