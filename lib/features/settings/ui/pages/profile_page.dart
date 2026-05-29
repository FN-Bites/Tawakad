import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/rewards/model/badge_model.dart';
import 'package:tawakad_app/features/rewards/provider/reward_provider.dart';
import 'package:tawakad_app/features/rewards/ui/animation/badge_tier_rive.dart';
import 'package:tawakad_app/features/settings/providers/profile_provider.dart';
import 'package:tawakad_app/features/settings/ui/pages/settings_page.dart';
import 'package:tawakad_app/features/settings/ui/widgets/settings_ui.dart';

class _TierStyle {
  final Color primary;
  final Color secondary;
  final String assetPath;

  const _TierStyle({
    required this.primary,
    required this.secondary,
    required this.assetPath,
  });
}

final _tierStyles = <BadgeTier, _TierStyle>{
  BadgeTier.bronze: const _TierStyle(
    primary: Color(0xFFCC9B6E),
    secondary: Color(0xFFE5AE7D),
    assetPath: 'assets/badges/bronze.png',
  ),
  BadgeTier.silver: const _TierStyle(
    primary: Color(0xFF93A8BB),
    secondary: Color(0xFFD6E4EF),
    assetPath: 'assets/badges/silver.png',
  ),
  BadgeTier.gold: const _TierStyle(
    primary: Color(0xFFFEC103),
    secondary: Color(0xFFFDE236),
    assetPath: 'assets/badges/gold.png',
  ),
  BadgeTier.platinum: const _TierStyle(
    primary: Color(0xFF6403FE),
    secondary: Color(0xFF6C5EFD),
    assetPath: 'assets/badges/platinum.png',
  ),
  BadgeTier.diamond: const _TierStyle(
    primary: Color(0xFF03C9FE),
    secondary: Color(0xFF5EF0FD),
    assetPath: 'assets/badges/diamond.png',
  ),
};

final _tierOrder = [
  BadgeTier.bronze,
  BadgeTier.silver,
  BadgeTier.gold,
  BadgeTier.platinum,
  BadgeTier.diamond,
];

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

  BadgeModel? _badgeForTier(BadgeTier tier) {
    try {
      return BadgeDefinitions.all.firstWhere((b) => b.tier == tier);
    } catch (_) {
      return null;
    }
  }

  BadgeTier? _highestEarnedTier(int completedLists) {
    BadgeTier? highest;
    for (final tier in _tierOrder) {
      final badge = _badgeForTier(tier);
      if (badge != null && completedLists >= badge.requiredCompletions) {
        highest = tier;
      }
    }
    return highest;
  }

  Set<BadgeTier> _earnedTiers(int completedLists) {
    return {
      for (final tier in _tierOrder)
        if ((_badgeForTier(tier)?.requiredCompletions ?? 999999) <=
            completedLists)
          tier,
    };
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final rewards = context.watch<RewardProvider>();
    final isDark = settingsIsDark(context);

    final completedLists = rewards.completedLists;
    final highestTier = _highestEarnedTier(completedLists);
    final earnedTiers = _earnedTiers(completedLists);

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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      _buildProfileSection(
                          context, profile, isDark, highestTier),
                      const SizedBox(height: 28),
                      _sectionTitle(context, 'جوائزي'),
                      const SizedBox(height: 14),
                      _buildBadgesCard(context, isDark, earnedTiers),
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
    BadgeTier? highestTier,
  ) {
    final displayName = profile.profile?.displayName ?? 'اسم المستخدم';
    final email = profile.profile?.email ?? '';

    final BadgeModel? highestBadge =
        highestTier != null ? _badgeForTier(highestTier) : null;
    final Color bannerPrimary = highestTier != null
        ? _tierStyles[highestTier]!.primary
        : Colors.transparent;
    final Color bannerSecondary = highestTier != null
        ? _tierStyles[highestTier]!.secondary
        : Colors.transparent;

    return _FieldCard(
      isDark: isDark,
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
            child:
                const Icon(Icons.person_rounded, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            displayName,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
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
          if (highestBadge != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient:
                    LinearGradient(colors: [bannerPrimary, bannerSecondary]),
              ),
              child: Text(
                highestBadge.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgesCard(
    BuildContext context,
    bool isDark,
    Set<BadgeTier> earnedTiers,
  ) {
    return _FieldCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _tierOrder.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (_, index) {
          final tier = _tierOrder[index];
          final style = _tierStyles[tier]!;
          final isEarned = earnedTiers.contains(tier);
          final badge = _badgeForTier(tier);

          return _badgeItem(
            context: context,
            isDark: isDark,
            style: style,
            isEarned: isEarned,
            label: isEarned ? (badge?.name ?? '') : '؟ ؟ ؟',
            labelColor: isEarned
                ? style.primary
                : (isDark ? const Color(0xFF888888) : const Color(0xFFBBBBBB)),
          );
        },
      ),
    );
  }

  Widget _badgeItem({
    required BuildContext context,
    required bool isDark,
    required _TierStyle style,
    required bool isEarned,
    required String label,
    required Color labelColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Image.asset(
            isEarned ? style.assetPath : 'assets/badges/unlocked.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: labelColor,
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
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.isDark,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
  });

  final bool isDark;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
