import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_date.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/models.dart';
import '../controllers/reservations_controller.dart';
import 'async_list_view.dart';
import 'class_card.dart';
import 'confirm_booking_sheet.dart';

/// Upcoming classes, grouped under a date heading, each with a Join button.
class ClassesTab extends ConsumerWidget {
  const ClassesTab({super.key});

  Future<void> _join(
    BuildContext context,
    WidgetRef ref,
    GymClass gymClass,
  ) async {
    final bool confirmed = await showBookingConfirmSheet(
      context,
      subtitle: 'Join this class',
      title: gymClass.name,
      confirmLabel: 'Join class',
      details: <BookingDetail>[
        BookingDetail(
          Icons.event_rounded,
          '${AppDateFormat.dayLabel(gymClass.startsAt)}, '
          '${AppDateFormat.timeLabel(gymClass.startsAt)}',
        ),
        BookingDetail(
          Icons.timelapse_rounded,
          '${gymClass.durationMinutes} minutes',
        ),
        BookingDetail(Icons.person_outline_rounded, gymClass.instructorName),
        BookingDetail(Icons.place_outlined, gymClass.room),
      ],
      note: '${gymClass.spotsRemaining} of ${gymClass.capacity} spots left.',
    );

    if (!confirmed || !context.mounted) return;

    final BookingOutcome outcome = await ref
        .read(bookingControllerProvider.notifier)
        .joinClass(gymClass);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          outcome.isSuccess
              ? "You're in — ${gymClass.name}, "
                    '${AppDateFormat.dayLabel(gymClass.startsAt).toLowerCase()} '
                    'at ${AppDateFormat.timeLabel(gymClass.startsAt)}.'
              : outcome.error!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<GymClass>> classes = ref.watch(classesProvider);
    final Set<String> joined = ref.watch(bookedReferenceIdsProvider);
    final BookingState booking = ref.watch(bookingControllerProvider);

    return AsyncListView<_ClassRow>(
      // Flattened to rows so the date headings scroll with the cards and the
      // list stays lazy — grouping into nested Columns would build every
      // class on the first frame.
      value: classes.whenData(_withDateHeadings),
      onRefresh: () async {
        ref.invalidate(classesProvider);
        ref.invalidate(myReservationsProvider);
        await ref.read(classesProvider.future);
      },
      emptyIcon: Icons.event_busy_rounded,
      emptyTitle: 'No classes scheduled',
      emptyBody:
          'Nothing on the timetable right now. Check back in a day or two.',
      itemBuilder: (BuildContext context, _ClassRow row) => switch (row) {
        _DateHeading(:final DateTime date) => _Heading(date: date),
        _ClassEntry(:final GymClass gymClass) => ClassCard(
          gymClass: gymClass,
          isJoined: joined.contains(gymClass.id),
          isPending: booking.isPending(gymClass.id),
          onJoin: () => _join(context, ref, gymClass),
        ),
      },
    );
  }

  /// Inserts a heading row whenever the day changes. The list arrives sorted
  /// by start time, so one pass is enough.
  List<_ClassRow> _withDateHeadings(List<GymClass> classes) {
    final List<_ClassRow> rows = <_ClassRow>[];
    String? currentDay;

    for (final GymClass gymClass in classes) {
      final String day = AppDate.keyOf(gymClass.startsAt);
      if (day != currentDay) {
        currentDay = day;
        rows.add(_DateHeading(AppDate.dayOf(gymClass.startsAt)));
      }
      rows.add(_ClassEntry(gymClass));
    }

    return rows;
  }
}

sealed class _ClassRow {
  const _ClassRow();
}

class _DateHeading extends _ClassRow {
  const _DateHeading(this.date);

  final DateTime date;
}

class _ClassEntry extends _ClassRow {
  const _ClassEntry(this.gymClass);

  final GymClass gymClass;
}

class _Heading extends StatelessWidget {
  const _Heading({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          Text(
            AppDateFormat.dayLabel(date),
            style: AppTextStyles.fieldLabel.copyWith(color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(child: Divider(color: AppColors.brandLine)),
        ],
      ),
    );
  }
}
