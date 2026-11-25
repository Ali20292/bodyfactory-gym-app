import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format.dart';

/// A date and time in one control.
///
/// Two pickers in sequence rather than a combined widget, because that is what
/// Material gives us and staff are used to it. Returns the merged value.
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? errorText;

  /// Present when the field is optional, e.g. an event's end.
  final VoidCallback? onClear;

  Future<void> _pick(BuildContext context) async {
    final DateTime base = value ?? DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (date == null || !context.mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return;

    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? current = value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.fieldLabel.copyWith(color: AppColors.brandMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: AppColors.brandSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: () => _pick(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: errorText == null
                      ? AppColors.brandLine
                      : AppColors.danger,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.event_rounded,
                    size: 18,
                    color: AppColors.brandHint,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      current == null
                          ? 'Not set'
                          : '${AppDateFormat.shortDate(current)} '
                                '${current.year} · '
                                '${AppDateFormat.timeLabel(current)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: current == null
                            ? AppColors.brandHint
                            : AppColors.cream,
                      ),
                    ),
                  ),
                  if (onClear != null && current != null)
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.brandHint,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}

/// One row in a staff list: what it is, when, and a menu.
class AdminListTile extends StatelessWidget {
  const AdminListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    this.leading,
    this.onTap,
    this.actions = const <AdminAction>[],
    this.isDimmed = false,
  });

  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final Widget? leading;
  final VoidCallback? onTap;
  final List<AdminAction> actions;

  /// Past items stay in the list but recede — staff need to see them, and
  /// hiding them makes a schedule look emptier than it is.
  final bool isDimmed;

  @override
  Widget build(BuildContext context) {
    final Color color = badgeColor ?? AppColors.accent;

    return Opacity(
      opacity: isDimmed ? 0.55 : 1,
      child: Material(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.brandLine),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.cream,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (badge != null) ...<Widget>[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                badge!,
                                style: AppTextStyles.caption.copyWith(
                                  color: color,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.brandMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (actions.isNotEmpty)
                  PopupMenuButton<AdminAction>(
                    color: AppColors.brandSurfaceHi,
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.brandHint,
                      size: 20,
                    ),
                    onSelected: (AdminAction action) => action.onSelected(),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<AdminAction>>[
                          for (final AdminAction action in actions)
                            PopupMenuItem<AdminAction>(
                              value: action,
                              child: Text(
                                action.label,
                                style: TextStyle(
                                  color: action.isDestructive
                                      ? AppColors.danger
                                      : AppColors.cream,
                                ),
                              ),
                            ),
                        ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class AdminAction {
  const AdminAction({
    required this.label,
    required this.onSelected,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onSelected;
  final bool isDestructive;
}

/// The empty state for a staff list.
class AdminEmpty extends StatelessWidget {
  const AdminEmpty({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.section,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Column(
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
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
    );
  }
}
