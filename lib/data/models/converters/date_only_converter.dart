import 'package:json_annotation/json_annotation.dart';

import '../../../core/utils/app_date.dart';

/// Serialises a day-shaped field as `yyyy-MM-dd`.
///
/// Attendance days and calendar notes are calendar days, not instants. Sending
/// a full timestamp invites timezone drift that silently moves a marker to the
/// wrong day, so the wire format carries no time or offset at all.
class DateOnlyConverter implements JsonConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromJson(String json) => AppDate.dayOf(DateTime.parse(json));

  @override
  String toJson(DateTime object) => AppDate.keyOf(object);
}
