import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/models.dart';

/// One event or offer in the Home list.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final GymEvent event;

  /// Events say when they start. Offers say when they run out — a start date
  /// on a discount that is already live tells you nothing useful.
  String get _whenLabel {
    if (event.isOffer) {
      final DateTime? endsAt = event.endsAt;
      return endsAt == null
          ? 'Available now'
          : 'Until ${AppDateFormat.shortDate(endsAt)}';
    }
    return '${AppDateFormat.dayLabel(event.startsAt)} · '
        '${AppDateFormat.timeLabel(event.startsAt)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _EventImage(imageUrl: event.imageUrl, isOffer: event.isOffer),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _TypeBadge(isOffer: event.isOffer),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _whenLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.brandMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  event.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  event.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.brandMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The card's picture, with the two things that go wrong on a phone handled:
/// no `imageUrl` at all, and a URL that fails to load. Both land on the same
/// placeholder, so a card is never a broken box.
class _EventImage extends StatelessWidget {
  const _EventImage({required this.imageUrl, required this.isOffer});

  final String? imageUrl;
  final bool isOffer;

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: url == null
          ? _placeholder()
          : Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? progress,
                  ) => progress == null ? child : _placeholder(),
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? _) =>
                      _placeholder(),
            ),
    );
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.brandSurfaceHi,
            (isOffer ? AppColors.accent : AppColors.brandLine).withValues(
              alpha: 0.22,
            ),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          isOffer ? Icons.local_offer_rounded : Icons.fitness_center_rounded,
          color: AppColors.brandHint,
          size: 30,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isOffer});

  final bool isOffer;

  @override
  Widget build(BuildContext context) {
    // Offers are orange, events are cream: two categories, two colours, and
    // the accent is spent on the one that is selling you something.
    final Color color = isOffer ? AppColors.accent : AppColors.cream;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isOffer ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        isOffer ? 'Offer' : 'Event',
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
