import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class MailSendRive extends StatefulWidget {
  const MailSendRive({super.key});

  @override
  State<MailSendRive> createState() => _MailSendRiveState();
}

class _MailSendRiveState extends State<MailSendRive> {
  late final rive.FileLoader fileLoader = rive.FileLoader.fromAsset(
    'assets/animation/mail-send.riv',
    riveFactory: rive.Factory.rive,
  );

  @override
  void dispose() {
    fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return rive.RiveWidgetBuilder(
      fileLoader: fileLoader,
      builder: (context, state) {
        if (state is rive.RiveLoading) return const SizedBox.shrink();
        if (state is rive.RiveFailed) {
          return Text('Rive failed: ${state.error}');
        }
        if (state is rive.RiveLoaded) {
          return rive.RiveWidget(
            controller: state.controller,
            fit: rive.Fit.contain,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
