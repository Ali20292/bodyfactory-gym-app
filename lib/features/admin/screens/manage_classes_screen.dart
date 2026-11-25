import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/models.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_widgets.dart';
import 'class_editor_screen.dart';

/// The timetable, as staff see it: everything, with how full each class is.
class ManageClassesScreen extends ConsumerWidget {
  const ManageClassesScreen({super.key});

  Future<void> _edit(BuildContext context, {GymClass? existing}) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              ClassEditorScreen(existing: existing),
        ),
      );

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    GymClass gymClass,
  ) async {
    final int booked = gymClass.bookedCount;

    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Cancel ${gymClass.name}?'),
            content: Text(
              booked == 0
                  ? 'Nobody has booked it, so nobody is affected.'
                  // The number is the point: cancelling a full class is a
                  // different decision from cancelling an empty one.
                  : '$booked ${booked == 1 ? "person has" : "people have"} '
                        'booked. Their place is released and the class '
                        'disappears from the timetable.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep it'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Cancel class'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    final (int? released, String? error) = await ref
        .read(adminActionsProvider.notifier)
        .cancelClass(gymClass.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (released == 0
                  ? '${gymClass.name} cancelled.'
                  : '${gymClass.name} cancelled — $released '
                        '${released == 1 ? "booking" : "bookings"} released.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<GymClass>> classes = ref.watch(adminClassesProvider);
    final DateTime now = DateTime.now();

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Classes'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.ink,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New class'),
        ),
        body: classes.when(
          loading: () => const LoadingView(),
          error: (Object error, StackTrace _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(adminClassesProvider),
          ),
          data: (List<GymClass> list) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.xxxl * 2,
            ),
            children: <Widget>[
              if (list.isEmpty)
                const AdminEmpty(
                  title: 'No classes yet',
                  body:
                      'Add one and it appears under Reservations for every '
                      'member.',
                )
              else
                for (final GymClass gymClass in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AdminListTile(
                      title: gymClass.name,
                      subtitle:
                          '${AppDateFormat.dayLabel(gymClass.startsAt)} '
                          '${AppDateFormat.timeLabel(gymClass.startsAt)} · '
                          '${gymClass.instructorName} · ${gymClass.room}',
                      badge: gymClass.spotsLabel,
                      badgeColor: gymClass.isFull
                          ? AppColors.occupancyPacked
                          : AppColors.occupancyQuiet,
                      isDimmed: gymClass.isPastAt(now),
                      onTap: () => _edit(context, existing: gymClass),
                      actions: <AdminAction>[
                        AdminAction(
                          label: 'Edit',
                          onSelected: () => _edit(context, existing: gymClass),
                        ),
                        AdminAction(
                          label: 'Who is booked',
                          onSelected: () => context.push(
                            AppRoutes.manageClassRosterFor(gymClass.id),
                          ),
                        ),
                        AdminAction(
                          label: 'Cancel class',
                          isDestructive: true,
                          onSelected: () => _cancel(context, ref, gymClass),
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
