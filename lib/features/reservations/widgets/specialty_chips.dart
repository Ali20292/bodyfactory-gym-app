import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// What a trainer specialises in, as a wrap of small pills.
///
/// A [Wrap] rather than a [Row]: three specialties fit on a wide phone and not
/// on a narrow one, and a trainer should not be the reason a card overflows.
class SpecialtyChips extends StatelessWidget {
  const SpecialtyChips({
    super.key,
    required this.specialties,
    this.maxToShow,
    this.compact = true,
  });

  final List<String> specialties;

  /// Caps the list and adds a "+2" pill for the rest. Null shows all of them.
  final int? maxToShow;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (specialties.isEmpty) return const SizedBox.shrink();

    final int limit = maxToShow ?? specialties.length;
    final List<String> shown = specialties.take(limit).toList();
    final int hidden = specialties.length - shown.length;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final String specialty in shown)
          _Chip(label: specialty, compact: compact),
        if (hidden > 0) _Chip(label: '+$hidden', compact: compact, muted: true),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.compact, this.muted = false});

  final String label;
  final bool compact;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final Color color = muted ? AppColors.brandMuted : AppColors.accent;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm + 2 : AppSpacing.md,
        vertical: compact ? AppSpacing.xxs + 1 : AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: compact ? 11.5 : 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
