import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/date_only_converter.dart';

part 'calendar_note.freezed.dart';
part 'calendar_note.g.dart';

/// Free text the member attaches to a day — "Leg Day", "Push", "Rest".
///
/// This is the split-tracking primitive: copy/paste and template application
/// both work by writing these.
@freezed
abstract class CalendarNote with _$CalendarNote {
  const factory CalendarNote({
    required String id,
    @DateOnlyConverter() required DateTime date,
    required String label,

    /// `RRGGBB` or `AARRGGBB`, without a leading `#`. Null means the theme
    /// picks the colour.
    String? colorHex,
  }) = _CalendarNote;

  const CalendarNote._();

  factory CalendarNote.fromJson(Map<String, dynamic> json) =>
      _$CalendarNoteFromJson(json);

  bool get isEmpty => label.trim().isEmpty;
}
