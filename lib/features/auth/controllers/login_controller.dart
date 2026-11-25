import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/repository_providers.dart';

/// Form state for the Login screen. Holds only messages and flags — never the
/// password, which lives in its `TextEditingController` and goes nowhere else.
@immutable
class LoginFormState {
  const LoginFormState({
    this.membershipIdError,
    this.passwordError,
    this.formError,
    this.isSubmitting = false,
  });

  /// Rendered under the membership ID field.
  final String? membershipIdError;

  /// Rendered under the password field.
  final String? passwordError;

  /// Whole-form failure, e.g. rejected credentials or no connection. Shown
  /// above the button, never as a snackbar.
  final String? formError;

  final bool isSubmitting;

  LoginFormState copyWith({
    String? membershipIdError,
    String? passwordError,
    String? formError,
    bool? isSubmitting,
  }) => LoginFormState(
    membershipIdError: membershipIdError,
    passwordError: passwordError,
    formError: formError,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}

class LoginController extends AutoDisposeNotifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  /// Clears the whole-form error as soon as the user starts fixing things, so
  /// a stale "incorrect" message does not sit under a field they just edited.
  void onFieldChanged() {
    if (state.formError == null &&
        state.membershipIdError == null &&
        state.passwordError == null) {
      return;
    }
    state = LoginFormState(isSubmitting: state.isSubmitting);
  }

  /// Returns true when the session was created. Navigation is *not* done here
  /// — the router's redirect reacts to the new session on its own.
  Future<bool> submit({
    required String membershipId,
    required String password,
  }) async {
    final String id = membershipId.trim();

    // Client-side validation for UX only. The backend validates again, and
    // its answer is the one that counts.
    final String? idError = id.isEmpty ? 'Enter your membership ID.' : null;
    final String? passwordError = password.isEmpty
        ? 'Enter your password.'
        : null;

    if (idError != null || passwordError != null) {
      state = LoginFormState(
        membershipIdError: idError,
        passwordError: passwordError,
      );
      return false;
    }

    state = const LoginFormState(isSubmitting: true);

    try {
      final AuthRepository repository = ref.read(authRepositoryProvider);
      await repository.logIn(membershipId: id, password: password);
      return true;
    } on Failure catch (failure) {
      // Deliberately the repository's own message. It says nothing about
      // whether that membership ID exists.
      state = LoginFormState(formError: failure.message);
      return false;
    } catch (_) {
      state = const LoginFormState(
        formError: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}

final AutoDisposeNotifierProvider<LoginController, LoginFormState>
loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, LoginFormState>(
      LoginController.new,
    );
