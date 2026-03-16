import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import 'bootstrap_controller.dart';

/// Splash / loading screen shown while checking onboarding state.
///
/// Resolves immediately from SharedPreferences and navigates to either
/// '/feed' or '/onboarding'. Users will see this for less than a frame on
/// warm launches and a brief moment on cold launches.
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen>
    with SingleTickerProviderStateMixin {
  final _controller = const BootstrapController();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Run device-id setup and route resolution in parallel.
    final results = await Future.wait([
      _controller.ensureDeviceId(),
      _controller.initialRoute(),
    ]);

    // Brief minimum splash so the logo doesn't flash too fast.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    final route = results[1] as String;
    context.go(route);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MindScrollLogo(),
              const SizedBox(height: 24),
              Text(
                'Loading reflections...',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.stoicism.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Mind" in white + "Scroll" in teal, Playfair italic.
class _MindScrollLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Mind',
            style: TextStyle(
              fontFamily: 'Playfair',
              fontSize: 36,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
          TextSpan(
            text: 'Scroll',
            style: TextStyle(
              fontFamily: 'Playfair',
              fontSize: 36,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.normal,
              color: AppColors.stoicism,
            ),
          ),
        ],
      ),
    );
  }
}
