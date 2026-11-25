import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/repository_providers.dart';

@immutable
class OtpState {
  const OtpState({
    required this.challenge,
    required this.resendIn,
    this.errorMessage,
    this.attemptsRemaining,
    this.isVerifying = false,
    this.isResending = false,
    this.isLocked = false,
    this.isVerified = false,
  });

  final SignUpChallenge challenge;

  /// Seconds until "Resend code" becomes tappable. Zero means it is available.
  final int resendIn;

  final String? errorMessage;

  /// Null until the backend has told us — the app never counts attempts
  /// itself, because only the server's count is authoritative.
  final int? attemptsRemaining;

  final bool isVerifying;
  final bool isResending;

  /// The backend has stopped accepting codes for this challenge.
  final bool isLocked;

  /// Account created.
  final bool isVerified;

  bool get canResend => resendIn == 0 && !isResending && !isLocked;
  bool get canSubmit => !isVerifying && !isLocked && !isVerified;

  OtpState copyWith({
    SignUpChallenge? challenge,
    int? resendIn,
    String? errorMessage,
    int? attemptsRemaining,
    bool? isVerifying,
    bool? isResending,
    bool? isLocked,
    bool? isVerified,
    bool clearError = false,
  }) => OtpState(
    challenge: challenge ?? this.challenge,
    resendIn: resendIn ?? this.resendIn,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
    isVerifying: isVerifying ?? this.isVerifying,
    isResending: isResending ?? this.isResending,
    isLocked: isLocked ?? this.isLocked,
    isVerified: isVerified ?? this.isVerified,
  );
}

/// Drives the OTP screen: the resend countdown, verification, and lockout.
///
/// The code itself is never checked here. It is posted and the backend
/// answers yes or no — the app has no way to know what the right code is.
class OtpController
    extends AutoDisposeFamilyNotifier<OtpState, SignUpChallenge> {
  Timer? _ticker;

  @override
  OtpState build(SignUpChallenge arg) {
    ref.onDispose(() => _ticker?.cancel());
    _startCountdown();
    return OtpState(
      challenge: arg,
      resendIn: AppConfig.otpResendCooldown.inSeconds,
      attemptsRemaining: arg.attemptsRemaining,
    );
  }

  void _startCountdown() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final int next = state.resendIn - 1;
      if (next <= 0) {
        timer.cancel();
        state = state.copyWith(resendIn: 0);
        return;
      }
      state = state.copyWith(resendIn: next);
    });
  }

  /// True once the account exists. The caller then returns to Login.
  Future<bool> verify(String code) async {
    if (!state.canSubmit) return false;

    state = state.copyWith(isVerifying: true, clearError: true);

    try {
      final AuthRepository repository = ref.read(authRepositoryProvider);
      await repository.verifyOtp(
        challengeId: state.challenge.challengeId,
        code: code,
      );
      state = state.copyWith(isVerifying: false, isVerified: true);
      return true;
    } on OtpFailure catch (failure) {
      state = state.copyWith(
        isVerifying: false,
        isLocked: failure.isLocked,
        attemptsRemaining: failure.attemptsRemaining,
        errorMessage: failure.isLocked
            ? failure.message
            : '${failure.message} '
                  '${failure.attemptsRemaining} '
                  '${failure.attemptsRemaining == 1 ? "try" : "tries"} left.',
      );
      return false;
    } on Failure catch (failure) {
      state = state.copyWith(isVerifying: false, errorMessage: failure.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<void> resend() async {
    if (!state.canResend) return;

    state = state.copyWith(isResending: true, clearError: true);

    try {
      final AuthRepository repository = ref.read(authRepositoryProvider);
      final SignUpChallenge next = await repository.resendOtp(
        challengeId: state.challenge.challengeId,
      );
      state = state.copyWith(
        challenge: next,
        isResending: false,
        attemptsRemaining: next.attemptsRemaining,
        resendIn: AppConfig.otpResendCooldown.inSeconds,
      );
      _startCountdown();
    } on RateLimitFailure catch (failure) {
      // The server is the authority on the cooldown; adopt its number rather
      // than trusting the local timer.
      state = state.copyWith(
        isResending: false,
        resendIn: failure.retryAfter?.inSeconds ?? state.resendIn,
        errorMessage: failure.message,
      );
      _startCountdown();
    } on Failure catch (failure) {
      state = state.copyWith(isResending: false, errorMessage: failure.message);
    }
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }
}

final AutoDisposeNotifierProviderFamily<
  OtpController,
  OtpState,
  SignUpChallenge
>
otpControllerProvider = NotifierProvider.autoDispose
    .family<OtpController, OtpState, SignUpChallenge>(OtpController.new);
