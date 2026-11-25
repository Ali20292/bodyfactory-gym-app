import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym_event.freezed.dart';
part 'gym_event.g.dart';

enum GymEventType {
  @JsonValue('event')
  event,
  @JsonValue('offer')
  offer,
}

/// An item in the Home tab's events & offers list.
@freezed
abstract class GymEvent with _$GymEvent {
  const factory GymEvent({
    required String id,
    required String title,
    required String description,
    required DateTime startsAt,
    @JsonKey(unknownEnumValue: GymEventType.event) required GymEventType type,
    String? imageUrl,
    DateTime? endsAt,
  }) = _GymEvent;

  const GymEvent._();

  factory GymEvent.fromJson(Map<String, dynamic> json) =>
      _$GymEventFromJson(json);

  bool get isOffer => type == GymEventType.offer;

  /// True once the event has finished. Open-ended items ([endsAt] null) are
  /// treated as over when their start day has passed.
  bool isPastAt(DateTime now) => (endsAt ?? startsAt).isBefore(now);
}
