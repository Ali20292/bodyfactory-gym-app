import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

/// What was booked. [referenceId] points at a `TrainerSlot` or a `GymClass`
/// depending on this value.
enum ReservationKind {
  @JsonValue('trainer')
  trainer,

  /// `class` is a reserved word in Dart, so the Dart name differs from the
  /// wire value. The `@JsonValue` is what keeps the contract intact.
  @JsonValue('class')
  gymClass,
}

enum ReservationStatus {
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('completed')
  completed,
}

/// A member's booking of a trainer slot or a class.
///
/// Cancellation windows, per-member booking limits, waitlists, and
/// double-booking rules are not specified yet. Nothing here assumes any of
/// them, so they can be added without restructuring.
@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required String memberId,
    @JsonKey(unknownEnumValue: ReservationKind.trainer)
    required ReservationKind kind,

    /// The `TrainerSlot.id` or `GymClass.id` this reservation is against.
    required String referenceId,
    required DateTime startsAt,
    @JsonKey(unknownEnumValue: ReservationStatus.confirmed)
    required ReservationStatus status,
  }) = _Reservation;

  const Reservation._();

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);

  bool get isConfirmed => status == ReservationStatus.confirmed;

  bool isUpcomingAt(DateTime now) => isConfirmed && startsAt.isAfter(now);

  /// Whether the member may cancel. The cancellation *window* is a product
  /// rule that has not been specified — until it is, the only client-side gate
  /// is "confirmed and not yet started", and the backend has the final say.
  bool isCancellableAt(DateTime now) => isUpcomingAt(now);
}
