import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/date_only_converter.dart';

part 'attendance_record.freezed.dart';
part 'attendance_record.g.dart';

/// One day of the member's own attendance, used for the calendar's dots.
///
/// [checkOutAt] is nullable because the gym's entry system has no exit signal
/// today — presence is inferred from a fixed session window. If exits ever
/// start being reported, this fills in without a schema change.
@freezed
abstract class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    @DateOnlyConverter() required DateTime date,
    DateTime? checkInAt,
    DateTime? checkOutAt,
  }) = _AttendanceRecord;

  const AttendanceRecord._();

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);

  bool get attended => checkInAt != null;

  /// Null unless both ends are known, so an inferred window is never presented
  /// as a measured session length.
  Duration? get sessionLength => checkInAt != null && checkOutAt != null
      ? checkOutAt!.difference(checkInAt!)
      : null;
}
