import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/features/signIn/state/signIn_flow_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes.dart';
import 'features/onboarding/state/onboarding_flow_provider.dart';
import 'features/signUp/state/signup_flow_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// -----------------------------------------------------------------------------
import 'package:firebase_core/firebase_core.dart';
import 'features/verifyEmail/state/verifyEmail_flow_provider.dart';
import 'features/forgotPassword/state/forgotPassword_flow_provider.dart';
import 'features/createNewPassword/state/createNewPassword_flow_provider.dart';
import 'firebase_options.dart';
import 'core/services/deep_link_service.dart';
import 'features/createNewPassword/ui/widgets/create_new_password_args.dart';

// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// -----------------------------------------------------------------------------
void main() async {
// -----------------------------------------------------------------------------
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
// -----------------------------------------------------------------------------

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OnboardingFlowProvider(totalSteps: 4),
        ),
        ChangeNotifierProvider(
          create: (_) => SignupFlowProvider(),
        ),
// -----------------------------------------------------------------------------
        ChangeNotifierProvider(
          create: (_) => VerifyEmailFlowProvider(),
        ),
// -----------------------------------------------------------------------------
        ChangeNotifierProvider(
          create: (_) => SignInFlowProvider(),
        ),
// -----------------------------------------------------------------------------
        ChangeNotifierProvider(
          create: (_) => ForgotPasswordFlowProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CreateNewPasswordFlowProvider(),
        ),
// -----------------------------------------------------------------------------
        //
      ],
      child: const TawakadApp(),
    ),
  );
// -----------------------------------------------------------------------------
  final deepLinkService = DeepLinkService();
  final data = await deepLinkService.getInitialLinkData();
  if (data != null) {
    if (data.mode == 'resetPassword') {
      navigatorKey.currentState?.pushNamed(
        AppRoutes.createNewPassword,
        arguments: CreateNewPasswordArgs(
          oobCode: data.oobCode,
        ),
      );
    }
    if (data.mode == 'verifyEmail') {
      navigatorKey.currentState?.pushNamed(
        AppRoutes.verifyEmail,
        arguments: data.oobCode,
      );
    }
  }
  deepLinkService.listenForLinks((data) {
    if (data.mode == 'resetPassword') {
      navigatorKey.currentState?.pushNamed(
        AppRoutes.createNewPassword,
        arguments: CreateNewPasswordArgs(
          oobCode: data.oobCode,
        ),
      );
    }
    if (data.mode == 'verifyEmail') {
      navigatorKey.currentState?.pushNamed(
        AppRoutes.verifyEmail,
        arguments: data.oobCode,
      );
    }
  });
}
// -----------------------------------------------------------------------------

class TawakadApp extends StatelessWidget {
  const TawakadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.homePage,
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
