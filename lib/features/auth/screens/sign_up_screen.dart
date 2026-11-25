import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/models.dart';
import '../controllers/sign_up_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/form_error_banner.dart';
import '../widgets/password_strength_bar.dart';

/// Account creation.
///
/// The point of this flow is that only real gym members can create an
/// account: the membership ID must already exist in the gym's records, and
/// the OTP proves the person holds the phone attached to it.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _membershipId = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  final FocusNode _membershipIdFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  @override
  void dispose() {
    _username.dispose();
    _membershipId.dispose();
    _password.dispose();
    _confirm.dispose();
    _membershipIdFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final SignUpChallenge? challenge = await ref
        .read(signUpControllerProvider.notifier)
        .submit(
          username: _username.text,
          membershipId: _membershipId.text,
          password: _password.text,
          confirmPassword: _confirm.text,
        );

    if (challenge == null || !mounted) return;

    // The challenge travels as `extra`: it is meaningful only for this
    // in-flight attempt and has no business in a restorable URL.
    await context.push(AppRoutes.otp, extra: challenge);
  }

  @override
  Widget build(BuildContext context) {
    final SignUpFormState state = ref.watch(signUpControllerProvider);
    final SignUpController controller = ref.read(
      signUpControllerProvider.notifier,
    );

    return AuthScaffold(
      title: 'Create your account',
      subtitle:
          'Your membership ID is on your gym card. We will text a code to '
          'the number the gym has on file.',
      // Same frame as Login: no app bar, centred, same backdrop, footer
      // pinned to the bottom. Getting back is the "Log in" link in that
      // footer, plus the system back gesture, which go_router still handles.
      footer: Column(
        children: <Widget>[
          const _LoginPrompt(),
          if (AppConfig.enableDevTools) const _DemoSignUpHint(),
        ],
      ),
      children: <Widget>[
        AppTextField(
          label: 'Username',
          controller: _username,
          hintText: 'How you want to be known',
          errorText: state.usernameError,
          enabled: !state.isSubmitting,
          textInputAction: TextInputAction.next,
          maxLength: 30,
          prefixIcon: Icons.person_outline_rounded,
          centerLabel: true,
          onChanged: (_) => controller.onFieldChanged(),
          onSubmitted: (_) => _membershipIdFocus.requestFocus(),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: 'Membership ID',
          controller: _membershipId,
          focusNode: _membershipIdFocus,
          hintText: 'GM-2044',
          errorText: state.membershipIdError,
          enabled: !state.isSubmitting,
          textInputAction: TextInputAction.next,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ],
          prefixIcon: Icons.badge_outlined,
          centerLabel: true,
          onChanged: (_) => controller.onFieldChanged(),
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: 'Password',
          controller: _password,
          focusNode: _passwordFocus,
          obscureText: true,
          errorText: state.passwordError,
          enabled: !state.isSubmitting,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.lock_outline_rounded,
          centerLabel: true,
          onChanged: controller.onPasswordChanged,
          onSubmitted: (_) => _confirmFocus.requestFocus(),
        ),
        PasswordStrengthBar(strength: state.strength, password: _password.text),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: 'Confirm password',
          controller: _confirm,
          focusNode: _confirmFocus,
          obscureText: true,
          errorText: state.confirmError,
          enabled: !state.isSubmitting,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.lock_outline_rounded,
          centerLabel: true,
          onChanged: (_) => controller.onFieldChanged(),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.xl),
        FormErrorBanner(message: state.formError),
        PrimaryButton(
          label: 'Send code',
          isLoading: state.isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          'Already have an account?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(onPressed: () => context.pop(), child: const Text('Log in')),
      ],
    );
  }
}

/// Debug builds only — without a backend there is no way to know which IDs
/// the gym would accept.
class _DemoSignUpHint extends StatelessWidget {
  const _DemoSignUpHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Text(
        'Demo build — try ${MockData.signUpReadyMembershipId}, '
        'code ${MockData.demoOtpCode}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
