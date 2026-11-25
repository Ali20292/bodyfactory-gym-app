import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_in.freezed.dart';
part 'check_in.g.dart';

/// How the gym's entry system reported the check-in.
@JsonEnum(alwaysCreate: true)
enum CheckInSource {
  @JsonValue('turnstile')
  turnstile,
  @JsonValue('frontDesk')
  frontDesk,
  @JsonValue('manual')
  manual,
}

/// One member's presence window.
///
/// A backend-side concept — the app normally only sees the aggregate through
/// [GymCapacity], because a list of who is at the gym right now is exactly the
/// thing that must not reach a client. Modelled here so the mock repository can
/// exercise the same window logic the backend runs.
///
/// There is no exit signal today: presence is inferred from entry plus a fixed
/// session window (`SESSION_WINDOW_MINUTES`, 75 by default). [expiresAt] is a
/// plain field rather than a computed getter precisely so it can be overwritten
/// — re-scans push it forward, and a real exit signal would pull it back.
@freezed
abstract class CheckIn with _$CheckIn {
  const factory CheckIn({
    required String memberId,
    required DateTime enteredAt,
    required DateTime expiresAt,
    @JsonKey(unknownEnumValue: CheckInSource.manual)
    required CheckInSource source,
  }) = _CheckIn;

  const CheckIn._();

  factory CheckIn.fromJson(Map<String, dynamic> json) =>
      _$CheckInFromJson(json);

  /// The member counts as in the gym when [at] falls inside the window.
  /// Expiry is evaluated on read, never by a scheduled decrement, so the count
  /// stays correct even if the service was down.
  bool isActiveAt(DateTime at) =>
      !at.isBefore(enteredAt) && at.isBefore(expiresAt);

  bool get isActive => isActiveAt(DateTime.now());

  /// A re-scan inside the window must not count the member twice — it refreshes
  /// the window instead.
  CheckIn refreshed(DateTime at, Duration sessionWindow) =>
      copyWith(enteredAt: at, expiresAt: at.add(sessionWindow));

  /// Closes the window early. Used when the entry system starts reporting
  /// exits, at which point the 75-minute expiry becomes a fallback only.
  CheckIn closedAt(DateTime at) => copyWith(expiresAt: at);
}
