import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_date.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/models.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/publish_slots_sheet.dart';

/// One trainer's bookable times, and who holds them.
class TrainerSlotsScreen extends ConsumerWidget {
  const TrainerSlotsScreen({super.key, required this.trainerId});

  final String trainerId;

  Future<void> _publish(BuildContext context, WidgetRef ref) async {
    final PublishRequest? request = await showPublishSlotsSheet(context);
    if (request == null || !context.mounted) return;

    final String? error = await ref
        .read(adminActionsProvider.notifier)
        .publishSlots(
          trainerId: trainerId,
          startTimes: request.startTimes,
          durationMinutes: request.durationMinutes,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              '${request.startTimes.length} '
                  '${request.startTimes.length == 1 ? "time" : "times"} '
                  'published.',
        ),
      ),
    );
  }

  Future<void> _deleteSlot(
    BuildContext context,
    WidgetRef ref,
    TrainerSlot slot,
  ) async {
    final String? error = await ref
        .read(adminActionsProvider.notifier)
        .deleteSlot(slot.id);

    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TrainerSlot>> slots = ref.watch(
      adminTrainerSlotsProvider(trainerId),
    );
    final Map<String, RosterEntry> roster =
        ref.watch(trainerRosterProvider(trainerId)).valueOrNull ??
        const <String, RosterEntry>{};
    final Trainer? trainer = ref
        .watch(adminTrainersProvider)
        .valueOrNull
        ?.where((Trainer t) => t.id == trainerId)
        .firstOrNull;

    final DateTime now = DateTime.now();

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(trainer?.name ?? 'Times'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _publish(context, ref),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.ink,
          icon: const Icon(Icons.more_time_rounded),
          label: const Text('Publish times'),
        ),
        body: slots.when(
          loading: () => const LoadingView(),
          error: (Object error, StackTrace _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(adminTrainerSlotsProvider(trainerId)),
          ),
          data: (List<TrainerSlot> list) {
            // Only what is still to come: a past schedule is noise on a screen
            // whose job is publishing the next few weeks.
            final List<TrainerSlot> upcoming =
                list.where((TrainerSlot slot) => !slot.isPastAt(now)).toList()
                  ..sort(
                    (TrainerSlot a, TrainerSlot b) =>
                        a.startsAt.compareTo(b.startsAt),
                  );

            final Map<String, List<TrainerSlot>> byDay =
                <String, List<TrainerSlot>>{};
            for (final TrainerSlot slot in upcoming) {
              byDay
                  .putIfAbsent(
                    AppDate.keyOf(slot.startsAt),
                    () => <TrainerSlot>[],
                  )
                  .add(slot);
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.lg,
                AppSpacing.screenH,
                AppSpacing.xxxl * 2,
              ),
              children: <Widget>[
                if (upcoming.isEmpty)
                  const AdminEmpty(
                    title: 'No times published',
                    body: 'Publish some and members can book them.',
                  )
                else
                  for (final List<TrainerSlot> day in byDay.values) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.sm,
                        bottom: AppSpacing.md,
                      ),
                      child: Text(
                        AppDateFormat.dayLabel(day.first.startsAt),
                        style: AppTextStyles.fieldLabel.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    for (final TrainerSlot slot in day)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _SlotRow(
                          slot: slot,
                          bookedBy: roster[slot.id],
                          onDelete: () => _deleteSlot(context, ref, slot),
                        ),
                      ),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot, required this.onDelete, this.bookedBy});

  final TrainerSlot slot;
  final RosterEntry? bookedBy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final RosterEntry? booked = bookedBy;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: slot.isBooked
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.brandLine,
        ),
      ),
      child: Row(
        children: <Widget>[
          Text(
            AppDateFormat.timeLabel(slot.startsAt),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cream),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '${slot.durationMinutes} min',
            style: AppTextStyles.caption.copyWith(color: AppColors.brandHint),
          ),
          const Spacer(),
          if (slot.isBooked)
            Flexible(
              child: Text(
                // The name is the point of showing this to staff at all.
                booked?.username ?? 'Booked',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.brandHint,
              visualDensity: VisualDensity.compact,
              tooltip: 'Withdraw this time',
            ),
        ],
      ),
    );
  }
}
