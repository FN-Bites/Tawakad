import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tawakad_app/features/onboarding/providers/onboarding_flow_provider.dart';
import 'package:tawakad_app/features/onboarding/ui/pages/onboarding_screens/onboarding_page.dart';

void main() {
  testWidgets(
    'user can enter name and move to next step',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => OnboardingFlowProvider(
            totalSteps: 5,
          ),
          child: const MaterialApp(
            home: OnboardingPage(),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField).at(0),
        'Nujood',
      );

      await tester.enterText(
        find.byType(TextField).at(1),
        'Mohammed',
      );

      await tester.tap(find.text('Next'));

      await tester.pumpAndSettle();

      expect(find.text('Gender'), findsOneWidget);
    },
  );
}
