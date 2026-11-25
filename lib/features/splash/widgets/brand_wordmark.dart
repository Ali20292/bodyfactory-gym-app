import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// "BODY FACTORY" over a rule, with the "GYM" subline beneath.
///
/// Letters rise and fade in one after another, then the rule draws outward
/// and the subline expands its tracking as it appears — the same sequence as
/// the brand animation, compressed to splash length.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, required this.progress, this.scale = 1});

  /// 0 → nothing shown, 1 → fully settled.
  final double progress;

  final double scale;

  static const String _brand = 'BODY FACTORY';
  static const String _sub = 'GYM';

  /// The wordmark's own timeline, in seconds.
  static const double _duration = 1.3;

  @override
  Widget build(BuildContext context) {
    final double t = progress.clamp(0.0, 1.0) * _duration;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _Letters(t: t, text: _brand, scale: scale),
        SizedBox(height: 18 * scale),
        _Rule(t: t, scale: scale),
        SizedBox(height: 16 * scale),
        _Subline(t: t, text: _sub, scale: scale),
      ],
    );
  }
}

class _Letters extends StatelessWidget {
  const _Letters({required this.t, required this.text, required this.scale});

  final double t;
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    int index = 0;

    // The wordmark is laid out letter by letter so each can be animated, which
    // means its width depends on font metrics. Those are not guaranteed:
    // Oswald may not have loaded yet, the user may have text scaling turned
    // up, or the brand name may get longer. Scaling down to fit makes the
    // lockup impossible to overflow instead of merely unlikely to.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: text.split('').map((String character) {
          // The space is laid out but never animated, so the two words stay
          // one continuous stagger rather than restarting.
          if (character == ' ') {
            return SizedBox(width: 18 * scale);
          }

          final double start = 0.05 + index * 0.035;
          index++;
          final double p = _segment(t, start, start + 0.4, Curves.easeOutExpo);

          return Opacity(
            opacity: p,
            child: Transform.translate(
              offset: Offset(0, (1 - p) * 22 * scale),
              child: Text(
                character,
                style: AppTextStyles.wordmark(
                  size: 34 * scale,
                ).copyWith(color: AppColors.cream),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.t, required this.scale});

  final double t;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double p = _segment(t, 0.55, 1.0, Curves.easeOutExpo);

    return Opacity(
      opacity: p,
      child: Container(
        width: (60 + 150 * p) * scale,
        height: 2 * scale,
        color: AppColors.accent,
      ),
    );
  }
}

class _Subline extends StatelessWidget {
  const _Subline({required this.t, required this.text, required this.scale});

  final double t;
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double p = _segment(t, 0.75, 1.3, Curves.easeOutExpo);

    return Opacity(
      opacity: p,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w400,
          color: AppColors.accent,
          // Tracking opens up as it settles, matching the source animation.
          letterSpacing: (4 + 5 * p) * scale,
          height: 1,
        ),
      ),
    );
  }
}

/// Loading bar under the wordmark. Reflects the splash hold, so it is an
/// honest progress cue rather than decoration.
class SplashProgressBar extends StatelessWidget {
  const SplashProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: AppSpacing.xxs,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(color: AppColors.accent),
        ),
      ),
    );
  }
}

double _segment(double t, double start, double end, Curve curve) {
  if (t <= start) return 0;
  if (t >= end) return 1;
  return curve.transform((t - start) / (end - start));
}
