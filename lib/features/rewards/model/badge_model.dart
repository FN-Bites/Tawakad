import '../ui/animation/badge_tier_rive.dart';

class BadgeModel {
  final BadgeTier tier;
  final String name;
  final String motivationalLine;
  final int requiredCompletions;

  const BadgeModel({
    required this.tier,
    required this.name,
    required this.motivationalLine,
    required this.requiredCompletions,
  });
}

class BadgeDefinitions {
  BadgeDefinitions._();

  static const List<BadgeModel> all = [
    BadgeModel(
      tier: BadgeTier.bronze,
      name: 'الوسام البرونزي',
      motivationalLine: 'أول قائمة مكتملة — بدأت رحلتك نحو التنظيم',
      requiredCompletions: 1,
    ),
    BadgeModel(
      tier: BadgeTier.silver,
      name: 'الوسام الفضي',
      motivationalLine: 'خمس قوائم مكتملة — استمر بهذا المستوى',
      requiredCompletions: 5,
    ),
    BadgeModel(
      tier: BadgeTier.gold,
      name: 'الوسام الذهبي',
      motivationalLine: 'خمس عشرة قائمة مكتملة — تقدم ممتاز',
      requiredCompletions: 15,
    ),
    BadgeModel(
      tier: BadgeTier.platinum,
      name: 'الوسام البلاتيني',
      motivationalLine: 'خمس وعشرون قائمة مكتملة — مستوى ثابت وقوي',
      requiredCompletions: 25,
    ),
    BadgeModel(
      tier: BadgeTier.diamond,
      name: 'الوسام الماسي',
      motivationalLine: 'خمس وثلاثون قائمة مكتملة — وصلتِ إلى أعلى مستوى',
      requiredCompletions: 50,
    ),
  ];

  static BadgeModel? unlockedAt(int count) {
    try {
      return all.firstWhere((b) => b.requiredCompletions == count);
    } catch (_) {
      return null;
    }
  }
}

sealed class CompletionEvent {
  const CompletionEvent();
}

final class BadgeCompletion extends CompletionEvent {
  final BadgeModel badge;
  const BadgeCompletion(this.badge);
}

final class DefaultCompletion extends CompletionEvent {
  const DefaultCompletion();
}
