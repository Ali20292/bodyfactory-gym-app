import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/models.dart';
import '../../reservations/widgets/trainer_avatar.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_widgets.dart';
import 'trainer_editor_screen.dart';

/// The coaching team, and the way to their schedules.
class ManageTrainersScreen extends ConsumerWidget {
  const ManageTrainersScreen({super.key});

  Future<void> _edit(BuildContext context, {Trainer? existing}) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              TrainerEditorScreen(existing: existing),
        ),
      );

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Trainer trainer,
  ) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Remove ${trainer.name}?'),
            content: const Text(
              'Their remaining times are withdrawn. If anyone still holds a '
              'session with them, this is refused.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    final String? error = await ref
        .read(adminActionsProvider.notifier)
        .deleteTrainer(trainer.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? '${trainer.name} removed.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trainer>> trainers = ref.watch(adminTrainersProvider);

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Trainers'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.ink,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New trainer'),
        ),
        body: trainers.when(
          loading: () => const LoadingView(),
          error: (Object error, StackTrace _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(adminTrainersProvider),
          ),
          data: (List<Trainer> list) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.xxxl * 2,
            ),
            children: <Widget>[
              if (list.isEmpty)
                const AdminEmpty(
                  title: 'No trainers yet',
                  body: 'Add a coach and members can book time with them.',
                )
              else
                for (final Trainer trainer in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AdminListTile(
                      leading: TrainerAvatar(
                        name: trainer.name,
                        photoUrl: trainer.photoUrl,
                        size: 40,
                      ),
                      title: trainer.name,
                      subtitle: trainer.specialties.join(' · '),
                      onTap: () => context.push(
                        AppRoutes.manageTrainerSlotsFor(trainer.id),
                      ),
                      actions: <AdminAction>[
                        AdminAction(
                          label: 'Times & bookings',
                          onSelected: () => context.push(
                            AppRoutes.manageTrainerSlotsFor(trainer.id),
                          ),
                        ),
                        AdminAction(
                          label: 'Edit',
                          onSelected: () => _edit(context, existing: trainer),
                        ),
                        AdminAction(
                          label: 'Remove',
                          isDestructive: true,
                          onSelected: () => _delete(context, ref, trainer),
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
