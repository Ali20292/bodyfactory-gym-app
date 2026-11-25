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
import '../controllers/login_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/form_error_banner.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _membershipId = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    _membershipId.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    // No navigation on success: the router's redirect picks up the new
    // session and moves the user to Home on its own.
    await ref
        .read(loginControllerProvider.notifier)
        .submit(membershipId: _membershipId.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final LoginFormState state = ref.watch(loginControllerProvider);
    final LoginController controller = ref.read(
      loginControllerProvider.notifier,
    );

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Log in with the membership ID on your gym card.',
      footer: Column(
        children: <Widget>[
          const _SignUpPrompt(),
          if (AppConfig.enableDevTools) const _DemoCredentialsHint(),
        ],
      ),
      children: <Widget>[
        AppTextField(
          label: 'Membership ID',
          controller: _membershipId,
          hintText: 'GM-1001',
          errorText: state.membershipIdError,
          enabled: !state.isSubmitting,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[AutofillHints.username],
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
          textInputAction: TextInputAction.done,
          autofillHints: const <String>[AutofillHints.password],
          prefixIcon: Icons.lock_outline_rounded,
          centerLabel: true,
          onChanged: (_) => controller.onFieldChanged(),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: TextButton(
            onPressed: state.isSubmitting
                ? null
                : () => context.push(AppRoutes.forgotPassword),
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FormErrorBanner(message: state.formError),
        PrimaryButton(
          label: 'Log in',
          isLoading: state.isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt();

  @override
  Widget build(BuildContext context) {
    // A Wrap, not a Row: on a narrow screen the label and the button move to
    // separate lines instead of overflowing off the right edge.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          "Don't have an account?",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.push(AppRoutes.signUp),
          child: const Text('Sign up'),
        ),
      ],
    );
  }
}

/// Debug builds only — there is no SMS and no backend yet, so the demo
/// credentials have to come from somewhere. Never shown in a release build.
class _DemoCredentialsHint extends StatelessWidget {
  const _DemoCredentialsHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Text(
        'Demo build — ${MockData.demoMembershipId} / '
        '${MockData.demoPassword}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
