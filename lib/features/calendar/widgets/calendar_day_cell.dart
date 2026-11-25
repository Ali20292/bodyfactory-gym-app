import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// One day in the month grid.
///
/// Carries three signals at once — did you train, is something on, what did
/// you plan — so the cell has to stay legible at about 44x60. The note label
/// gets one line and is clipped; the sheet has the full text.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    this.noteLabel,
    this.attended = false,
    this.hasEvent = false,
    this.isSelected = false,
    this.isToday = false,
    this.isOutside = false,
  });

  final DateTime day;
  final String? noteLabel;
  final bool attended;
  final bool hasEvent;
  final bool isSelected;
  final bool isToday;

  /// A day from the neighbouring month, shown to fill the grid.
  final bool isOutside;

  @override
  Widget build(BuildContext context) {
    final Color number = isOutside
        ? AppColors.brandHint.withValues(alpha: 0.5)
        : AppColors.cream;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.accent.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: switch ((isSelected, isToday)) {
            (true, _) => AppColors.accent,
            // Today is marked with a ring rather than a fill, so selecting it
            // still reads as a change.
            (false, true) => AppColors.accent.withValues(alpha: 0.45),
            _ => Colors.transparent,
          },
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${day.day}',
            style: AppTextStyles.caption.copyWith(
              color: number,
              fontWeight: isToday || isSelected
                  ? FontWeight.w700
                  : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          if (noteLabel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                noteLabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: isOutside
                      ? AppColors.brandHint.withValues(alpha: 0.5)
                      : AppColors.accentHi,
                  fontSize: 8.5,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (attended || hasEvent) ...<Widget>[
            const SizedBox(height: AppSpacing.xxs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Attendance is a filled dot, an event is a hollow ring: two
                // shapes, so they are still distinguishable to someone who
                // cannot tell the two colours apart.
                if (attended) const _Dot(color: AppColors.occupancyQuiet),
                if (attended && hasEvent) const SizedBox(width: 3),
                if (hasEvent)
                  const _Dot(color: AppColors.accent, filled: false),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, this.filled = true});

  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: filled ? null : Border.all(color: color, width: 1.2),
      ),
    );
  }
}
