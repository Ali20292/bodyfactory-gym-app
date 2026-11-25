import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Full-width call to action.
///
/// While [isLoading] the button is disabled and shows a spinner *inside*
/// itself, so the layout never jumps and the action cannot be double-fired.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    return FilledButton(
      onPressed: isEnabled ? onPressed : null,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onBrand),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(label),
              ],
            ),
    );
  }
}
