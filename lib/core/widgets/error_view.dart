import 'package:flutter/material.dart';

import '../errors/failures.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The `error` arm of an `AsyncValue.when`.
///
/// Takes a [Failure] rather than a raw error so nothing internal leaks into
/// the UI. Anything that is not a [Failure] falls back to a generic message.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  String get _message => switch (error) {
    final Failure failure => failure.message,
    _ => 'Something went wrong.',
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
