import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Whole-form failure message.
///
/// Rendered inline above the submit button rather than in a snackbar: it must
/// stay on screen while the user fixes the problem, and it needs to be
/// reachable by a screen reader in reading order.
class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final String? text = message;
    if (text == null) return const SizedBox.shrink();

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: AppColors.danger,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
