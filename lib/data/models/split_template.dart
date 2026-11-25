import 'package:freezed_annotation/freezed_annotation.dart';

part 'split_template.freezed.dart';
part 'split_template.g.dart';

/// How a [SplitTemplate] is laid over a date range.
enum SplitRepeatMode {
  /// Same weekdays every week — day 0 of [SplitTemplate.days] is Monday.
  @JsonValue('weekly')
  weekly,

  /// An N-day cycle that rolls forward regardless of weekday, the usual shape
  /// for a PPL split.
  @JsonValue('rotating')
  rotating,
}

/// A named training cycle, e.g. `["Push", "Pull", "Legs", "Rest"]`.
///
/// [days] is ordered and its length is the cycle length. Applying a template
/// writes one [CalendarNote] per day across the chosen range.
@freezed
abstract class SplitTemplate with _$SplitTemplate {
  const factory SplitTemplate({
    required String id,
    required String name,
    required List<String> days,
  }) = _SplitTemplate;

  const SplitTemplate._();

  factory SplitTemplate.fromJson(Map<String, dynamic> json) =>
      _$SplitTemplateFromJson(json);

  int get cycleLength => days.length;

  bool get isValid => days.isNotEmpty && name.trim().isNotEmpty;

  /// The label for position [index] in the cycle, wrapping around. Returns
  /// null for an empty template rather than throwing.
  String? labelAt(int index) {
    if (days.isEmpty) return null;
    return days[index % days.length];
  }
}
