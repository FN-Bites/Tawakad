enum OnboardingAnimation { logoGlitter, lists, mascot, scanning }

class OnboardingStep {
  final String title;
  final String body;
  final OnboardingAnimation animation;

  OnboardingStep({
    required this.title,
    required this.body,
    required this.animation,
  });
}

final List<OnboardingStep> onboardingSteps = [
  OnboardingStep(
    title: 'مرحبًا بك في توكد',
    body:
        'التطبيق الذي سيساعدك على التأكد من أن أغراضك دائمًا معك، لتكون مستعدًا لأي مكان تذهب إليه.',
    animation: OnboardingAnimation.logoGlitter,
  ),
  OnboardingStep(
    title: 'أنشئ قوائم لأغراضك',
    body: 'أنشئ قوائم بالأغراض التي تحتاجها لكل مكان تذهب إليه، ونظمها بسهولة.',
    animation: OnboardingAnimation.lists,
  ),
  OnboardingStep(
    title: 'اقتراحات ذكية للأغراض',
    body:
        'يقترح لك توكي الأغراض التي قد تحتاج لإحضارها معك، بما يتناسب بالظروف المحيطة بك.',
    animation: OnboardingAnimation.mascot,
  ),
  OnboardingStep(
    title: 'افحص أغراضك تلقائيًا',
    body:
        'عند الوقت الذي تحدده، سيتم فحص أغراضك تلقائيًا للتأكد من أن جميع أغراضك المهمة معك قبل المغادرة.',
    animation: OnboardingAnimation.scanning,
  ),
];
