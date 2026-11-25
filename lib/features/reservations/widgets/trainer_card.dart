import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';
import 'specialty_chips.dart';
import 'trainer_avatar.dart';

/// One trainer in the list: photo, name, what they specialise in.
///
/// Tapping opens their schedule — the card itself books nothing, because
/// which hour you want is the whole decision.
class TrainerCard extends StatelessWidget {
  const TrainerCard({super.key, required this.trainer, required this.onTap});

  final Trainer trainer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandSurface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.brandLine),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TrainerAvatar(name: trainer.name, photoUrl: trainer.photoUrl),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            trainer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.cream,
                            ),
                          ),
                        ),
                        if (trainer.rating != null)
                          _Rating(rating: trainer.rating!),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SpecialtyChips(
                      specialties: trainer.specialties,
                      // Two fit on the narrowest phone; the rest roll into a
                      // "+1" rather than pushing the card taller.
                      maxToShow: 2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'See available times',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.brandMuted,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.brandHint,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.star_rounded, size: 16, color: AppColors.accentHi),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.cream,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
