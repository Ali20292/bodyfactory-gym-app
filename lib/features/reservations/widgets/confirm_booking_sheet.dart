import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// One line of the confirmation sheet: an icon and a fact.
@immutable
class BookingDetail {
  const BookingDetail(this.icon, this.text);

  final IconData icon;
  final String text;
}

/// The last step before a booking is written.
///
/// Shared by the trainer and class flows so the two never drift into feeling
/// like different products. Returns true only if the user confirmed — the
/// caller does the writing, because this sheet knows nothing about
/// repositories.
Future<bool> showBookingConfirmSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<BookingDetail> details,
  String confirmLabel = 'Confirm booking',
  String? note,
}) async {
  final bool? confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.brandSurface,
    builder: (BuildContext context) => _ConfirmSheet(
      title: title,
      subtitle: subtitle,
      details: details,
      confirmLabel: confirmLabel,
      note: note,
    ),
  );

  return confirmed ?? false;
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.title,
    required this.subtitle,
    required this.details,
    required this.confirmLabel,
    this.note,
  });

  final String title;
  final String subtitle;
  final List<BookingDetail> details;
  final String confirmLabel;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              subtitle,
              style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.cream),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final BookingDetail detail in details) ...<Widget>[
              Row(
                children: <Widget>[
                  Icon(detail.icon, size: 18, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      detail.text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (note != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                note!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandHint,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Not now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
