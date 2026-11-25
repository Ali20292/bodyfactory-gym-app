import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_challenge.freezed.dart';
part 'sign_up_challenge.g.dart';

/// What the backend hands back after accepting a sign-up: an OTP is now in
/// flight against the phone number stored for that membership ID.
///
/// Note what is *not* here: the code itself. The app never receives it and
/// never checks it — it posts what the user typed and gets back a yes or no.
@freezed
abstract class SignUpChallenge with _$SignUpChallenge {
  const factory SignUpChallenge({
    /// Opaque handle for this attempt. Carries no membership information.
    required String challengeId,

    /// Masked by the backend, e.g. `+20 1** *** 4471`, so the user knows which
    /// phone to check without the app ever holding the real number.
    required String maskedPhone,
    required DateTime expiresAt,

    /// Wrong-code attempts left before the backend locks the challenge.
    required int attemptsRemaining,
  }) = _SignUpChallenge;

  const SignUpChallenge._();

  factory SignUpChallenge.fromJson(Map<String, dynamic> json) =>
      _$SignUpChallengeFromJson(json);

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  Duration remainingAt(DateTime now) {
    final Duration left = expiresAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }
}
