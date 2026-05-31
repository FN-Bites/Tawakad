import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tawakad_app/firebase_options.dart';
import 'package:tawakad_app/features/settings/providers/profile_provider.dart';
import 'package:tawakad_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  });

  testWidgets('TawakadApp builds with required providers', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProfileProvider(),
        child: const TawakadApp(),
      ),
    );

    expect(find.byType(TawakadApp), findsOneWidget);
  });
}
