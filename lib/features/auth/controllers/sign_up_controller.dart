import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/repository_providers.dart';

/// How strong a password looks to the user. Advisory only — the rule that
/// actually gates submission is [PasswordRules.isValid].
enum PasswordStrength {
  none('', 0),
  weak('Weak', 0.33),
  fair('Fair', 0.66),
  strong('Strong', 1);

  const PasswordStrength(this.label, this.fill);

  final String label;
  final double fill;
}

/// Client-side password checks. Mirrored server-side, which is the copy that
/// counts — this one is only here so the user gets an answer before they
/// submit.
class PasswordRules {
  const PasswordRules._();

  static const int minLength = 8;

  static bool hasLetter(String value) => value.contains(RegExp('[A-Za-z]'));
  static bool hasNumber(String value) => value.contains(RegExp('[0-9]'));
  static bool isLongEnough(String value) => value.length >= minLength;

  static bool isValid(String value) =>
      isLongEnough(value) && hasLetter(value) && hasNumber(value);

  static PasswordStrength strengthOf(String value) {
    if (value.isEmpty) return PasswordStrength.none;
    if (!isValid(value)) return PasswordStrength.weak;

    final bool hasSymbol = value.contains(RegExp(r'[^A-Za-z0-9]'));
    final bool hasMixedCase =
        value.contains(RegExp('[a-z]')) && value.contains(RegExp('[A-Z]'));

    return value.length >= 12 && (hasSymbol || hasMixedCase)
        ? PasswordStrength.strong
        : PasswordStrength.fair;
  }
}

@immutable
class SignUpFormState {
  const SignUpFormState({
    this.usernameError,
    this.membershipIdError,
    this.passwordError,
    this.confirmError,
    this.formError,
    this.isSubmitting = false,
    this.strength = PasswordStrength.none,
  });

  final String? usernameError;
  final String? membershipIdError;
  final String? passwordError;
  final String? confirmError;

  /// Whole-form failure, e.g. the membership ID being unusable.
  final String? formError;

  final bool isSubmitting;
  final PasswordStrength strength;

  bool get hasFieldErrors =>
      usernameError != null ||
      membershipIdError != null ||
      passwordError != null ||
      confirmError != null;

  SignUpFormState copyWith({bool? isSubmitting, PasswordStrength? strength}) =>
      SignUpFormState(
        isSubmitting: isSubmitting ?? this.isSubmitting,
        strength: strength ?? this.strength,
      );
}

class SignUpController extends AutoDisposeNotifier<SignUpFormState> {
  @override
  SignUpFormState build() => const SignUpFormState();

  /// Recomputes the strength meter and clears stale errors as the user edits.
  void onPasswordChanged(String password) {
    state = SignUpFormState(strength: PasswordRules.strengthOf(password));
  }

  void onFieldChanged() {
    if (!state.hasFieldErrors && state.formError == null) return;
    state = SignUpFormState(strength: state.strength);
  }

  /// Returns the challenge on success, null on failure. Navigation is the
  /// caller's job — this only owns form state.
  Future<SignUpChallenge?> submit({
    required String username,
    required String membershipId,
    required String password,
    required String confirmPassword,
  }) async {
    final String trimmedUsername = username.trim();
    final String trimmedId = membershipId.trim();

    // Client-side validation for UX only. The backend validates again and its
    // answer is the one that counts.
    final String? usernameError = _validateUsername(username, trimmedUsername);
    final String? idError = trimmedId.isEmpty
        ? 'Enter your membership ID.'
        : null;
    final String? passwordError = _validatePassword(password);
    final String? confirmError = password != confirmPassword
        ? 'Both passwords must match.'
        : null;

    if (usernameError != null ||
        idError != null ||
        passwordError != null ||
        confirmError != null) {
      state = SignUpFormState(
        usernameError: usernameError,
        membershipIdError: idError,
        passwordError: passwordError,
        confirmError: confirmError,
        strength: PasswordRules.strengthOf(password),
      );
      return null;
    }

    state = SignUpFormState(
      isSubmitting: true,
      strength: PasswordRules.strengthOf(password),
    );

    try {
      final AuthRepository repository = ref.read(authRepositoryProvider);
      return await repository.signUp(
        username: trimmedUsername,
        membershipId: trimmedId,
        password: password,
      );
    } on ValidationFailure catch (failure) {
      state = SignUpFormState(
        usernameError: failure.fieldErrors['username'],
        membershipIdError: failure.fieldErrors['membershipId'],
        passwordError: failure.fieldErrors['password'],
        formError: failure.fieldErrors.isEmpty ? failure.message : null,
        strength: PasswordRules.strengthOf(password),
      );
      return null;
    } on Failure catch (failure) {
      // The membership ID rejection lands here. Deliberately shown as a
      // whole-form message rather than under the ID field: pinning it there
      // would confirm the ID is the thing that is wrong, which is exactly
      // what must not be revealed.
      state = SignUpFormState(
        formError: failure.message,
        strength: PasswordRules.strengthOf(password),
      );
      return null;
    } catch (_) {
      state = SignUpFormState(
        formError: 'Something went wrong. Please try again.',
        strength: PasswordRules.strengthOf(password),
      );
      return null;
    }
  }

  String? _validateUsername(String raw, String trimmed) {
    if (trimmed.isEmpty) return 'Choose a username.';
    if (raw != trimmed) return 'Remove the spaces at the start or end.';
    if (trimmed.length < 3) return 'Use at least 3 characters.';
    if (trimmed.length > 30) return 'Use at most 30 characters.';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Choose a password.';
    if (!PasswordRules.isLongEnough(password)) {
      return 'Use at least ${PasswordRules.minLength} characters.';
    }
    if (!PasswordRules.hasLetter(password) ||
        !PasswordRules.hasNumber(password)) {
      return 'Include at least one letter and one number.';
    }
    return null;
  }
}

final AutoDisposeNotifierProvider<SignUpController, SignUpFormState>
signUpControllerProvider =
    NotifierProvider.autoDispose<SignUpController, SignUpFormState>(
      SignUpController.new,
    );
