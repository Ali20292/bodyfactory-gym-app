import 'dart:async';

import '../../core/config/app_config.dart';
import '../../core/errors/failures.dart';
import '../../core/storage/session_store.dart';
import '../mock/mock_data.dart';
import '../mock/mock_store.dart';
import '../models/models.dart';
import 'auth_repository.dart';

/// In-memory auth. Accepts [MockData.demoMembershipId] /
/// [MockData.demoPassword], and [MockData.demoOtpCode] for the OTP.
///
/// It reproduces the *observable* behaviour of the real thing, including the
/// parts that exist for security: one blurred message for every sign-up
/// rejection, no way to tell a wrong password from an unknown ID, a five-try
/// lockout, and a resend cooldown. Getting those wrong here would mean
/// building screens against the wrong shape.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    SessionStore? store,
    MockStore? data,
    DateTime Function()? clock,
  }) : _store = store ?? InMemorySessionStore(),
       _data = data ?? MockStore(),
       _now = clock ?? DateTime.now;

  /// Where the signed-in member is recorded, so the account repository can
  /// serve the right profile. Stands in for the backend reading the token.
  final MockStore _data;

  static const int _maxOtpAttempts = 5;
  static const Duration _otpLifetime = Duration(minutes: 5);

  final SessionStore _store;
  final DateTime Function() _now;
  final StreamController<AuthSession?> _sessions =
      StreamController<AuthSession?>.broadcast();

  final Map<String, _PendingSignUp> _pending = <String, _PendingSignUp>{};
  int _challengeCounter = 0;

  @override
  Stream<AuthSession?> watchSession() => _sessions.stream;

  @override
  Future<AuthSession> logIn({
    required String membershipId,
    required String password,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final String id = membershipId.trim();

    // The role comes off the account on the server, never off anything the
    // client sent. Two demo accounts: one member, one staff.
    final Member? member = switch (id) {
      MockData.demoMembershipId when password == MockData.demoPassword =>
        MockData.member(),
      MockData.demoStaffMembershipId
          when password == MockData.demoStaffPassword =>
        MockData.staffMember(),
      _ => null,
    };

    // One message for both failure modes. Distinguishing them would tell an
    // attacker which membership IDs are real.
    if (member == null) throw const AuthFailure();

    final AuthSession session = _sessionFor(member);
    await _store.write(session);
    _sessions.add(session);
    return session;
  }

  @override
  Future<SignUpChallenge> signUp({
    required String username,
    required String membershipId,
    required String password,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    // Client-side validation already ran; this is the server-side pass that
    // actually counts. Client validation is never trusted.
    final Map<String, String> fieldErrors = <String, String>{};
    final String trimmedUsername = username.trim();
    if (trimmedUsername.length < 3 || trimmedUsername.length > 30) {
      fieldErrors['username'] = 'Use between 3 and 30 characters.';
    }
    if (password.length < 8 ||
        !password.contains(RegExp('[A-Za-z]')) ||
        !password.contains(RegExp('[0-9]'))) {
      fieldErrors['password'] =
          'Use at least 8 characters, with a letter and a number.';
    }
    if (fieldErrors.isNotEmpty) {
      throw ValidationFailure(
        'Please check the details entered.',
        fieldErrors: fieldErrors,
      );
    }

    final String id = membershipId.trim();
    final bool usable =
        MockData.knownMembershipIds.contains(id) &&
        !MockData.alreadyRegisteredIds.contains(id);

    // "Not a member" and "already has an account" are deliberately the same
    // message. The backend knows the difference; the user does not.
    if (!usable) {
      throw const AuthFailure(
        "We couldn't set up an account with that membership ID. "
        'Please check with the front desk.',
      );
    }

    return _issueChallenge(membershipId: id, username: trimmedUsername);
  }

  @override
  Future<void> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final _PendingSignUp? pending = _pending[challengeId];
    if (pending == null) throw const OtpExpiredFailure();

    if (pending.isLocked) throw const OtpFailure.locked();

    if (pending.challenge.isExpiredAt(_now())) {
      _pending.remove(challengeId);
      throw const OtpExpiredFailure();
    }

    if (code != MockData.demoOtpCode) {
      pending.attemptsUsed++;
      final int left = _maxOtpAttempts - pending.attemptsUsed;
      if (left <= 0) {
        pending.isLocked = true;
        throw const OtpFailure.locked();
      }
      pending.challenge = pending.challenge.copyWith(attemptsRemaining: left);
      throw OtpFailure(attemptsRemaining: left);
    }

    // Account created. The user is sent back to Login to sign in — verifying
    // the phone does not by itself hand out a session.
    _pending.remove(challengeId);
  }

  @override
  Future<SignUpChallenge> resendOtp({required String challengeId}) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final _PendingSignUp? pending = _pending[challengeId];
    if (pending == null) throw const OtpExpiredFailure();
    if (pending.isLocked) throw const OtpFailure.locked();

    final Duration sinceLast = _now().difference(pending.lastSentAt);
    if (sinceLast < AppConfig.otpResendCooldown) {
      throw RateLimitFailure(
        'Please wait before requesting another code.',
        AppConfig.otpResendCooldown - sinceLast,
      );
    }

    _pending.remove(challengeId);
    return _issueChallenge(
      membershipId: pending.membershipId,
      username: pending.username,
    );
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final AuthSession? stored = await _store.read();
    if (stored == null) return null;

    if (stored.isExpired) {
      await _store.clear();
      _sessions.add(null);
      return null;
    }

    // A restored session is a signed-in session, so the same fact has to be
    // recorded as at log-in — otherwise a relaunch serves the wrong profile.
    _data.signedInMember = stored.member;
    _sessions.add(stored);
    return stored;
  }

  @override
  Future<void> logOut() async {
    await _store.clear();
    _sessions.add(null);
  }

  SignUpChallenge _issueChallenge({
    required String membershipId,
    required String username,
  }) {
    final DateTime now = _now();
    final SignUpChallenge challenge = SignUpChallenge(
      challengeId: 'chg-${_challengeCounter++}',
      maskedPhone: MockData.demoMaskedPhone,
      expiresAt: now.add(_otpLifetime),
      attemptsRemaining: _maxOtpAttempts,
    );

    _pending[challenge.challengeId] = _PendingSignUp(
      membershipId: membershipId,
      username: username,
      challenge: challenge,
      lastSentAt: now,
    );

    return challenge;
  }

  AuthSession _sessionFor(Member member) {
    // Recorded here, where the session is minted, so every path that produces
    // one — log in now, restore later — leaves the same fact behind.
    _data.signedInMember = member;

    return AuthSession(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      expiresAt: _now().add(const Duration(hours: 8)),
      member: member,
    );
  }

  /// Releases the session stream. Wired to the provider's `onDispose`.
  void dispose() => _sessions.close();
}

/// A sign-up waiting on its OTP. Never leaves the repository.
class _PendingSignUp {
  _PendingSignUp({
    required this.membershipId,
    required this.username,
    required this.challenge,
    required this.lastSentAt,
  });

  final String membershipId;
  final String username;
  SignUpChallenge challenge;
  DateTime lastSentAt;
  int attemptsUsed = 0;
  bool isLocked = false;
}
