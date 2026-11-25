import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Stand-in body for a route that exists in the router but is not built yet.
///
/// Scaffolding only — every one of these is replaced by the real screen in its
/// own step of the build order. If any of these are still here at the end of
/// the build, something was skipped.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.buildStep,
    this.showAppBar = true,
  });

  final String title;

  /// The build-order step that replaces this screen, e.g. `'Step 8 — Home'`.
  final String buildStep;

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.construction_rounded,
                size: 40,
                color: AppColors.inkFaint,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                buildStep,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
