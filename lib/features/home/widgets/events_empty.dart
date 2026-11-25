import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/body_factory_mark.dart';

/// What the list says when the gym has nothing on.
///
/// The illustration is the brand mark itself, dimmed — it needs no asset, it
/// scales, and an empty screen is a reasonable place for the logo to show up.
class EventsEmpty extends StatelessWidget {
  const EventsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Column(
        children: <Widget>[
          const Opacity(opacity: 0.35, child: BodyFactoryMark(size: 64)),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'No upcoming events right now',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Workshops and offers show up here as soon as the gym posts them.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.brandMuted,
            ),
          ),
        ],
      ),
    );
  }
}
