import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// The member's picture, with a camera badge inviting a change.
///
/// Falls back to initials: `profileImageUrl` is nullable, and a member who has
/// never set one should get something deliberate rather than a grey blank.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 96,
    this.onTap,
    this.isBusy = false,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  /// True while a new picture is being processed or uploaded.
  final bool isBusy;

  String get _initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl;

    return Semantics(
      button: onTap != null,
      label: 'Profile picture. Tap to change.',
      child: GestureDetector(
        onTap: isBusy ? null : onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: <Widget>[
              Container(
                width: size,
                height: size,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandSurfaceHi,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
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
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? _,
                            ) => _initialsBadge(),
                      ),
              ),
              if (isBusy)
                Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(0, 0, 0, 0.55),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                ),
              if (onTap != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      // Ringed in the page background so the badge reads as
                      // sitting on top of the photo rather than inside it.
                      border: Border.all(color: AppColors.brand, width: 2),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      size: 15,
                      color: AppColors.ink,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialsBadge() => Center(
    child: Text(
      _initials,
      style: AppTextStyles.titleLarge.copyWith(
        color: AppColors.accent,
        fontSize: size * 0.34,
      ),
    ),
  );
}
