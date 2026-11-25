import 'package:freezed_annotation/freezed_annotation.dart';

import 'member.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// A logged-in session.
///
/// The tokens in here are the most sensitive values the app holds. They live in
/// `flutter_secure_storage` only — never `shared_preferences`, never in any
/// state that gets serialised for debugging, and never in a log line. The
/// [toString] override exists so an accidental `print(session)` cannot leak
/// them.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    required Member member,
  }) = _AuthSession;

  const AuthSession._();

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);

  bool get isExpired => !DateTime.now().isBefore(expiresAt);

  /// True when the access token is close enough to expiry that the next
  /// request should refresh first. Keeps the user from hitting a 401 mid-tap.
  bool get needsRefresh =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 2)));

  @override
  String toString() =>
      'AuthSession(member: ${member.id}, expiresAt: $expiresAt, '
      'tokens: <redacted>)';
}
