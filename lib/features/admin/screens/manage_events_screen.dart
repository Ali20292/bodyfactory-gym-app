import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/models.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_widgets.dart';
import 'event_editor_screen.dart';

/// Everything posted to Home, newest first, with the past dimmed rather than
/// hidden.
class ManageEventsScreen extends ConsumerWidget {
  const ManageEventsScreen({super.key});

  Future<void> _edit(BuildContext context, {GymEvent? existing}) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              EventEditorScreen(existing: existing),
        ),
      );

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    GymEvent event,
  ) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Delete "${event.title}"?'),
            content: const Text(
              'It disappears from every member\'s Home screen straight away.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    final String? error = await ref
        .read(adminActionsProvider.notifier)
        .deleteEvent(event.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Deleted.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<GymEvent>> events = ref.watch(adminEventsProvider);
    final DateTime now = DateTime.now();

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Events & offers'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.ink,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New post'),
        ),
        body: events.when(
          loading: () => const LoadingView(),
          error: (Object error, StackTrace _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(adminEventsProvider),
          ),
          data: (List<GymEvent> list) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.xxxl * 2,
            ),
            children: <Widget>[
              if (list.isEmpty)
                const AdminEmpty(
                  title: 'Nothing posted yet',
                  body:
                      'Anything you post here shows up on the members\' '
                      'Home screen.',
                )
              else
                for (final GymEvent event in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AdminListTile(
                      title: event.title,
                      subtitle:
                          '${AppDateFormat.dayLabel(event.startsAt)} · '
                          '${AppDateFormat.timeLabel(event.startsAt)}'
                          '${event.endsAt == null ? '' : ' → '
                                    '${AppDateFormat.shortDate(event.endsAt!)}'}',
                      badge: event.isOffer ? 'Offer' : 'Event',
                      badgeColor: event.isOffer
                          ? AppColors.accent
                          : AppColors.cream,
                      // Members only see what is still to come; staff see it
                      // all, with the finished ones pushed back visually.
                      isDimmed: event.isPastAt(now),
                      onTap: () => _edit(context, existing: event),
                      actions: <AdminAction>[
                        AdminAction(
                          label: 'Edit',
                          onSelected: () => _edit(context, existing: event),
                        ),
                        AdminAction(
                          label: 'Delete',
                          isDestructive: true,
                          onSelected: () => _delete(context, ref, event),
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
