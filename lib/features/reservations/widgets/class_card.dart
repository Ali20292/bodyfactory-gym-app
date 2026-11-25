import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/models.dart';

/// One class, with the Join button as the point of the card.
class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.gymClass,
    required this.onJoin,
    this.isJoined = false,
    this.isPending = false,
  });

  final GymClass gymClass;

  final VoidCallback onJoin;

  /// The member already holds a confirmed booking for this class.
  final bool isJoined;

  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final bool isFull = gymClass.isFull;
    final bool canJoin = !isJoined && !isFull;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          // A class the member is in is outlined rather than filled: enough to
          // find at a glance, not enough to shout over the ones they can book.
          color: isJoined
              ? AppColors.accent.withValues(alpha: 0.55)
              : AppColors.brandLine,
        ),
      ),
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
                      gymClass.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'with ${gymClass.instructorName}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brandMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _SpotsBadge(gymClass: gymClass),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Flexible, not fixed: "Studio 2" is short but a room called
          // "Functional training area" is not, and neither the time nor the
          // room should be able to push the other off the card.
          Row(
            children: <Widget>[
              Flexible(
                child: _Fact(
                  icon: Icons.schedule_rounded,
                  text:
                      '${AppDateFormat.timeLabel(gymClass.startsAt)} · '
                      '${gymClass.durationMinutes} min',
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Flexible(
                child: _Fact(icon: Icons.place_outlined, text: gymClass.room),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            gymClass.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.brandMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: canJoin
                ? FilledButton(
                    onPressed: isPending ? null : onJoin,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: isPending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.ink,
                            ),
                          )
                        : const Text('Join'),
                  )
                : _StatusPill(
                    label: isJoined ? "You're in" : 'Class full',
                    icon: isJoined
                        ? Icons.check_circle_rounded
                        : Icons.block_rounded,
                    color: isJoined ? AppColors.accent : AppColors.brandHint,
                  ),
          ),
        ],
      ),
    );
  }
}

/// How many places are left, coloured by how close to full it is.
///
/// CLAUDE.md sketches this as "12/20 spots". On a device that reads badly: an
/// empty class shows "0/20" in green, and the number and the colour appear to
/// contradict each other — 0 looks like none left when it means none taken.
/// Counting down what is actually available says the same thing once.
class _SpotsBadge extends StatelessWidget {
  const _SpotsBadge({required this.gymClass});

  final GymClass gymClass;

  @override
  Widget build(BuildContext context) {
    final int remaining = gymClass.spotsRemaining;
    final Color color = switch (remaining) {
      0 => AppColors.occupancyPacked,
      <= 3 => AppColors.occupancyBusy,
      _ => AppColors.occupancyQuiet,
    };
    final String label = switch (remaining) {
      0 => 'Full',
      1 => '1 spot left',
      _ => '$remaining spots left',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 15, color: AppColors.brandHint),
        const SizedBox(width: AppSpacing.xs + 2),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: AppColors.cream),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.labelLarge.copyWith(color: color)),
        ],
      ),
    );
  }
}
