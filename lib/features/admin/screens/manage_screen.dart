import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../data/models/models.dart';
import '../controllers/admin_controller.dart';

/// The staff hub: what the gym has posted, and the way in to change it.
class ManageScreen extends ConsumerWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int events = ref.watch(adminEventsProvider).valueOrNull?.length ?? 0;
    final List<GymClass> classes =
        ref.watch(adminClassesProvider).valueOrNull ?? const <GymClass>[];
    final int trainers =
        ref.watch(adminTrainersProvider).valueOrNull?.length ?? 0;

    final DateTime now = DateTime.now();
    final int upcomingClasses = classes
        .where((GymClass gymClass) => !gymClass.isPastAt(now))
        .length;

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.xxxl,
            ),
            children: <Widget>[
              Text(
                'Manage',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.cream,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'What members see, and who takes it',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _ManageCard(
                icon: Icons.campaign_rounded,
                title: 'Events & offers',
                subtitle: 'The cards on the members\' Home screen',
                count: events,
                onTap: () => context.push(AppRoutes.manageEvents),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ManageCard(
                icon: Icons.groups_rounded,
                title: 'Classes',
                subtitle: 'The timetable members book onto',
                count: upcomingClasses,
                countLabel: 'upcoming',
                onTap: () => context.push(AppRoutes.manageClasses),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ManageCard(
                icon: Icons.fitness_center_rounded,
                title: 'Trainers',
                subtitle: 'Coaches, their specialties and their times',
                count: trainers,
                onTap: () => context.push(AppRoutes.manageTrainers),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _StaffNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageCard extends StatelessWidget {
  const _ManageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onTap,
    this.countLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final String? countLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandSurface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.brandLine),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brandMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                countLabel == null ? '$count' : '$count ${countLabel!}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandHint,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.brandHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Says out loud what the role does and does not do.
///
/// Staff should not be left thinking the app is what keeps members out of
/// these screens.
class _StaffNote extends StatelessWidget {
  const _StaffNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.brandSurfaceHi,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.shield_outlined,
            size: 18,
            color: AppColors.brandHint,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'You are signed in as staff. Anything posted here is visible to '
              'every member straight away.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
