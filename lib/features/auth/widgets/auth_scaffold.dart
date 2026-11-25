import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/body_factory_mark.dart';
import 'auth_background.dart';

/// Widest the form is allowed to get. Beyond this the fields start looking
/// like a desktop form on a tablet.
const double _maxFormWidth = 440;

/// Shared frame for the auth screens.
///
/// Always black-and-orange, whatever the OS theme is: these screens are the
/// brand's front door and should follow the splash, not the phone. Everything
/// is centred, and the only orange text is a link.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showBackButton = false,
    this.onBack,
    this.footer,
    this.backgroundImage = AuthBackground.defaultImage,
    this.showLogo = true,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showBackButton;
  final VoidCallback? onBack;

  /// Lets each auth screen pick its own backdrop.
  final String backgroundImage;

  /// Shows the Body Factory mark above the heading.
  final bool showLogo;

  /// Pinned to the bottom of the screen when there is room, rather than
  /// floating just under the form.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    // Applied here as well as at the app root, so these screens keep their
    // look even if they are ever shown from somewhere with a different theme.
    return Theme(
      data: AppTheme.brand,
      child: Builder(
        builder: (BuildContext context) {
          final ThemeData theme = Theme.of(context);

          return AuthBackground(
            imageAsset: backgroundImage,
            child: Scaffold(
              // Transparent so the photographic backdrop shows through; the
              // Stack below paints the background instead.
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              appBar: showBackButton
                  ? AppBar(
                      leading: BackButton(onPressed: onBack),
                      backgroundColor: Colors.transparent,
                    )
                  : null,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      // Tight at the top so the lockup sits high on the
                      // screen, roomier at the bottom where the footer lives.
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        AppSpacing.sm,
                        AppSpacing.screenH,
                        AppSpacing.xxl,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          // Caps the form's width so the fields do not stretch
                          // across a tablet, and centres it when there is room
                          // to spare. Fills the screen vertically when there is
                          // room, scrolls when the keyboard takes it away.
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - AppSpacing.xxl,
                            maxWidth: _maxFormWidth,
                          ),
                          child: _maybeIntrinsic(
                            // `Expanded` needs a bounded height, which a scroll
                            // view does not give. IntrinsicHeight supplies one —
                            // but it is not free, so it is only used when there
                            // is a footer to push down.
                            enabled: footer != null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                if (showLogo) ...<Widget>[
                                  // Bare mark, no tile: the backdrop is
                                  // already dark, so a black container behind
                                  // it would only add a visible edge.
                                  const Center(
                                    child: BodyFactoryMark(size: 76),
                                  ),
                                  // The gap between the mark and the heading,
                                  // kept as-is while everything above it
                                  // moved up.
                                  const SizedBox(height: AppSpacing.section),
                                ] else
                                  const SizedBox(height: AppSpacing.lg),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.section),
                                ...children,
                                if (footer != null) ...<Widget>[
                                  const Expanded(
                                    child: SizedBox(height: AppSpacing.xl),
                                  ),
                                  footer!,
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Wraps [child] in an [IntrinsicHeight] only when [enabled].
Widget _maybeIntrinsic({required bool enabled, required Widget child}) =>
    enabled ? IntrinsicHeight(child: child) : child;
