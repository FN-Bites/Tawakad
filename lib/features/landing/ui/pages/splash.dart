import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/animation/splash_logo.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

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
