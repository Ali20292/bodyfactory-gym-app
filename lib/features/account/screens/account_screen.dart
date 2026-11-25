import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/models.dart';
import '../controllers/account_controller.dart';
import '../services/profile_image_service.dart';
import '../widgets/photo_source_sheet.dart';
import '../widgets/profile_avatar.dart';

/// The member's own page: who they are, what they have left, and the way out.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _isUploading = false;

  Future<void> _changePhoto() async {
    final PhotoOrigin? origin = await showPhotoSourceSheet(context);
    if (origin == null || !mounted) return;

    setState(() => _isUploading = true);
    final String? error = await ref
        .read(profileProvider.notifier)
        .changePhoto(origin);

    if (!mounted) return;
    setState(() => _isUploading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Member> profile = ref.watch(profileProvider);

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Account'),
          actions: <Widget>[
            IconButton(
              onPressed: () => context.push(AppRoutes.settings),
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
        body: profile.when(
          loading: () => const LoadingView(),
          error: (Object error, StackTrace _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(profileProvider),
          ),
          data: (Member member) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.sm,
              AppSpacing.screenH,
              AppSpacing.xxxl,
            ),
            children: <Widget>[
              Center(
                child: ProfileAvatar(
                  name: member.username,
                  imageUrl: member.profileImageUrl,
                  isBusy: _isUploading,
                  onTap: _changePhoto,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _NameRow(
                username: member.username,
                onEdit: () => context.push(AppRoutes.editUsername),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  'Member ${member.id}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.brandMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              _MembershipCard(member: member),
              const SizedBox(height: AppSpacing.lg),
              _InvitationsCard(
                remaining: member.invitationsRemaining,
                onTap: () => context.push(AppRoutes.invitations),
              ),
              const SizedBox(height: AppSpacing.lg),
              _MenuRow(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.username, required this.onEdit});

  final String username;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Flexible so a long username ellipsises instead of pushing the edit
        // button off the row.
        Flexible(
          child: Text(
            username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.cream,
              fontSize: 24,
            ),
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          color: AppColors.accent,
          tooltip: 'Edit username',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final bool expired = member.hasExpiredMembership;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Membership',
                  style: AppTextStyles.fieldLabel.copyWith(
                    color: AppColors.brandMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  member.membershipTier,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  expired
                      ? 'Expired ${AppDateFormat.shortDate(member.membershipExpiry)}'
                      : 'Renews ${AppDateFormat.shortDate(member.membershipExpiry)} '
                            '${member.membershipExpiry.year}',
                  style: AppTextStyles.caption.copyWith(
                    color: expired
                        ? AppColors.occupancyPacked
                        : AppColors.brandMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            expired ? Icons.error_outline_rounded : Icons.verified_rounded,
            color: expired ? AppColors.occupancyPacked : AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _InvitationsCard extends StatelessWidget {
  const _InvitationsCard({required this.remaining, required this.onTap});

  final int remaining;
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
            border: Border.all(
              color: remaining > 0
                  ? AppColors.accent.withValues(alpha: 0.45)
                  : AppColors.brandLine,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  '$remaining',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.accent,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Guest invitations',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      remaining == 0
                          ? 'None left — see where they went'
                          : '$remaining left on your membership',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brandMuted,
                      ),
                    ),
                  ],
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

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
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
              Icon(icon, size: 20, color: AppColors.brandMuted),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.cream,
                  ),
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
