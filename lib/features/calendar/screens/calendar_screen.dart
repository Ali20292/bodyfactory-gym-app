import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_date.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../controllers/calendar_controller.dart';
import '../widgets/calendar_day_cell.dart';
import '../widgets/day_detail_sheet.dart';

/// The Calendar tab: attendance, what's on, and the training split.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// Held here rather than in a provider: which month you are looking at and
  /// how zoomed in you are is view state, and the tab shell keeps this screen
  /// alive, so it survives switching tabs anyway.
  DateTime _focused = AppDate.today();
  DateTime _selected = AppDate.today();
  CalendarFormat _format = CalendarFormat.month;

  /// The family key for the visible month. Must be the first of the month —
  /// see [calendarMonthDataProvider].
  DateTime get _month => DateTime(_focused.year, _focused.month);

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CalendarMonthData> monthAsync = ref.watch(
      calendarMonthDataProvider(_month),
    );
    // Null while the month loads. The grid still draws, just without markers,
    // which is far better than a spinner where the calendar should be.
    final CalendarMonthData? data = monthAsync.valueOrNull;
    final String? clipboard = ref.watch(noteClipboardProvider);

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
            children: <Widget>[
              _Header(onSplits: () => context.push(AppRoutes.splits)),
              if (clipboard != null)
                _ClipboardBanner(
                  label: clipboard,
                  onClear: () =>
                      ref.read(noteClipboardProvider.notifier).clear(),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _Calendar(
                  focused: _focused,
                  selected: _selected,
                  format: _format,
                  data: data,
                  onDaySelected: (DateTime selected, DateTime focused) {
                    setState(() {
                      _selected = selected;
                      _focused = focused;
                    });
                    showDayDetailSheet(context, selected);
                  },
                  onFormatChanged: (CalendarFormat format) =>
                      setState(() => _format = format),
                  onPageChanged: (DateTime focused) =>
                      setState(() => _focused = focused),
                ),
              ),
              if (monthAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.accent,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              const _Legend(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.focused,
    required this.selected,
    required this.format,
    required this.data,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  final DateTime focused;
  final DateTime selected;
  final CalendarFormat format;
  final CalendarMonthData? data;
  final void Function(DateTime, DateTime) onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final ValueChanged<DateTime> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return TableCalendar<void>(
      // Two years back and one forward: enough to review a training history
      // and to lay a split over the year ahead.
      firstDay: DateTime(AppDate.today().year - 2),
      lastDay: DateTime(AppDate.today().year + 1, 12, 31),
      focusedDay: focused,
      calendarFormat: format,
      availableCalendarFormats: const <CalendarFormat, String>{
        CalendarFormat.month: 'Month',
        CalendarFormat.twoWeeks: '2 weeks',
        CalendarFormat.week: 'Week',
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      rowHeight: 60,
      daysOfWeekHeight: 22,
      selectedDayPredicate: (DateTime day) => isSameDay(selected, day),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      headerStyle: HeaderStyle(
        titleCentered: false,
        formatButtonShowsNext: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.cream,
        ),
        formatButtonTextStyle: AppTextStyles.caption.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
        formatButtonDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
        ),
        leftChevronIcon: const Icon(
          Icons.chevron_left_rounded,
          color: AppColors.brandMuted,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.brandMuted,
        ),
        headerPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTextStyles.caption.copyWith(
          color: AppColors.brandHint,
          fontSize: 11,
        ),
        weekendStyle: AppTextStyles.caption.copyWith(
          color: AppColors.brandHint,
          fontSize: 11,
        ),
      ),
      // Every cell goes through one builder, so a day looks the same whether
      // it is today, selected, or from the month next door.
      calendarBuilders: CalendarBuilders<void>(
        defaultBuilder: (BuildContext context, DateTime day, DateTime _) =>
            _cell(day),
        todayBuilder: (BuildContext context, DateTime day, DateTime _) =>
            _cell(day, isToday: true),
        selectedBuilder: (BuildContext context, DateTime day, DateTime _) =>
            _cell(
              day,
              isSelected: true,
              isToday: isSameDay(day, DateTime.now()),
            ),
        outsideBuilder: (BuildContext context, DateTime day, DateTime _) =>
            _cell(day, isOutside: true),
        disabledBuilder: (BuildContext context, DateTime day, DateTime _) =>
            _cell(day, isOutside: true),
      ),
    );
  }

  Widget _cell(
    DateTime day, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
  }) {
    return CalendarDayCell(
      day: day,
      noteLabel: data?.noteOn(day)?.label,
      attended: data?.attendedOn(day) ?? false,
      hasEvent: (data?.eventsOn(day).isNotEmpty) ?? false,
      isToday: isToday,
      isSelected: isSelected,
      isOutside: isOutside,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSplits});

  final VoidCallback onSplits;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Calendar',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.cream,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Your training, day by day',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.brandMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onSplits,
            icon: const Icon(Icons.repeat_rounded, size: 18),
            label: const Text('Splits'),
          ),
        ],
      ),
    );
  }
}

/// Shown while something is on the clipboard, because otherwise the only clue
/// is a Paste button buried in a sheet the user has to open first.
class _ClipboardBanner extends StatelessWidget {
  const _ClipboardBanner({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xs,
        AppSpacing.screenH,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.copy_rounded, size: 16, color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '"$label" copied — open a day to paste it.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: AppColors.cream),
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 16),
            color: AppColors.brandMuted,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.sm,
        children: const <Widget>[
          _LegendItem(color: AppColors.occupancyQuiet, label: 'You trained'),
          _LegendItem(
            color: AppColors.accent,
            label: 'Gym event',
            filled: false,
          ),
          _LegendItem(
            color: AppColors.accentHi,
            label: 'Your note',
            isText: true,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.filled = true,
    this.isText = false,
  });

  final Color color;
  final String label;
  final bool filled;
  final bool isText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isText)
          Text(
            'Abc',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? color : Colors.transparent,
              border: filled ? null : Border.all(color: color, width: 1.2),
            ),
          ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.brandMuted),
        ),
      ],
    );
  }
}
