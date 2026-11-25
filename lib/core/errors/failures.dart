/// The only error type the UI is allowed to see.
///
/// Repositories catch transport-level exceptions (`DioException`, parse
/// errors, platform errors) and map them to a [Failure]. No widget or
/// controller ever handles a raw `DioException`.
sealed class Failure implements Exception {
  const Failure(this.message);

  /// Safe to show to the user as-is. Never contains a stack trace, a URL, or
  /// anything that reveals whether a given membership ID exists.
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// No usable connection, DNS failure, or the request timed out.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No connection. Check your internet and try again.',
  ]);
}

/// The backend answered with a 5xx, or something we cannot interpret.
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong on our side. Please try again.',
  ]);
}

/// Credentials rejected, or the session is no longer valid (401/403).
///
/// The message is intentionally generic: it must never reveal whether a
/// membership ID exists in the system.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Incorrect membership ID or password.']);
}

/// The backend rejected the input (422/400). [fieldErrors] maps a form field
/// name to its message so the UI can render it inline under that field.
class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    this.fieldErrors = const <String, String>{},
  });

  final Map<String, String> fieldErrors;
}

/// Too many attempts. [retryAfter] is present when the backend tells us when
/// the caller may try again — used by the OTP resend cooldown.
class RateLimitFailure extends Failure {
  const RateLimitFailure([
    super.message = 'Too many attempts. Please wait and try again.',
    this.retryAfter,
  ]);

  final Duration? retryAfter;
}

/// The entered OTP was wrong.
///
/// [attemptsRemaining] lets the screen tell the user how many tries are left;
/// [isLocked] means the backend has stopped accepting codes for this challenge.
class OtpFailure extends Failure {
  const OtpFailure({
    required this.attemptsRemaining,
    this.isLocked = false,
    String message = 'That code is not right.',
  }) : super(message);

  const OtpFailure.locked()
    : attemptsRemaining = 0,
      isLocked = true,
      super('Too many incorrect codes. Start again from sign up.');

  final int attemptsRemaining;
  final bool isLocked;
}

/// The OTP expired before it was used. Codes are single-use and short-lived.
class OtpExpiredFailure extends Failure {
  const OtpExpiredFailure([
    super.message = 'That code has expired. Request a new one.',
  ]);
}

/// The requested resource is gone, or was never there.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'That is no longer available.']);
}

/// A booking conflict — slot taken, class full, already reserved (409).
class ConflictFailure extends Failure {
  const ConflictFailure([
    super.message = 'That is no longer available. Please pick another option.',
  ]);
}

/// Anything we failed to classify.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}
