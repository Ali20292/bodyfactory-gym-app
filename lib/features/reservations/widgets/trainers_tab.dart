import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../data/models/models.dart';
import '../controllers/reservations_controller.dart';
import 'async_list_view.dart';
import 'trainer_card.dart';

/// Everyone who takes one-to-one sessions. Tapping a card opens that
/// trainer's schedule, which is where a session actually gets booked.
class TrainersTab extends ConsumerWidget {
  const TrainersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trainer>> trainers = ref.watch(trainersProvider);

    return AsyncListView<Trainer>(
      value: trainers,
      onRefresh: () async {
        ref.invalidate(trainersProvider);
        await ref.read(trainersProvider.future);
      },
      emptyIcon: Icons.fitness_center_rounded,
      emptyTitle: 'No trainers listed yet',
      emptyBody: 'The gym has not published its coaching team here yet.',
      itemBuilder: (BuildContext context, Trainer trainer) => TrainerCard(
        trainer: trainer,
        onTap: () => context.push(AppRoutes.trainerDetailFor(trainer.id)),
      ),
    );
  }
}
