import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/features/onboarding/providers/onboarding_flow_provider.dart';
import '../../widgets/onboarding_scaffold.dart';
import 'name_page.dart';
import 'gender_page.dart';
import 'status_page.dart';
import 'medication_page.dart';
import 'package:tawakad_app/core/widgets/entry_bottom_action_text.dart';
import 'package:tawakad_app/features/onboarding/ui/animation/mascot_rive.dart';

class OnboardingQuestionsPage extends StatefulWidget {
  const OnboardingQuestionsPage({super.key});

  @override
  State<OnboardingQuestionsPage> createState() =>
      _OnboardingQuestionsPageState();
}

class _OnboardingQuestionsPageState extends State<OnboardingQuestionsPage> {
  Timer? _bubbleTimer;
  bool _showBubble = false;
  int? _lastStep;

  @override
  void initState() {
    super.initState();
    _startBubbleDelay();
  }

  void _startBubbleDelay() {
    _bubbleTimer?.cancel();

    setState(() {
      _showBubble = false;
    });

    _bubbleTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _showBubble = true;
      });
    });
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    if (_lastStep != flow.currentStep) {
      _lastStep = flow.currentStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startBubbleDelay();
      });
    }

    Widget stepChild;
    String title;
    String mascotMessage;
    VoidCallback? onNext;

    switch (flow.currentStep) {
      case 1:
        title = 'ماهو اسمك؟';
        mascotMessage = 'ما اسمك؟ أحب أناديك به خلال استخدامك للتطبيق';
        stepChild = const NameStepContent();
        onNext = flow.nextFromNameStep;
        break;

      case 2:
        title = 'ماهو جنسك؟';
        mascotMessage = 'يساعدني التعرّف على جنسك في تقديم اقتراحات تناسبك';
        stepChild = const GenderStepContent();
        onNext = flow.nextFromGenderStep;
        break;

      case 3:
        title = 'ماهي حالتك؟';
        mascotMessage =
            'معرفة حالتك المهنية تساعدني في تقديم اقتراحات مناسبة لك';
        stepChild = const StatusStepContent();
        onNext = flow.nextFromStatusStep;
        break;

      case 4:
        title = 'هل تتناول أي أدوية؟';
        mascotMessage =
            'يساعدني معرفة ما إذا كنت تتناول أي أدوية على تذكيرك بإحضار أدويتك معك ';
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
        mascotMessage = '';
        stepChild = const SizedBox();
        onNext = null;
    }

    return OnboardingScaffold(
      currentStep: flow.currentStep,
      totalSteps: flow.totalSteps,
      title: title,
      primaryButtonText: 'التالي',
      onPrimaryPressed: onNext,
      onBack: () {
        if (flow.currentStep == 1) {
          Navigator.pop(context);
          return;
        }
        flow.back();
      },
      mascotState: flow.showMascotError ? MascotState.error : MascotState.idle,
      mascotMessage: mascotMessage,
      isError: flow.showMascotError,
      showBubble: _showBubble,
      bottom: EntryBottomActionText(
        prefixText: 'لديك حساب؟ ',
        actionText: 'قم بتسجيل الدخول',
        onTap: () {
          Navigator.pushReplacementNamed(context, '/signin');
        },
      ),
      child: stepChild,
    );
  }
}
