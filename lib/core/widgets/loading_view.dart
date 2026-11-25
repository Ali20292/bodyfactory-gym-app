import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// The `loading` arm of an `AsyncValue.when`.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
