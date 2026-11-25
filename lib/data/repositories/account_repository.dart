import 'dart:typed_data';

import '../models/models.dart';

/// The signed-in member's own profile.
abstract class AccountRepository {
  Future<Member> fetchProfile();

  /// Throws `ValidationFailure` when the username is malformed or already
  /// taken — uniqueness is decided server-side, never in the client.
  Future<Member> updateUsername(String username);

  /// Uploads a new profile picture and returns the updated member.
  ///
  /// Takes bytes rather than a `File` so the caller owns cropping and
  /// compression (≤ 500 KB) and nothing here depends on `dart:io`.
  Future<Member> updateProfileImage({
    required Uint8List bytes,
    required String fileName,
  });

  /// Guest invitations the member has already spent, newest first.
  Future<List<InvitationUsage>> fetchInvitationHistory();
}
