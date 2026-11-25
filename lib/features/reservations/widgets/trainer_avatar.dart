import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A trainer's photo, with initials standing in when there isn't one.
///
/// The fallback is not decoration: `photoUrl` is nullable on [Trainer], and a
/// gym that has not photographed everyone yet should still get a list that
/// looks deliberate rather than one with holes in it.
class TrainerAvatar extends StatelessWidget {
  const TrainerAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 64,
    this.ring = true,
  });

  final String name;
  final String? photoUrl;
  final double size;

  /// Thin orange ring. On at list size, off on the detail header where the
  /// photo is already the largest thing on screen.
  final bool ring;

  String get _initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String? url = photoUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.brandSurfaceHi,
        border: ring
            ? Border.all(
                color: AppColors.accent.withValues(alpha: 0.55),
                width: 2,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? _initialsBadge()
          : Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? progress,
                  ) => progress == null ? child : _initialsBadge(),
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? _) =>
                      _initialsBadge(),
            ),
    );
  }

  Widget _initialsBadge() => Center(
    child: Text(
      _initials,
      style: AppTextStyles.titleMedium.copyWith(
        color: AppColors.accent,
        fontSize: size * 0.34,
      ),
    ),
  );
}
