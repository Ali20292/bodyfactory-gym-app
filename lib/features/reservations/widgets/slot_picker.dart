import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_date.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/models.dart';

/// A trainer's schedule, grouped by day, as tappable times.
///
/// Taken and past slots are shown struck through rather than dropped. Hiding
/// them makes a full week look like an empty one, and the member cannot tell
/// the difference between "nothing on Tuesday" and "Tuesday is gone".
class SlotPicker extends StatelessWidget {
  const SlotPicker({
    super.key,
    required this.slots,
    required this.onSelected,
    this.pendingSlotId,
  });

  final List<TrainerSlot> slots;

  /// Called with a slot the member may actually book. Taken and past slots do
  /// not call back at all.
  final ValueChanged<TrainerSlot> onSelected;

  /// The slot currently being written, if any.
  final String? pendingSlotId;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final Map<String, List<TrainerSlot>> byDay = _groupByDay(slots, now);

    if (byDay.isEmpty) {
      return const _EmptySchedule();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final MapEntry<String, List<TrainerSlot>> day in byDay.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppDateFormat.dayLabel(day.value.first.startsAt, now: now),
                  style: AppTextStyles.fieldLabel.copyWith(
                    color: AppColors.brandMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    for (final TrainerSlot slot in day.value)
                      _SlotChip(
                        slot: slot,
                        isBookable: slot.isBookableAt(now),
                        isPending: pendingSlotId == slot.id,
                        onTap: () => onSelected(slot),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Days in order, each with its slots in order. Whole days that are entirely
  /// in the past are dropped — a day that has already happened is noise, not
  /// information.
  Map<String, List<TrainerSlot>> _groupByDay(
    List<TrainerSlot> slots,
    DateTime now,
  ) {
    final Map<String, List<TrainerSlot>> byDay = <String, List<TrainerSlot>>{};

    for (final TrainerSlot slot in slots) {
      if (AppDate.dayOf(slot.startsAt).isBefore(AppDate.dayOf(now))) continue;
      byDay
          .putIfAbsent(AppDate.keyOf(slot.startsAt), () => <TrainerSlot>[])
          .add(slot);
    }

    for (final List<TrainerSlot> day in byDay.values) {
      day.sort(
        (TrainerSlot a, TrainerSlot b) => a.startsAt.compareTo(b.startsAt),
      );
    }

    return byDay;
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isBookable,
    required this.isPending,
    required this.onTap,
  });

  final TrainerSlot slot;
  final bool isBookable;
  final bool isPending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = isBookable
        ? AppColors.accent.withValues(alpha: 0.5)
        : AppColors.brandLine;
    final Color text = isBookable ? AppColors.cream : AppColors.brandHint;

    return Semantics(
      button: isBookable,
      enabled: isBookable,
      label: isBookable
          ? '${AppDateFormat.timeLabel(slot.startsAt)}, available'
          : '${AppDateFormat.timeLabel(slot.startsAt)}, taken',
      child: Material(
        color: isBookable
            ? AppColors.accent.withValues(alpha: 0.10)
            : AppColors.brandSurfaceHi,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: isBookable && !isPending ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: border),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md - 2,
            ),
            child: isPending
                ? const SizedBox(
                    width: 54,
                    height: 18,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : Text(
                    AppDateFormat.timeLabel(slot.startsAt),
                    style: AppTextStyles.caption.copyWith(
                      color: text,
                      fontWeight: FontWeight.w600,
                      decoration: isBookable
                          ? null
                          : TextDecoration.lineThrough,
                      decorationColor: AppColors.brandHint,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Text(
        'No times published yet. Ask at the front desk and they will add some.',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brandMuted),
      ),
    );
  }
}
