import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../services/profile_image_service.dart';

/// The signed-in member's profile.
///
/// An [AsyncNotifier] rather than a `FutureProvider` because the username edit
/// is optimistic: the new name has to be on screen before the server has
/// agreed to it, and put back if it does not.
class ProfileController extends AsyncNotifier<Member> {
  bool _disposed = false;

  @override
  Future<Member> build() async {
    ref.onDispose(() => _disposed = true);
    return ref.watch(accountRepositoryProvider).fetchProfile();
  }

  AccountRepository get _repository => ref.read(accountRepositoryProvider);

  /// Renames the member. Returns null on success, or a message to show under
  /// the field.
  ///
  /// The new name appears immediately and is rolled back if the server rejects
  /// it — which it will for a name that is taken, since uniqueness is decided
  /// there and cannot be known here.
  Future<String?> updateUsername(String username) async {
    final Member? previous = state.valueOrNull;
    final String trimmed = username.trim();

    if (previous != null) {
      state = AsyncValue<Member>.data(previous.copyWith(username: trimmed));
    }

    try {
      final Member updated = await _repository.updateUsername(trimmed);
      if (_disposed) return null;
      state = AsyncValue<Member>.data(updated);
      return null;
    } on ValidationFailure catch (failure) {
      if (!_disposed && previous != null) {
        state = AsyncValue<Member>.data(previous);
      }
      return failure.fieldErrors['username'] ?? failure.message;
    } on Failure catch (failure) {
      if (!_disposed && previous != null) {
        state = AsyncValue<Member>.data(previous);
      }
      return failure.message;
    }
  }

  /// Picks a photo, crops and compresses it, and uploads it.
  ///
  /// Returns null on success, a message on failure, and null-with-no-change if
  /// the user backed out of the picker.
  Future<String?> changePhoto(PhotoOrigin origin) async {
    final PickedImage? picked = await ref
        .read(profileImageSourceProvider)
        .pick(origin);
    if (picked == null || _disposed) return null;

    // Off the UI isolate: decode plus re-encode of a phone photo is long
    // enough to drop frames, and this runs while a sheet is closing.
    final Uint8List? prepared = await compute(
      prepareProfileImage,
      picked.bytes,
    );
    if (_disposed) return null;

    if (prepared == null) {
      return "That file doesn't look like an image.";
    }

    try {
      final Member updated = await _repository.updateProfileImage(
        bytes: prepared,
        // Always a JPEG by the time it leaves here, whatever went in.
        fileName: '${_baseName(picked.fileName)}.jpg',
      );
      if (_disposed) return null;
      state = AsyncValue<Member>.data(updated);
      return null;
    } on Failure catch (failure) {
      return failure.message;
    }
  }

  String _baseName(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    final String stem = dot > 0 ? fileName.substring(0, dot) : fileName;
    return stem.isEmpty ? 'profile' : stem;
  }
}

final AsyncNotifierProvider<ProfileController, Member> profileProvider =
    AsyncNotifierProvider<ProfileController, Member>(ProfileController.new);

/// Invitations the member has already spent, newest first.
final AutoDisposeFutureProvider<List<InvitationUsage>>
invitationHistoryProvider = FutureProvider.autoDispose<List<InvitationUsage>>(
  (Ref ref) => ref.watch(accountRepositoryProvider).fetchInvitationHistory(),
);

/// Logging out.
///
/// Clears the stored session and nothing else here: the router is watching the
/// session stream, so the redirect to Login happens on its own. A screen
/// calling `go` after this would be a second source of truth for the same
/// event, and the two would eventually disagree.
final Provider<Future<void> Function()> logOutProvider =
    Provider<Future<void> Function()>((Ref ref) {
      return () async {
        await ref.read(authRepositoryProvider).logOut();
        // Anything cached about this member goes with the session.
        ref.invalidate(profileProvider);
        ref.invalidate(invitationHistoryProvider);
      };
    });
