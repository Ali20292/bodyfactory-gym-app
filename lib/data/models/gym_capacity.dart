import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym_capacity.freezed.dart';
part 'gym_capacity.g.dart';

/// How busy the gym reads to the member.
enum OccupancyLevel {
  quiet('Quiet'),
  moderate('Moderate'),
  busy('Busy'),
  packed('Packed');

  const OccupancyLevel(this.label);

  final String label;
}

/// The payload of `GET /gym/capacity`.
///
/// The app **never computes occupancy itself** — it displays whatever
/// `currentOccupancy` the backend returns. All counting, deduplication, and
/// window expiry is server-side. The getters below are presentation maths only.
@freezed
abstract class GymCapacity with _$GymCapacity {
  const factory GymCapacity({
    required int currentOccupancy,
    required int maxCapacity,
    required DateTime updatedAt,
  }) = _GymCapacity;

  const GymCapacity._();

  factory GymCapacity.fromJson(Map<String, dynamic> json) =>
      _$GymCapacityFromJson(json);

  /// Unclamped, so the *text* can honestly read 108% when more people are
  /// inside than the gym is rated for.
  double get occupancyRatio =>
      maxCapacity <= 0 ? 0 : currentOccupancy / maxCapacity;

  /// Clamped to 0..1 — this is what the bar's fill uses, so an over-capacity
  /// reading cannot overflow the widget.
  double get fillRatio => occupancyRatio.clamp(0.0, 1.0);

  int get occupancyPercent => (occupancyRatio * 100).round();

  /// Bands from the spec, expressed as ratios so they hold if `maxCapacity`
  /// ever changes: quiet < 40%, moderate 40–70%, busy 70–90%, packed > 90%.
  /// Against the default max of 120 that is 0–47 / 48–83 / 84–107 / 108+.
  OccupancyLevel get level {
    final double ratio = occupancyRatio;
    if (ratio < 0.4) return OccupancyLevel.quiet;
    if (ratio < 0.7) return OccupancyLevel.moderate;
    if (ratio < 0.9) return OccupancyLevel.busy;
    return OccupancyLevel.packed;
  }

  /// "38 of 120 members in the gym"
  String get countLabel =>
      '$currentOccupancy of $maxCapacity members in the gym';
}
