import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/onboarding_flow_provider.dart';
import '../widgets/onboarding_scaffold.dart';
import 'name_page.dart';
import 'gender_page.dart';
import 'status_page.dart';
import 'medication_page.dart';
import '../../../../core/widgets/mascot_rive.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    Widget stepChild;
    String title;
    VoidCallback? onNext;

    switch (flow.currentStep) {
      case 1:
        title = 'ماهو اسمك؟';
        stepChild = const NameStepContent();
        onNext = flow.nextFromNameStep;
        break;

      case 2:
        title = 'ماهو جنسك؟';
        stepChild = const GenderStepContent();
        onNext = flow.nextFromGenderStep;
        break;

      case 3:
        title = 'ماهي حالتك؟';
        stepChild = const StatusStepContent();
        onNext = flow.nextFromStatusStep;
        break;

      case 4:
        title = 'هل تتناول أي أدوية؟';
        stepChild = const MedicationStepContent();
        onNext = () {
          flow.nextFromMedicationStep();

          if (!flow.showMascotError) {
            Navigator.pushReplacementNamed(context, '/signup');
          }
        };
        break;

      default:
        title = '';
        stepChild = const SizedBox();
        onNext = null;
    }

    return AuthScaffold(
      currentStep: flow.currentStep,
      totalSteps: flow.totalSteps,
      title: title,
      primaryButtonText: 'التالي',
      onPrimaryPressed: onNext,
      onBack: flow.back,
      bottomPrefixText: 'لديك حساب؟ ',
      bottomActionText: 'قم بتسجيل الدخول',
      onBottomActionPressed: () {},
      mascot: MascotRive(showError: flow.showMascotError),
      child: stepChild,
    );
  }
}
