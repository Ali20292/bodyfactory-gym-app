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
import '../controllers/account_controller.dart';

/// Guest invitations: how many are left, and where the others went.
class InvitationsScreen extends ConsumerWidget {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Member> profile = ref.watch(profileProvider);
    final AsyncValue<List<InvitationUsage>> history = ref.watch(
      invitationHistoryProvider,
    );

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Invitations'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.lg,
            AppSpacing.screenH,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            _RemainingCard(
              remaining: profile.valueOrNull?.invitationsRemaining,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Already used',
              style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            history.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xl),
                child: LoadingView(),
              ),
              error: (Object error, StackTrace _) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(invitationHistoryProvider),
              ),
              data: (List<InvitationUsage> used) => used.isEmpty
                  ? Text(
                      'None used yet.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.brandHint,
                      ),
                    )
                  : Column(
                      children: <Widget>[
                        for (final InvitationUsage usage in used)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _UsageRow(usage: usage),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemainingCard extends StatelessWidget {
  const _RemainingCard({this.remaining});

  final int? remaining;

  @override
  Widget build(BuildContext context) {
    final int count = remaining ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            '$count',
            style: AppTextStyles.statNumber.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            count == 1 ? 'invitation left' : 'invitations left',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            // Redeeming is a front-desk process today. Saying so is better
            // than a button that does nothing, and better than implying the
            // app can hand out a pass it has no endpoint for.
            'Bring a guest and give your membership ID at the front desk.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.brandMuted),
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.usage});

  final InvitationUsage usage;

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
            Icons.person_add_alt_1_rounded,
            size: 20,
            color: AppColors.brandHint,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              usage.guestName ?? 'Guest',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cream),
            ),
          ),
          Text(
            '${AppDateFormat.shortDate(usage.usedAt)} ${usage.usedAt.year}',
            style: AppTextStyles.caption.copyWith(color: AppColors.brandMuted),
          ),
        ],
      ),
    );
  }
}
