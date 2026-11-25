import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/profile_image_service.dart';

/// Camera or gallery. Null if the user backed out.
Future<PhotoOrigin?> showPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<PhotoOrigin>(
    context: context,
    backgroundColor: AppColors.brandSurface,
    builder: (BuildContext context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Profile picture',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.cream),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              // Said up front, because a photo of a person is the one thing on
              // this screen that leaves the phone.
              'Cropped to a square and shrunk before it is uploaded.',
              style: AppTextStyles.caption.copyWith(color: AppColors.brandHint),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SourceTile(
              icon: Icons.photo_library_rounded,
              label: 'Choose from photos',
              onTap: () => Navigator.of(context).pop(PhotoOrigin.gallery),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SourceTile(
              icon: Icons.photo_camera_rounded,
              label: 'Take a photo',
              onTap: () => Navigator.of(context).pop(PhotoOrigin.camera),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandSurfaceHi,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.brandLine),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: AppColors.accent),
              const SizedBox(width: AppSpacing.lg),
              // Expanded, so a larger system text scale wraps the label
              // instead of pushing it off the tile.
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.cream,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
