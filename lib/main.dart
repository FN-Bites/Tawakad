import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routes.dart';
import 'features/onboarding/providers/onboarding_flow_provider.dart';
import 'features/signUp/providers/signup_flow_provider.dart';
import 'features/signUp/providers/verifyEmail_flow_provider.dart';
import 'package:tawakad_app/features/signIn/providers/signIn_flow_provider.dart';
import 'features/signIn/providers/forgotPassword_flow_provider.dart';
import 'features/home/provider/pack_list_provider.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_provider.dart';
import 'package:tawakad_app/core/app_shell.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_item_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OnboardingFlowProvider(totalSteps: 4),
        ),
        ChangeNotifierProvider(
          create: (_) => SignupFlowProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => VerifyEmailFlowProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SignInFlowProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ForgotPasswordFlowProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PackListProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BleProvider(),
        ),
        ChangeNotifierProxyProvider2<BleProvider, PackListProvider,
            BleItemProvider>(
          create: (ctx) {
            final bleItems = BleItemProvider(ctx.read<BleProvider>());
            _wireAutoScan(bleItems, ctx.read<PackListProvider>());
            return bleItems;
          },
          update: (ctx, ble, packLists, previous) {
            previous!.updateBle(ble);
            _wireAutoScan(previous, packLists);
            return previous;
          },
        ),
      ],
      child: const TawakadApp(),
    ),
  );
}

void _wireAutoScan(BleItemProvider bleItems, PackListProvider packLists) {
  bleItems.onAutoScanResult =
      (String checklistItemName, String listId, bool isPresent) {
    if (isPresent) {
      packLists.checkItemByName(listId, checklistItemName);
      debugPrint(
          'Auto-check: "$checklistItemName" in list "$listId" marked as ✓ (BLE present)');
    } else {
      debugPrint(
          'Auto-check: "$checklistItemName" in list "$listId" — signal absent, not checked.');
    }
  };
}

class TawakadApp extends StatefulWidget {
  const TawakadApp({super.key});

  @override
  State<TawakadApp> createState() => _TawakadAppState();
}

class _TawakadAppState extends State<TawakadApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.appShell,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
