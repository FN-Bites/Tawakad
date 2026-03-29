import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/features/onboarding/ui/pages/auth_entry_page.dart';
import 'onboarding_content.dart';
import 'onboarding_data.dart';
import 'package:tawakad_app/features/onboarding/ui/widgets/onboarding_indicator.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_back_button.dart';

class OnboardingPage extends StatefulWidget {
  final int initialPage;
  const OnboardingPage({super.key, this.initialPage = 0});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller =
      PageController(initialPage: widget.initialPage);
  late int _current = widget.initialPage;

  bool get _isLast => _current == onboardingSteps.length - 1;

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_current == 0) {
      Navigator.pop(context);
    } else {
      _controller.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() => _finish();

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthEntryPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_current != 0)
                    GlassBackButton(onPressed: _back)
                  else
                    const SizedBox(width: 44),
                  AppLiquidButtons.small(
                    label: 'تخطي',
                    onPressed: _skip,
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _current = i),
                  itemCount: onboardingSteps.length,
                  itemBuilder: (_, i) => OnboardingContent(
                    step: onboardingSteps[i],
                  ),
                ),
              ),
              OnboardingIndicator(
                total: onboardingSteps.length,
                current: _current,
              ),
              const SizedBox(height: 20),
              AppLiquidButtons.primary(
                label: 'التالي',
                onPressed: _next,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
