import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:tawakad_app/features/rewards/model/badge_model.dart';
import 'package:tawakad_app/features/rewards/ui/animation/badge_tier_rive.dart';
import 'package:tawakad_app/features/rewards/ui/animation/list_completion_rive.dart';
import 'package:tawakad_app/core/app_shell.dart';

class ListCompletionPage extends StatefulWidget {
  final BadgeModel? badge;

  const ListCompletionPage({super.key, this.badge});

  @override
  State<ListCompletionPage> createState() => _ListCompletionPageState();
}

class _ListCompletionPageState extends State<ListCompletionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  rive.FileLoader? _fileLoader;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();

    if (widget.badge != null) {
      _fileLoader = rive.FileLoader.fromAsset(
        widget.badge!.tier.assetPath,
        riveFactory: rive.Factory.rive,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _fileLoader?.dispose();
    super.dispose();
  }

  bool get _isBadge => widget.badge != null;

  String get _headline => _isBadge ? widget.badge!.name : 'أحسنت! قائمة مكتملة';

  String get _subline => _isBadge
      ? widget.badge!.motivationalLine
      : 'كل قائمة تكملها تقربك من تنظيم أفضل';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    const textPrimary = Color(0xFFFFFFFF);
    const textMuted = Color(0xCCFFFFFF);

    return Scaffold(
      backgroundColor: const Color(0xFF0091FF),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Animation ─────────────────────────────────────────────
              if (_isBadge && _fileLoader != null)
                SizedBox(
                  width: screenWidth,
                  height: screenWidth + topPadding,
                  child: rive.RiveWidgetBuilder(
                    fileLoader: _fileLoader!,
                    builder: (context, state) {
                      if (state is rive.RiveLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        );
                      }
                      if (state is rive.RiveFailed) {
                        return const Center(
                          child: Text(
                            'خطأ في تحميل الوسام',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(color: textMuted),
                          ),
                        );
                      }
                      if (state is rive.RiveLoaded) {
                        return rive.RiveFileWidget(
                          file: state.file,
                          painter: rive.StateMachinePainter(
                            stateMachineName: 'State Machine 1',
                            fit: rive.Fit.cover,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                )
              else ...[
                const Spacer(),
                Center(
                  child: ListCompletionRiveWidget(size: screenWidth * 0.50),
                ),
              ],

              // ── Headline ──────────────────────────────────────────────
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _headline,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),

              // ── Subline ───────────────────────────────────────────────
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _subline,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 20,
                    color: textMuted,
                    height: 1.6,
                  ),
                ),
              ),

              const Spacer(),

              // ── CTA ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32).copyWith(
                  bottom: bottomPadding + 24,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AppShell()),
                        (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text(
                      'العودة للمنزل',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
