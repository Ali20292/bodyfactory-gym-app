import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// A pull-to-refresh list over an [AsyncValue], with the loading, error and
/// empty states handled once.
///
/// All three Reservations tabs are the same shape — fetch a list, show cards,
/// let the user pull to refresh — so they share this rather than each growing
/// its own slightly different version of the same four states.
class AsyncListView<T> extends StatelessWidget {
  const AsyncListView({
    super.key,
    required this.value,
    required this.onRefresh,
    required this.itemBuilder,
    required this.emptyTitle,
    required this.emptyBody,
    this.emptyIcon = Icons.inbox_rounded,
    this.header,
  });

  final AsyncValue<List<T>> value;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;

  final String emptyTitle;
  final String emptyBody;
  final IconData emptyIcon;

  /// Optional widget above the first card, inside the same scroll view.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.accent,
      backgroundColor: AppColors.brandSurface,
      child: value.when(
        // A refresh keeps the current list on screen rather than flashing back
        // to skeletons under the user's finger.
        skipLoadingOnRefresh: true,
        loading: () => const _LoadingList(),
        error: (Object error, StackTrace _) =>
            _ErrorState(error: error, onRetry: onRefresh),
        data: (List<T> items) {
          if (items.isEmpty) {
            return _EmptyState(
              title: emptyTitle,
              body: emptyBody,
              icon: emptyIcon,
              header: header,
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.xxxl,
            ),
            itemCount: items.length + (header == null ? 0 : 1),
            separatorBuilder: (BuildContext context, int _) =>
                const SizedBox(height: AppSpacing.lg),
            itemBuilder: (BuildContext context, int index) {
              if (header != null) {
                if (index == 0) return header!;
                return itemBuilder(context, items[index - 1]);
              }
              return itemBuilder(context, items[index]);
            },
          );
        },
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.xxxl,
      ),
      children: <Widget>[
        for (int i = 0; i < 4; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          Container(
            height: 132,
            decoration: BoxDecoration(
              color: AppColors.brandSurface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.brandLine),
            ),
          ),
        ],
      ],
    );
  }
}

/// Scrollable so pull-to-refresh still works from the error and empty states —
/// otherwise the one gesture that could fix things is the one unavailable.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  String get _message => switch (error) {
    final Failure failure => failure.message,
    _ => "We couldn't load that. Check your connection and try again.",
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: <Widget>[
        const SizedBox(height: AppSpacing.section),
        const Icon(
          Icons.cloud_off_rounded,
          size: 36,
          color: AppColors.brandHint,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          _message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brandMuted),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: TextButton(onPressed: onRetry, child: const Text('Try again')),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.body,
    required this.icon,
    this.header,
  });

  final String title;
  final String body;
  final IconData icon;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.xxxl,
      ),
      children: <Widget>[
        if (header != null) ...<Widget>[
          header!,
          const SizedBox(height: AppSpacing.lg),
        ],
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.section,
          ),
          decoration: BoxDecoration(
            color: AppColors.brandSurface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.brandLine),
          ),
          child: Column(
            children: <Widget>[
              Icon(icon, size: 34, color: AppColors.brandHint),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                body,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
