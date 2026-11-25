import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_date.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/calendar_repository.dart';
import '../controllers/calendar_controller.dart';

/// Lays a split over a date range.
///
/// Returns a sentence describing what happened, or null if nothing was
/// written. The caller shows it, along with the undo.
Future<String?> showApplyTemplateSheet(
  BuildContext context, {
  required SplitTemplate template,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.brandSurface,
    // The overwrite prompt has to be answered before this closes.
    isDismissible: true,
    builder: (BuildContext context) => _ApplySheet(template: template),
  );
}

class _ApplySheet extends ConsumerStatefulWidget {
  const _ApplySheet({required this.template});

  final SplitTemplate template;

  @override
  ConsumerState<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends ConsumerState<_ApplySheet> {
  SplitRepeatMode _mode = SplitRepeatMode.rotating;
  late DateTime _from = AppDate.today();
  late DateTime _to = AppDate.today().add(const Duration(days: 84));

  int get _dayCount => AppDate.daysApart(_from, _to) + 1;

  Future<void> _pickDate({required bool isStart}) async {
    final DateTime initial = isStart ? _from : _to;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: AppDate.today().subtract(const Duration(days: 365)),
      lastDate: AppDate.today().add(const Duration(days: 730)),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _from = AppDate.dayOf(picked);
        // Keeping the end after the start here means the Apply button never
        // has to explain an impossible range.
        if (!_to.isAfter(_from)) _to = _from.add(const Duration(days: 27));
      } else {
        _to = AppDate.dayOf(picked);
        if (!_to.isAfter(_from)) _from = _to.subtract(const Duration(days: 27));
      }
    });
  }

  void _setSpan(Duration span) {
    setState(() => _to = _from.add(span));
  }

  /// Asks what to do about days that already have a note. Null means cancel.
  Future<OverwritePolicy?> _resolveConflicts(int existing) async {
    return showDialog<OverwritePolicy>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Some days already have notes'),
        content: Text(
          existing < 0
              ? 'Some days in this range may already have notes. What should '
                    'happen to them?'
              : existing == 1
              ? 'One day in this range already has a note. What should happen '
                    'to it?'
              : '$existing days in this range already have notes. What should '
                    'happen to them?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(OverwritePolicy.keepExisting),
            child: const Text('Keep existing'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(OverwritePolicy.overwrite),
            child: const Text('Overwrite'),
          ),
        ],
      ),
    );
  }

  Future<void> _apply() async {
    final CalendarActions actions = ref.read(calendarActionsProvider.notifier);

    final int existing = await actions.countExistingNotes(from: _from, to: _to);
    if (!mounted) return;

    OverwritePolicy policy = OverwritePolicy.keepExisting;
    if (existing != 0) {
      final OverwritePolicy? chosen = await _resolveConflicts(existing);
      // Cancel: nothing is written, and the sheet stays open so the range is
      // not lost.
      if (chosen == null || !mounted) return;
      policy = chosen;
    }

    final (ApplyTemplateResult? result, String? error) = await actions
        .applyTemplate(
          template: widget.template,
          from: _from,
          to: _to,
          mode: _mode,
          onConflict: policy,
        );

    if (!mounted) return;

    if (error != null) {
      Navigator.of(context).pop(error);
      return;
    }

    final ApplyTemplateResult applied = result!;
    final String skipped = applied.skipped == 0
        ? ''
        : ', ${applied.skipped} left alone';
    Navigator.of(context).pop(
      '${widget.template.name} written to ${applied.written} '
      '${applied.written == 1 ? "day" : "days"}$skipped.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWriting = ref.watch(calendarActionsProvider).isWriting;

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
              'Repeat this split',
              style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.template.name,
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.cream),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.template.days.join(' → '),
              style: AppTextStyles.caption.copyWith(color: AppColors.accentHi),
            ),

            const SizedBox(height: AppSpacing.xl),
            _ModeSelector(
              mode: _mode,
              cycleLength: widget.template.cycleLength,
              onChanged: (SplitRepeatMode mode) => setState(() => _mode = mode),
            ),

            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Expanded(
                  child: _DateField(
                    label: 'From',
                    date: _from,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _DateField(
                    label: 'To',
                    date: _to,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                _SpanChip(
                  label: '4 weeks',
                  onTap: () => _setSpan(const Duration(days: 27)),
                ),
                _SpanChip(
                  label: '3 months',
                  onTap: () => _setSpan(const Duration(days: 90)),
                ),
                _SpanChip(
                  label: '6 months',
                  onTap: () => _setSpan(const Duration(days: 181)),
                ),
                _SpanChip(
                  label: 'A year',
                  onTap: () => _setSpan(const Duration(days: 364)),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              '$_dayCount ${_dayCount == 1 ? "day" : "days"} will be written.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.brandMuted,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            if (isWriting) ...<Widget>[
              const LinearProgressIndicator(
                color: AppColors.accent,
                backgroundColor: AppColors.brandSurfaceHi,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Writing $_dayCount days…',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
            ] else
              FilledButton(
                onPressed: _apply,
                child: const Text('Apply to calendar'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.mode,
    required this.cycleLength,
    required this.onChanged,
  });

  final SplitRepeatMode mode;
  final int cycleLength;
  final ValueChanged<SplitRepeatMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ModeOption(
          title: 'Rotating',
          // The distinction is the whole reason both modes exist, so each one
          // says what it does to *your* days rather than naming a strategy.
          subtitle:
              'A $cycleLength-day cycle that rolls forward, whatever the '
              'weekday. The usual shape for push/pull/legs.',
          isSelected: mode == SplitRepeatMode.rotating,
          onTap: () => onChanged(SplitRepeatMode.rotating),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ModeOption(
          title: 'Weekly',
          subtitle:
              'The same weekday always gets the same label. The first entry '
              'is Monday.',
          isSelected: mode == SplitRepeatMode.weekly,
          onTap: () => onChanged(SplitRepeatMode.weekly),
        ),
      ],
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.accent.withValues(alpha: 0.12)
          : AppColors.brandSurfaceHi,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.brandLine,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: isSelected ? AppColors.accent : AppColors.brandHint,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isSelected ? AppColors.accent : AppColors.cream,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brandMuted,
                      ),
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandSurfaceHi,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.brandLine),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${AppDateFormat.shortDate(date)} ${date.year}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpanChip extends StatelessWidget {
  const _SpanChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.brandLine),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.brandMuted),
          ),
        ),
      ),
    );
  }
}
