import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/models.dart';
import '../controllers/calendar_controller.dart';
import 'note_editor_sheet.dart';

/// Everything about one day: whether you trained, what is on, and your note.
Future<void> showDayDetailSheet(BuildContext context, DateTime day) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.brandSurface,
    builder: (BuildContext context) => _DaySheet(day: day),
  );
}

class _DaySheet extends ConsumerWidget {
  const _DaySheet({required this.day});

  final DateTime day;

  DateTime get _month => DateTime(day.year, day.month);

  Future<void> _report(
    BuildContext context,
    String? error,
    String success,
  ) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? success)));
  }

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    CalendarNote? existing,
  ) async {
    final String? label = await showNoteEditorSheet(
      context,
      date: day,
      initial: existing?.label,
    );
    if (label == null || !context.mounted) return;

    final String? error = await ref
        .read(calendarActionsProvider.notifier)
        .saveNote(date: day, label: label);

    if (!context.mounted) return;
    Navigator.of(context).pop();
    await _report(context, error, 'Note saved.');
  }

  Future<void> _deleteNote(
    BuildContext context,
    WidgetRef ref,
    CalendarNote note,
  ) async {
    final String? error = await ref
        .read(calendarActionsProvider.notifier)
        .deleteNote(note.id);

    if (!context.mounted) return;
    Navigator.of(context).pop();
    await _report(context, error, 'Note deleted.');
  }

  Future<void> _paste(BuildContext context, WidgetRef ref) async {
    final String? error = await ref
        .read(calendarActionsProvider.notifier)
        .pasteOnto(day);

    if (!context.mounted) return;
    Navigator.of(context).pop();
    await _report(context, error, 'Pasted.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CalendarMonthData? data = ref
        .watch(calendarMonthDataProvider(_month))
        .valueOrNull;

    final CalendarNote? note = data?.noteOn(day);
    final AttendanceRecord? attendance = data?.attendanceOn(day);
    final List<GymEvent> events = data?.eventsOn(day) ?? const <GymEvent>[];
    final String? clipboard = ref.watch(noteClipboardProvider);

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
              AppDateFormat.dayLabel(day),
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.cream),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${AppDateFormat.shortDate(day)} ${day.year}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _AttendanceRow(attendance: attendance),

            if (events.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              Text(
                "What's on",
                style: AppTextStyles.fieldLabel.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final GymEvent event in events)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _EventRow(event: event),
                ),
            ],

            const SizedBox(height: AppSpacing.xl),
            Text(
              'Your note',
              style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (note == null)
              Text(
                'Nothing planned for this day yet.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.brandHint,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.brandSurfaceHi,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  note.label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.accentHi,
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                _Action(
                  icon: note == null ? Icons.add_rounded : Icons.edit_outlined,
                  label: note == null ? 'Add note' : 'Edit',
                  onTap: () => _editNote(context, ref, note),
                ),
                if (note != null)
                  _Action(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    onTap: () {
                      ref.read(noteClipboardProvider.notifier).copy(note.label);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Copied "${note.label}" — open another day to paste.',
                          ),
                        ),
                      );
                    },
                  ),
                if (clipboard != null && clipboard != note?.label)
                  _Action(
                    icon: Icons.content_paste_rounded,
                    label: 'Paste "$clipboard"',
                    onTap: () => _paste(context, ref),
                  ),
                if (note != null)
                  _Action(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    isDestructive: true,
                    onTap: () => _deleteNote(context, ref, note),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({this.attendance});

  final AttendanceRecord? attendance;

  @override
  Widget build(BuildContext context) {
    final bool attended = attendance?.attended ?? false;
    final DateTime? checkIn = attendance?.checkInAt;

    return Row(
      children: <Widget>[
        Icon(
          attended ? Icons.check_circle_rounded : Icons.remove_circle_outline,
          size: 20,
          color: attended ? AppColors.occupancyQuiet : AppColors.brandHint,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            switch ((attended, checkIn)) {
              (true, final DateTime at) =>
                'You trained — checked in at ${AppDateFormat.timeLabel(at)}',
              (true, _) => 'You trained',
              _ => 'No check-in recorded',
            },
            style: AppTextStyles.bodyMedium.copyWith(
              color: attended ? AppColors.cream : AppColors.brandMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final GymEvent event;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          event.isOffer ? Icons.local_offer_rounded : Icons.event_rounded,
          size: 18,
          color: AppColors.accent,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                event.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.cream,
                ),
              ),
              Text(
                AppDateFormat.timeLabel(event.startsAt),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color color = isDestructive ? AppColors.danger : AppColors.accent;

    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md - 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 17, color: color),
              const SizedBox(width: AppSpacing.sm),
              // Capped so a long pasted label cannot stretch the chip past
              // the sheet.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
