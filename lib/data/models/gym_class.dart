import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym_class.freezed.dart';
part 'gym_class.g.dart';

@freezed
abstract class GymClass with _$GymClass {
  const factory GymClass({
    required String id,
    required String name,
    required String description,
    required String instructorName,
    required DateTime startsAt,
    required int durationMinutes,
    required int capacity,
    required int bookedCount,
    required String room,
  }) = _GymClass;

  const GymClass._();

  factory GymClass.fromJson(Map<String, dynamic> json) =>
      _$GymClassFromJson(json);

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));

  /// Never negative, even if the backend sends a bookedCount above capacity.
  int get spotsRemaining => (capacity - bookedCount).clamp(0, capacity);

  bool get isFull => spotsRemaining == 0;

  /// "12/20 spots"
  String get spotsLabel => '$bookedCount/$capacity spots';

  bool isPastAt(DateTime now) => startsAt.isBefore(now);

  bool isBookableAt(DateTime now) => !isFull && !isPastAt(now);
}
