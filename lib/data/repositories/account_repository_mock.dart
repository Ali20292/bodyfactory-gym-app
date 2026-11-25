import 'dart:async';
import 'dart:typed_data';

import '../../core/config/app_config.dart';
import '../../core/errors/failures.dart';
import '../mock/mock_data.dart';
import '../mock/mock_store.dart';
import '../models/models.dart';
import 'account_repository.dart';

/// In-memory profile. Edits stick for the session so optimistic updates and
/// their rollbacks can both be exercised.
class MockAccountRepository implements AccountRepository {
  MockAccountRepository({MockStore? store, DateTime Function()? clock})
    : _store = store ?? MockStore(),
      _now = clock ?? DateTime.now;

  /// Where the signed-in member lives. Reading it here is the mock's version
  /// of a backend resolving the token to a profile — which is why signing in
  /// as staff now shows the staff account rather than a hardcoded member.
  final MockStore _store;

  /// Usernames the mock treats as taken, so the rollback path is reachable.
  static const Set<String> takenUsernames = <String>{'admin', 'coach', 'gym'};

  static const int _maxImageBytes = 500 * 1024;

  final DateTime Function() _now;

  /// The signed-in member, kept in the store so it survives this repository
  /// being rebuilt and so the auth mock can set it.
  Member get _member => _store.signedInMember;
  set _member(Member value) => _store.signedInMember = value;
  late final List<InvitationUsage> _invitations = MockData.invitationHistory();

  int _nextImage = 0;

  @override
  Future<Member> fetchProfile() async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return _member;
  }

  @override
  Future<Member> updateUsername(String username) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final String trimmed = username.trim();
    if (trimmed.length < 3 || trimmed.length > 30) {
      throw const ValidationFailure(
        'Use between 3 and 30 characters.',
        fieldErrors: <String, String>{
          'username': 'Use between 3 and 30 characters.',
        },
      );
    }

    // Uniqueness is the server's call, never the client's.
    if (takenUsernames.contains(trimmed.toLowerCase())) {
      throw const ValidationFailure(
        'That username is taken.',
        fieldErrors: <String, String>{'username': 'That username is taken.'},
      );
    }

    _member = _member.copyWith(username: trimmed);
    return _member;
  }

  @override
  Future<Member> updateProfileImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    // The caller crops and compresses; this is the server-side check that the
    // limit was actually respected.
    if (bytes.lengthInBytes > _maxImageBytes) {
      throw const ValidationFailure(
        'That picture is too large. Please choose a smaller one.',
      );
    }

    _member = _member.copyWith(
      // A changing URL so the image cache does not serve the old picture.
      profileImageUrl:
          'https://picsum.photos/seed/profile${_nextImage++}/300/300',
    );
    return _member;
  }

  @override
  Future<List<InvitationUsage>> fetchInvitationHistory() async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return _invitations.toList()..sort(
      (InvitationUsage a, InvitationUsage b) => b.usedAt.compareTo(a.usedAt),
    );
  }

  /// Spends one invitation. Not on the interface yet — how invitations are
  /// redeemed is still an open question — but the seam is here.
  void debugSpendInvitation(String? guestName) {
    if (!_member.hasInvitationsLeft) return;
    _member = _member.copyWith(
      invitationsRemaining: _member.invitationsRemaining - 1,
    );
    _invitations.add(
      InvitationUsage(
        id: 'inv-${_invitations.length + 1}',
        usedAt: _now(),
        guestName: guestName,
      ),
    );
  }
}
