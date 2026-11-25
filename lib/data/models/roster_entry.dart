import 'package:freezed_annotation/freezed_annotation.dart';

part 'roster_entry.freezed.dart';
part 'roster_entry.g.dart';

/// One member on a staff-facing roster for a class or a trainer slot.
///
/// Deliberately thin: a name and the id staff would quote at the front desk,
/// and nothing else. A roster is other people's data, so it carries the least
/// that makes it useful — no phone number, no membership tier, no history.
@freezed
abstract class RosterEntry with _$RosterEntry {
  const factory RosterEntry({
    required String memberId,
    required String username,
    required DateTime bookedAt,
  }) = _RosterEntry;

  const RosterEntry._();

  factory RosterEntry.fromJson(Map<String, dynamic> json) =>
      _$RosterEntryFromJson(json);
}
