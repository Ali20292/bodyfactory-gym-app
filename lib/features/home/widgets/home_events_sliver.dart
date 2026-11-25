import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';
import 'event_card.dart';
import 'events_empty.dart';

/// The events & offers list, as a sliver so it stays lazy inside Home's
/// scroll view. Handles all three async states itself, since each one is a
/// different sliver and the caller should not have to care which.
class HomeEventsSliver extends StatelessWidget {
  const HomeEventsSliver({
    super.key,
    required this.events,
    required this.onRetry,
  });

  final AsyncValue<List<GymEvent>> events;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return events.when(
      skipLoadingOnRefresh: true,
      loading: () => const SliverToBoxAdapter(child: _EventsLoading()),
      error: (Object error, StackTrace _) => SliverToBoxAdapter(
        child: _EventsError(error: error, onRetry: onRetry),
      ),
      data: (List<GymEvent> list) {
        if (list.isEmpty) {
          return const SliverToBoxAdapter(child: EventsEmpty());
        }

        return SliverList.separated(
          itemCount: list.length,
          separatorBuilder: (BuildContext context, int _) =>
              const SizedBox(height: AppSpacing.lg),
          itemBuilder: (BuildContext context, int index) =>
              EventCard(event: list[index]),
        );
      },
    );
  }
}

class _EventsLoading extends StatelessWidget {
  const _EventsLoading();

  @override
  Widget build(BuildContext context) {
    // Two card-shaped blocks rather than a spinner: the list is the bulk of
    // the screen, and a bare spinner in that much space reads as broken.
    return Column(
      children: <Widget>[
        for (int i = 0; i < 2; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          Container(
            height: 210,
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

class _EventsError extends StatelessWidget {
  const _EventsError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  /// Only a [Failure] carries a message meant for a person; anything else gets
  /// the generic line rather than leaking an exception into the UI.
  String get _message => switch (error) {
    final Failure failure => failure.message,
    _ => "We couldn't load what's on.",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Column(
        children: <Widget>[
          Text(
            _message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.brandMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
