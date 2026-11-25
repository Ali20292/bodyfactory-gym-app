import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_date.dart';
import '../../../core/utils/date_format.dart';

/// The times to publish, and how long each session runs.
@immutable
class PublishRequest {
  const PublishRequest({
    required this.startTimes,
    required this.durationMinutes,
  });

  final List<DateTime> startTimes;
  final int durationMinutes;
}

/// Publishes a trainer's availability as days × hours.
///
/// A grid rather than one-slot-at-a-time: a coach's week is "these hours on
/// these days", and entering thirty times by hand is how a schedule ends up
/// never being published.
Future<PublishRequest?> showPublishSlotsSheet(BuildContext context) {
  return showModalBottomSheet<PublishRequest>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.brandSurface,
    builder: (BuildContext context) => const _PublishSheet(),
  );
}

class _PublishSheet extends StatefulWidget {
  const _PublishSheet();

  @override
  State<_PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends State<_PublishSheet> {
  /// The fortnight ahead, which is as far as most gyms publish.
  late final List<DateTime> _days = List<DateTime>.generate(
    14,
    (int index) => AppDate.today().add(Duration(days: index)),
  );

  final Set<String> _selectedDays = <String>{};
  final Set<int> _selectedHours = <int>{};
  int _duration = 60;

  static const List<int> _hours = <int>[
    7,
    8,
    9,
    10,
    11,
    12,
    16,
    17,
    18,
    19,
    20,
    21,
  ];

  int get _count => _selectedDays.length * _selectedHours.length;

  List<DateTime> _startTimes() {
    final DateTime now = DateTime.now();

    return <DateTime>[
      for (final DateTime day in _days)
        if (_selectedDays.contains(AppDate.keyOf(day)))
          for (final int hour in _selectedHours)
            DateTime(day.year, day.month, day.day, hour),
    ]..removeWhere((DateTime time) => time.isBefore(now));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Publish times',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.cream),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Pick the days and the hours. Times already published are left '
              'alone, so doing this twice is harmless.',
              style: AppTextStyles.caption.copyWith(color: AppColors.brandHint),
            ),

            const SizedBox(height: AppSpacing.xl),
            Text(
              'Days',
              style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final DateTime day in _days)
                  _Chip(
                    label: AppDateFormat.dayLabel(day),
                    isSelected: _selectedDays.contains(AppDate.keyOf(day)),
                    onTap: () => setState(() {
                      final String key = AppDate.keyOf(day);
                      if (!_selectedDays.remove(key)) _selectedDays.add(key);
                    }),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
            Text(
              'Hours',
              style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final int hour in _hours)
                  _Chip(
                    label: AppDateFormat.timeLabel(DateTime(2026, 1, 1, hour)),
                    isSelected: _selectedHours.contains(hour),
                    onTap: () => setState(() {
                      if (!_selectedHours.remove(hour)) {
                        _selectedHours.add(hour);
                      }
                    }),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
            Text(
              'Each session lasts',
              style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: <Widget>[
                for (final int minutes in <int>[30, 45, 60, 90])
                  _Chip(
                    label: '$minutes min',
                    isSelected: _duration == minutes,
                    onTap: () => setState(() => _duration = minutes),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _count == 0
                  ? null
                  : () => Navigator.of(context).pop(
                      PublishRequest(
                        startTimes: _startTimes(),
                        durationMinutes: _duration,
                      ),
                    ),
              child: Text(
                _count == 0
                    ? 'Pick days and hours'
                    : 'Publish $_count ${_count == 1 ? "time" : "times"}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.accent.withValues(alpha: 0.16)
          : AppColors.brandSurfaceHi,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.brandLine,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm - 1,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? AppColors.accent : AppColors.cream,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
