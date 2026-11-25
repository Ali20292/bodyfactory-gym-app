import '../models/models.dart';

/// Authentication and account creation.
///
/// Implementations throw a `Failure` — never a transport exception.
///
/// Two rules shape this interface:
/// * **No enumeration.** A failed log-in and a rejected membership ID both
///   surface one generic message. Nothing a caller can inspect reveals whether
///   an ID exists in the gym's records.
/// * **The app never sees the OTP.** It posts the code the user typed and gets
///   back a yes or no.
abstract class AuthRepository {
  /// Throws `AuthFailure` on bad credentials — with the same message whether
  /// the ID is unknown or the password is wrong.
  Future<AuthSession> logIn({
    required String membershipId,
    required String password,
  });

  /// Starts account creation. The backend checks the membership ID against the
  /// gym's member records and texts an OTP to the phone stored against it.
  ///
  /// Throws `ValidationFailure` for a bad username or password, and
  /// `AuthFailure` with one blurred message when the ID is unusable — whether
  /// it does not exist or is already registered.
  Future<SignUpChallenge> signUp({
    required String username,
    required String membershipId,
    required String password,
  });

  /// Completes account creation. Throws `OtpFailure` (carrying the attempts
  /// left) on a wrong code, `OtpFailure.locked` once the backend stops
  /// accepting them, and `OtpExpiredFailure` when the code has aged out.
  Future<void> verifyOtp({required String challengeId, required String code});

  /// Issues a fresh code for the same challenge. Throws `RateLimitFailure` if
  /// asked again inside the cooldown.
  Future<SignUpChallenge> resendOtp({required String challengeId});

  /// Reads any session held in secure storage. Null when there is none or it
  /// has expired. Called by the splash screen before the auth redirect runs.
  Future<AuthSession?> restoreSession();

  /// Clears the stored session. Safe to call when already logged out.
  Future<void> logOut();

  /// Emits the current session, and null after logout or expiry. The router's
  /// redirect watches this, so a token expiring mid-session bounces the user
  /// to Login instead of leaving them on a stale screen.
  Stream<AuthSession?> watchSession();
}
