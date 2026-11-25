import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation_usage.freezed.dart';
part 'invitation_usage.g.dart';

/// One guest invitation the member has already spent.
///
/// The Account screen's "usage history" needs *some* shape and none was
/// specified, so this is the minimum that makes the list readable. Whether
/// invitations expire or can be gifted is still an open question — nothing
/// here assumes either way.
@freezed
abstract class InvitationUsage with _$InvitationUsage {
  const factory InvitationUsage({
    required String id,
    required DateTime usedAt,

    /// Null when the gym recorded the visit without a name.
    String? guestName,
  }) = _InvitationUsage;

  const InvitationUsage._();

  factory InvitationUsage.fromJson(Map<String, dynamic> json) =>
      _$InvitationUsageFromJson(json);
}
