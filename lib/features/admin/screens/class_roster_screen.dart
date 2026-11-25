import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/models.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_widgets.dart';

/// Who is booked into a class.
///
/// This is the one staff screen made of other members' data, so it carries the
/// least that lets someone run the session: a name and the membership ID they
/// would quote at the desk. No phone numbers, no history.
class ClassRosterScreen extends ConsumerWidget {
  const ClassRosterScreen({super.key, required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<RosterEntry>> roster = ref.watch(
      classRosterProvider(classId),
    );
    final GymClass? gymClass = ref
        .watch(adminClassesProvider)
        .valueOrNull
        ?.where((GymClass c) => c.id == classId)
        .firstOrNull;

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(gymClass?.name ?? 'Roster'),
        ),
        body: roster.when(
          loading: () => const LoadingView(),
          error: (Object error, StackTrace _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(classRosterProvider(classId)),
          ),
          data: (List<RosterEntry> entries) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.xxxl,
            ),
            children: <Widget>[
              if (gymClass != null) ...<Widget>[
                Text(
                  '${AppDateFormat.dayLabel(gymClass.startsAt)} · '
                  '${AppDateFormat.timeLabel(gymClass.startsAt)} · '
                  '${gymClass.room}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.brandMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${entries.length} of ${gymClass.capacity} places taken',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              if (entries.isEmpty)
                const AdminEmpty(
                  title: 'Nobody booked yet',
                  body: 'Names appear here as members join.',
                )
              else
                for (final RosterEntry entry in entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _RosterRow(entry: entry),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RosterRow extends StatelessWidget {
  const _RosterRow({required this.entry});

  final RosterEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.person_rounded,
            size: 18,
            color: AppColors.brandHint,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              entry.username,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cream),
            ),
          ),
          Text(
            entry.memberId,
            style: AppTextStyles.caption.copyWith(color: AppColors.brandMuted),
          ),
        ],
      ),
    );
  }
}
