import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../controllers/reservations_controller.dart';
import 'async_list_view.dart';

/// What the member has booked, soonest first, each with a way out.
class MyReservationsTab extends ConsumerWidget {
  const MyReservationsTab({super.key});

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    ReservationView view,
  ) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Cancel this booking?'),
            content: Text(
              '${view.title} — ${AppDateFormat.dayLabel(view.reservation.startsAt)} '
              'at ${AppDateFormat.timeLabel(view.reservation.startsAt)}.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep it'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Cancel booking'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    final BookingOutcome outcome = await ref
        .read(bookingControllerProvider.notifier)
        .cancel(view.reservation);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          outcome.isSuccess ? 'Booking cancelled.' : outcome.error!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ReservationView>> views = ref.watch(
      myReservationViewsProvider,
    );
    final BookingState booking = ref.watch(bookingControllerProvider);

    return AsyncListView<ReservationView>(
      value: views,
      onRefresh: () async {
        ref.invalidate(myReservationsProvider);
        await ref.read(myReservationsProvider.future);
      },
      emptyIcon: Icons.event_available_rounded,
      emptyTitle: 'Nothing booked yet',
      emptyBody:
          'Sessions with a trainer and classes you join will show up here.',
      itemBuilder: (BuildContext context, ReservationView view) =>
          _ReservationCard(
            view: view,
            isPending: booking.isPending(view.reservation.id),
            onCancel: () => _cancel(context, ref, view),
          ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.view,
    required this.isPending,
    required this.onCancel,
  });

  final ReservationView view;
  final bool isPending;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final DateTime startsAt = view.reservation.startsAt;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(view.icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  view.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  view.subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.brandMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${AppDateFormat.dayLabel(startsAt)} · '
                  '${AppDateFormat.timeLabel(startsAt)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.cream,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (isPending)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Cancel'),
            ),
        ],
      ),
    );
  }
}
