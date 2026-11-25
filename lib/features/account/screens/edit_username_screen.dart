import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/models.dart';
import '../controllers/account_controller.dart';

/// Renaming yourself.
///
/// Same rules as sign-up — 3 to 30 characters, trimmed — checked here for the
/// message and again on the server, which is the only place uniqueness can be
/// decided.
class EditUsernameScreen extends ConsumerStatefulWidget {
  const EditUsernameScreen({super.key});

  @override
  ConsumerState<EditUsernameScreen> createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends ConsumerState<EditUsernameScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  bool _isSaving = false;
  bool _initialised = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _localError(String value) {
    final String trimmed = value.trim();
    if (trimmed.length < 3 || trimmed.length > 30) {
      return 'Use between 3 and 30 characters.';
    }
    return null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final String? local = _localError(_controller.text);
    if (local != null) {
      setState(() => _error = local);
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final String? error = await ref
        .read(profileProvider.notifier)
        .updateUsername(_controller.text);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      // The optimistic name has already been rolled back by the controller;
      // this just says why.
      setState(() => _error = error);
      return;
    }

    context.pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Username updated.')));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Member> profile = ref.watch(profileProvider);

    // Seeded once, from whichever build first has the profile. Doing it on
    // every build would fight the user's typing.
    if (!_initialised && profile.hasValue) {
      _controller.text = profile.requireValue.username;
      _initialised = true;
    }

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Username'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.lg,
            AppSpacing.screenH,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            Text(
              'This is the name other members see. Your membership ID does '
              'not change.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Username',
              controller: _controller,
              hintText: 'How you want to be known',
              errorText: _error,
              enabled: !_isSaving,
              maxLength: 30,
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Save',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
