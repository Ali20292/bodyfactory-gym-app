import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/models.dart';
import '../controllers/calendar_controller.dart';
import '../widgets/apply_template_sheet.dart';
import '../widgets/template_editor_sheet.dart';

/// Saved training cycles, and the place to lay one over the calendar.
class SplitTemplatesScreen extends ConsumerWidget {
  const SplitTemplatesScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    SplitTemplate? existing,
  }) async {
    final SplitTemplate? draft = await showTemplateEditorSheet(
      context,
      existing: existing,
    );
    if (draft == null || !context.mounted) return;

    final SplitTemplate? saved = await ref
        .read(calendarActionsProvider.notifier)
        .saveTemplate(draft);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved == null
              ? 'A split needs a name and at least one day.'
              : '${saved.name} saved.',
        ),
      ),
    );
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    SplitTemplate template,
  ) async {
    final String? message = await showApplyTemplateSheet(
      context,
      template: template,
    );
    if (message == null || !context.mounted) return;

    // Captured now, and deliberately not `ref` itself. A snackbar outlives the
    // screen that showed it — walk back to the calendar and it follows you —
    // and by then this widget's `ref` is disposed, so an undo tapped from
    // there would throw instead of undoing anything. The notifier is not
    // auto-disposed, so holding it directly is safe.
    final CalendarActions actions = ref.read(calendarActionsProvider.notifier);
    final bool canUndo = ref.read(calendarActionsProvider).lastApply != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 8),
        action: canUndo
            ? SnackBarAction(label: 'Undo', onPressed: actions.undoLastApply)
            : null,
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SplitTemplate template,
  ) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Delete ${template.name}?'),
            content: const Text(
              'Days already written to the calendar stay as they are.',
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
    await ref
        .read(calendarActionsProvider.notifier)
        .deleteTemplate(template.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SplitTemplate>> templates = ref.watch(
      splitTemplatesProvider,
    );
    final UndoableApply? undo = ref.watch(calendarActionsProvider).lastApply;

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Splits'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context, ref),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.ink,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New split'),
        ),
        body: templates.when(
          loading: () => const LoadingView(),
          error: (Object error, StackTrace _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(splitTemplatesProvider),
          ),
          data: (List<SplitTemplate> list) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.xxxl * 2,
            ),
            children: <Widget>[
              Text(
                'Save a cycle once, then lay it over as many weeks as you '
                'want. Nothing is written until you choose a range.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
              if (undo != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                _UndoCard(undo: undo),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (list.isEmpty)
                Text(
                  'No splits yet.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.brandHint,
                  ),
                )
              else
                for (final SplitTemplate template in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: _TemplateCard(
                      template: template,
                      onApply: () => _apply(context, ref, template),
                      onEdit: () => _edit(context, ref, existing: template),
                      onDelete: () => _delete(context, ref, template),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kept on screen rather than only in a snackbar: a snackbar is gone in eight
/// seconds, and "I have just overwritten three months" is a thought that
/// arrives later than that.
class _UndoCard extends ConsumerWidget {
  const _UndoCard({required this.undo});

  final UndoableApply undo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int changed =
        undo.result.replaced.length + undo.result.createdDays.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${undo.templateName} changed $changed '
              '${changed == 1 ? "day" : "days"}.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cream),
            ),
          ),
          TextButton(
            onPressed: () async {
              final String? error = await ref
                  .read(calendarActionsProvider.notifier)
                  .undoLastApply();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error ?? 'Put back the way it was.')),
              );
            },
            child: const Text('Undo'),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  final SplitTemplate template;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  template.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.cream,
                  ),
                ),
              ),
              Text(
                '${template.cycleLength} days',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.brandSurfaceHi,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.brandHint,
                  size: 20,
                ),
                onSelected: (String value) =>
                    value == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (int i = 0; i < template.days.length; i++)
                _CycleChip(index: i, label: template.days[i]),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Repeat over a range'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleChip extends StatelessWidget {
  const _CycleChip({required this.index, required this.label});

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    // "Rest" is the absence of training, so it is drawn as an absence: muted
    // rather than accented, which makes the shape of a cycle readable at a
    // glance.
    final bool isRest = label.toLowerCase().trim() == 'rest';
    final Color color = isRest ? AppColors.brandMuted : AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '${index + 1}  $label',
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
