import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/body_factory_mark.dart';
import '../controllers/app_boot_controller.dart';
import '../widgets/brand_wordmark.dart';

/// Brand hold while the app restores any saved session and warms the theme.
///
/// The mark assembles, then the wordmark types in beneath it — a compressed
/// port of the brand animation in `design/logo_animation/`.
///
/// This screen navigates nowhere. Leaving it is the router's `redirect`
/// watching the auth state — so if the restored token turns out to be
/// expired, the redirect still lands the user on Login instead of somewhere
/// stale.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: splashHold,
  )..forward();

  /// The mark owns the first stretch of the hold, the wordmark overlaps into
  /// the tail of it so the two read as one motion.
  static const double _markEnd = 0.66;
  static const double _wordStart = 0.45;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brand,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final double t = _controller.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BodyFactoryMark(
                  size: 172,
                  progress: (t / _markEnd).clamp(0.0, 1.0),
                ),
                const SizedBox(height: AppSpacing.section),
                BrandWordmark(
                  progress: ((t - _wordStart) / (1 - _wordStart)).clamp(
                    0.0,
                    1.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                SplashProgressBar(progress: t),
              ],
            );
          },
        ),
      ),
    );
  }
}
