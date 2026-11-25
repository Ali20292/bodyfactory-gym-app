import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/sign_up_controller.dart';

/// Advisory strength hint under the password field.
///
/// Deliberately not a gate: what blocks submission is the explicit rule
/// (8+ characters, a letter and a number), shown as its own checklist. A bar
/// alone leaves people guessing at what "weak" means.
class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({
    super.key,
    required this.strength,
    required this.password,
  });

  final PasswordStrength strength;
  final String password;

  Color get _color => switch (strength) {
    PasswordStrength.none => Colors.transparent,
    PasswordStrength.weak => AppColors.danger,
    PasswordStrength.fair => AppColors.warning,
    PasswordStrength.strong => AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (strength == PasswordStrength.none) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: strength.fill),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    builder: (BuildContext context, double value, Widget? _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 4,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(_color),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                strength.label,
                style: theme.textTheme.labelSmall?.copyWith(color: _color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _Requirement(
            met: PasswordRules.isLongEnough(password),
            label: 'At least ${PasswordRules.minLength} characters',
          ),
          _Requirement(
            met:
                PasswordRules.hasLetter(password) &&
                PasswordRules.hasNumber(password),
            label: 'A letter and a number',
          ),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          Icon(
            met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 15,
            color: met ? AppColors.success : Colors.white38,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Semantics carries the state too — colour and icon alone are not
          // enough for a screen reader.
          Semantics(
            label: met ? '$label, met' : '$label, not met',
            excludeSemantics: true,
            child: Text(label, style: theme.textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}
