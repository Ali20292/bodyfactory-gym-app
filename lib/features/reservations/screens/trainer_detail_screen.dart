import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/models.dart';
import '../controllers/reservations_controller.dart';
import '../widgets/confirm_booking_sheet.dart';
import '../widgets/slot_picker.dart';
import '../widgets/specialty_chips.dart';
import '../widgets/trainer_avatar.dart';

/// One trainer: who they are, and when you can have them.
class TrainerDetailScreen extends ConsumerWidget {
  const TrainerDetailScreen({super.key, required this.trainerId});

  final String trainerId;

  Future<void> _book(
    BuildContext context,
    WidgetRef ref,
    Trainer trainer,
    TrainerSlot slot,
  ) async {
    final bool confirmed = await showBookingConfirmSheet(
      context,
      subtitle: 'Book a session',
      title: trainer.name,
      details: <BookingDetail>[
        BookingDetail(
          Icons.event_rounded,
          '${AppDateFormat.dayLabel(slot.startsAt)}, '
          '${AppDateFormat.timeLabel(slot.startsAt)}',
        ),
        BookingDetail(
          Icons.timelapse_rounded,
          '${slot.durationMinutes} minutes',
        ),
        if (trainer.specialties.isNotEmpty)
          BookingDetail(
            Icons.local_fire_department_rounded,
            trainer.specialties.join(', '),
          ),
      ],
    );

    if (!confirmed || !context.mounted) return;

    final BookingOutcome outcome = await ref
        .read(bookingControllerProvider.notifier)
        .bookTrainerSlot(slot);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          outcome.isSuccess
              ? 'Booked — ${trainer.name}, '
                    '${AppDateFormat.dayLabel(slot.startsAt).toLowerCase()} at '
                    '${AppDateFormat.timeLabel(slot.startsAt)}.'
              : outcome.error!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Trainer> trainer = ref.watch(trainerProvider(trainerId));

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        extendBodyBehindAppBar: true,
        body: trainer.when(
          loading: () => const LoadingView(),
          error: (Object error, StackTrace _) => ErrorView(
            error: error is Failure
                ? error
                : const NetworkFailure('We could not load that trainer.'),
            onRetry: () => ref.invalidate(trainerProvider(trainerId)),
          ),
          data: (Trainer value) => _Body(trainer: value, onBook: _book),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.trainer, required this.onBook});

  final Trainer trainer;
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    Trainer trainer,
    TrainerSlot slot,
  )
  onBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TrainerSlot>> slots = ref.watch(
      trainerSlotsProvider(trainer.id),
    );
    final BookingState booking = ref.watch(bookingControllerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(trainerSlotsProvider(trainer.id));
        await ref.read(trainerSlotsProvider(trainer.id).future);
      },
      color: AppColors.accent,
      backgroundColor: AppColors.brandSurface,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.sm,
          AppSpacing.screenH,
          AppSpacing.xxxl,
        ),
        children: <Widget>[
          _ProfileHeader(trainer: trainer),
          const SizedBox(height: AppSpacing.xl),
          Text(
            trainer.bio,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cream),
          ),
          const SizedBox(height: AppSpacing.section),
          Text(
            'Pick a time',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.cream),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Times already taken are crossed out.',
            style: AppTextStyles.caption.copyWith(color: AppColors.brandMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          slots.when(
            skipLoadingOnRefresh: true,
            loading: () => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xl),
              child: LoadingView(),
            ),
            error: (Object error, StackTrace _) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(trainerSlotsProvider(trainer.id)),
            ),
            data: (List<TrainerSlot> value) => SlotPicker(
              slots: value,
              pendingSlotId: booking.pendingId,
              onSelected: (TrainerSlot slot) =>
                  onBook(context, ref, trainer, slot),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.trainer});

  final Trainer trainer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TrainerAvatar(
          name: trainer.name,
          photoUrl: trainer.photoUrl,
          size: 108,
          ring: false,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          trainer.name,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.cream,
            fontSize: 26,
          ),
        ),
        if (trainer.rating != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.star_rounded,
                size: 18,
                color: AppColors.accentHi,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '${trainer.rating!.toStringAsFixed(1)} from members',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: SpecialtyChips(
            specialties: trainer.specialties,
            compact: false,
          ),
        ),
      ],
    );
  }
}
