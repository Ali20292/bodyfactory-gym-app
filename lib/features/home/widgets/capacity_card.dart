import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/models.dart';
import 'occupancy_bar.dart';

/// The hero of the Home tab: how busy the gym is right now.
class CapacityCard extends StatelessWidget {
  const CapacityCard({super.key, required this.capacity, this.onLongPress});

  final GymCapacity capacity;

  /// Debug builds only — cycles the forced occupancy level.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final OccupancyLevel level = capacity.level;
    final Color color = level.color;

    return _CapacityShell(
      onLongPress: onLongPress,
      // Read as one sentence rather than as five disconnected fragments,
      // which is what a screen reader would otherwise announce.
      semanticsLabel:
          '${capacity.occupancyPercent} percent full. ${level.label}. '
          '${capacity.countLabel}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'In the gym now',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: AppColors.brandMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text.rich(
                      TextSpan(
                        text: '${capacity.occupancyPercent}',
                        children: const <InlineSpan>[
                          TextSpan(
                            text: '%',
                            style: TextStyle(fontSize: 26, letterSpacing: 0),
                          ),
                        ],
                      ),
                      style: AppTextStyles.statNumber.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              _LevelPill(level: level),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          OccupancyBar(ratio: capacity.fillRatio, color: color),
          const SizedBox(height: AppSpacing.md),
          Text(
            capacity.countLabel,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cream),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Updated ${AppDateFormat.relativeSince(capacity.updatedAt)}',
            style: AppTextStyles.caption.copyWith(color: AppColors.brandHint),
          ),
        ],
      ),
    );
  }
}

/// Shown while the first reading is on its way. Same shape and height as the
/// real card so the layout does not jump when the number lands.
class CapacityCardSkeleton extends StatelessWidget {
  const CapacityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _CapacityShell(
      semanticsLabel: 'Loading how busy the gym is',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'In the gym now',
            style: AppTextStyles.fieldLabel.copyWith(
              color: AppColors.brandMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SkeletonBlock(width: 130, height: 46),
          const SizedBox(height: AppSpacing.xl),
          const _SkeletonBlock(width: double.infinity, height: 14),
          const SizedBox(height: AppSpacing.md),
          const _SkeletonBlock(width: 190, height: 13),
          const SizedBox(height: AppSpacing.sm),
          const _SkeletonBlock(width: 110, height: 11),
        ],
      ),
    );
  }
}

/// The bar could not be read. Deliberately quiet — the rest of Home is still
/// useful, so this states the problem and offers a retry rather than taking
/// the screen over.
class CapacityCardError extends StatelessWidget {
  const CapacityCardError({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _CapacityShell(
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.brandHint,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// The card itself: one place for the padding, the border, and the tap target
/// so the three states above cannot drift apart.
class _CapacityShell extends StatelessWidget {
  const _CapacityShell({
    required this.child,
    this.onLongPress,
    this.semanticsLabel,
  });

  final Widget child;
  final VoidCallback? onLongPress;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: child,
    );

    final Widget tappable = onLongPress == null
        ? card
        : GestureDetector(onLongPress: onLongPress, child: card);

    if (semanticsLabel == null) return tappable;

    return Semantics(
      container: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: tappable,
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level});

  final OccupancyLevel level;

  @override
  Widget build(BuildContext context) {
    final Color color = level.color;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            level.label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.brandSurfaceHi,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
