import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';

/// The colour a level is drawn in. One mapping, used by the bar, the
/// percentage, and the level pill so they can never disagree.
extension OccupancyLevelColor on OccupancyLevel {
  Color get color => switch (this) {
    OccupancyLevel.quiet => AppColors.occupancyQuiet,
    OccupancyLevel.moderate => AppColors.occupancyModerate,
    OccupancyLevel.busy => AppColors.occupancyBusy,
    OccupancyLevel.packed => AppColors.occupancyPacked,
  };
}

/// The horizontal fill showing how full the gym is.
///
/// [ratio] must already be clamped to 0..1 — over-capacity readings are shown
/// honestly in the *text* (108%) but the bar itself cannot overflow.
class OccupancyBar extends StatelessWidget {
  const OccupancyBar({
    super.key,
    required this.ratio,
    required this.color,
    this.height = 14,
  });

  final double ratio;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: <Widget>[
          // Track. Lighter than the card it sits on, so the empty part of the
          // bar reads as "space left" rather than as a gap in the layout.
          Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.brandSurfaceHi,
              borderRadius: BorderRadius.circular(height),
              border: Border.all(color: AppColors.brandLine),
            ),
          ),

          // Animates on first build, and again on every refresh — the tween
          // runs from the previous value to the new one, so the 60-second
          // poll slides the bar instead of snapping it.
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: ratio.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (BuildContext context, double value, Widget? _) {
              return FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height),
                    gradient: LinearGradient(
                      colors: <Color>[color.withValues(alpha: 0.72), color],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: color.withValues(alpha: 0.45),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
