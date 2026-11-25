import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/models.dart';
import '../controllers/otp_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/form_error_banner.dart';
import '../widgets/otp_input.dart';

/// Phone verification, the last step of sign-up.
///
/// On success the account exists and the user is sent back to Login to sign
/// in — verifying a phone does not by itself hand out a session.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.challenge});

  final SignUpChallenge challenge;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final GlobalKey<OtpInputState> _inputKey = GlobalKey<OtpInputState>();

  Future<void> _verify(String code) async {
    final bool ok = await ref
        .read(otpControllerProvider(widget.challenge).notifier)
        .verify(code);

    if (!mounted) return;

    if (!ok) {
      // Clear the boxes on a wrong code so the next attempt starts clean.
      _inputKey.currentState?.clear();
      return;
    }

    await _showSuccessAndReturnToLogin();
  }

  Future<void> _showSuccessAndReturnToLogin() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const _SuccessDialog(),
    );
    if (!mounted) return;

    // Back to Login, clearing the sign-up screens behind us.
    context.go(AppRoutes.login);
  }

  /// The spec allows leaving at any point, but warns first if a code is still
  /// in flight — otherwise it is easy to lose a code that has already been
  /// sent and then hit the resend cooldown.
  Future<bool> _confirmLeave() async {
    final OtpState state = ref.read(otpControllerProvider(widget.challenge));
    if (state.isVerified || state.isLocked) return true;

    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Leave verification?'),
        content: const Text(
          'Your code will expire and you will need to start again.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final OtpState state = ref.watch(otpControllerProvider(widget.challenge));
    final OtpController controller = ref.read(
      otpControllerProvider(widget.challenge).notifier,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) async {
        if (didPop) return;
        final bool leave = await _confirmLeave();
        // `mounted` on the State, then the State's own context.
        if (leave && mounted) {
          this.context.pop();
        }
      },
      child: AuthScaffold(
        title: 'Verify your number',
        subtitle:
            'We sent a ${AppConfig.otpLength}-digit code to '
            '${state.challenge.maskedPhone}.',
        // Unlike Sign Up, this one keeps its app-bar arrow: the spec requires
        // a way out at any point during verification.
        showBackButton: true,
        onBack: () async {
          final bool leave = await _confirmLeave();
          if (leave && mounted) {
            this.context.pop();
          }
        },
        children: <Widget>[
          OtpInput(
            key: _inputKey,
            length: AppConfig.otpLength,
            enabled: state.canSubmit,
            hasError: state.errorMessage != null,
            // Only dismiss the error once the user types a fresh digit.
            // Clearing the boxes after a rejected code also fires this, and
            // wiping the message then would erase the attempts-remaining
            // warning before it could be read.
            onChanged: (String value) {
              if (value.isNotEmpty) controller.clearError();
            },
            onCompleted: _verify,
          ),
          const SizedBox(height: AppSpacing.xl),
          FormErrorBanner(message: state.errorMessage),
          if (state.isLocked)
            PrimaryButton(
              label: 'Start again',
              onPressed: () => context.go(AppRoutes.signUp),
            )
          else
            _ResendRow(state: state, onResend: controller.resend),
          if (state.isVerifying) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.state, required this.onResend});

  final OtpState state;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (state.isResending) {
      return Center(
        child: Text('Sending a new code…', style: theme.textTheme.bodyMedium),
      );
    }

    if (state.canResend) {
      return Center(
        child: TextButton(
          onPressed: onResend,
          child: const Text('Resend code'),
        ),
      );
    }

    return Center(
      child: Text(
        'You can request a new code in ${state.resendIn}s',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 44,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Account created', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Log in with your membership ID and password.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Go to log in'),
        ),
      ],
    );
  }
}
