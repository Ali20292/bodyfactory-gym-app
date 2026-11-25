import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../controllers/account_controller.dart';

/// Settings, which today means the way out.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoggingOut = false;

  Future<void> _logOut() async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Log out?'),
            content: const Text(
              'You will need your membership ID and password to get back in.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Log out'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    setState(() => _isLoggingOut = true);
    // No navigation here on purpose. Clearing the session is the event; the
    // router's redirect is watching for it and takes us to Login. A `go` call
    // as well would be a second path to the same place, and the two would
    // eventually disagree.
    await ref.read(logOutProvider)();
  }

  @override
  Widget build(BuildContext context) {
    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Settings'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.lg,
            AppSpacing.screenH,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            _DangerRow(
              icon: Icons.logout_rounded,
              label: 'Log out',
              isBusy: _isLoggingOut,
              onTap: _logOut,
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text(
                'Body Factory${AppConfig.useMockData ? ' · demo data' : ''}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerRow extends StatelessWidget {
  const _DangerRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isBusy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandSurface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: AppColors.danger),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
              if (isBusy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
