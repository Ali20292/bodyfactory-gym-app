import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_slot.freezed.dart';
part 'trainer_slot.g.dart';

/// One bookable window in a trainer's schedule.
///
/// [durationMinutes] is per-slot rather than a global constant because whether
/// the gym runs fixed- or variable-length sessions is still an open question.
@freezed
abstract class TrainerSlot with _$TrainerSlot {
  const factory TrainerSlot({
    required String id,
    required String trainerId,
    required DateTime startsAt,
    required int durationMinutes,
    required bool isBooked,
  }) = _TrainerSlot;

  const TrainerSlot._();

  factory TrainerSlot.fromJson(Map<String, dynamic> json) =>
      _$TrainerSlotFromJson(json);

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));

  bool isPastAt(DateTime now) => startsAt.isBefore(now);

  /// Bookable means free *and* still in the future. The backend re-checks this
  /// on submit — client-side validation is never trusted.
  bool isBookableAt(DateTime now) => !isBooked && !isPastAt(now);
}
