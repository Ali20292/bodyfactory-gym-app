import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';
part 'member.g.dart';

/// What a signed-in person is allowed to do.
///
/// The app uses this to decide what to *show*. It is not a security boundary:
/// the APK is public, so anyone can find the admin endpoints and call them.
/// Every write the staff tools make must be authorized again on the server
/// against the role on the token — see [AdminRepository].
enum MemberRole {
  @JsonValue('member')
  member,

  /// Gym staff: can post events, offers, classes and trainers.
  @JsonValue('staff')
  staff;

  bool get isStaff => this == MemberRole.staff;
}

/// A gym member. Field names are the contract with the backend.
@freezed
abstract class Member with _$Member {
  const factory Member({
    /// The gym membership ID the member logs in with. A String, not an int —
    /// gyms issue IDs with prefixes and leading zeros.
    required String id,
    required String username,

    /// Already masked by the backend, e.g. `+20 1** *** 4471`. The app never
    /// receives the full number.
    required String phoneMasked,

    /// Free text rather than an enum: the gym's tier names are a product rule
    /// that has not been specified yet.
    required String membershipTier,
    required DateTime membershipExpiry,
    required int invitationsRemaining,
    String? profileImageUrl,

    /// Defaults to [MemberRole.member], and an unrecognised value from the
    /// backend falls back to it too. A new role name must never accidentally
    /// grant staff tools to an ordinary member.
    @JsonKey(unknownEnumValue: MemberRole.member)
    @Default(MemberRole.member)
    MemberRole role,
  }) = _Member;

  const Member._();

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  bool get hasExpiredMembership => DateTime.now().isAfter(membershipExpiry);

  bool get hasInvitationsLeft => invitationsRemaining > 0;

  bool get isStaff => role.isStaff;
}
