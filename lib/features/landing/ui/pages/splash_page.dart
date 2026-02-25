import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/animation/splash_rive.dart';
import 'package:tawakad_app/features/landing/ui/transitions/circular_reveal.dart';
import 'package:tawakad_app/features/landing/ui/pages/landing_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        CircularRevealRoute(
          page: const LandingPage(),
          centerAlignment: Alignment.center,
          duration: const Duration(milliseconds: 750),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 80),
            child: SizedBox(
              width: 400,
              height: 400,
              child: SplashRiveBuilder(),
            ),
          ),
        ),
      ),
    );
  }
}
