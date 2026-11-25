/// Date helpers shared by the calendar and attendance features.
///
/// The calendar deals in *days*, not instants. Comparing two `DateTime`s that
/// carry a time component is the classic source of "the marker is on the wrong
/// day" bugs, so anything day-shaped is normalised through here first.
class AppDate {
  const AppDate._();

  /// Strips the time component, keeping the local calendar day.
  static DateTime dayOf(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime today() => dayOf(DateTime.now());

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Stable map key for a calendar day, e.g. `2026-08-06`.
  static String keyOf(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  /// Every day from [start] to [end] inclusive, normalised to midnight.
  ///
  /// Built by adding to the day-of-month rather than adding `Duration(days: 1)`
  /// so it stays correct across daylight-saving transitions.
  static List<DateTime> daysBetween(DateTime start, DateTime end) {
    final DateTime from = dayOf(start);
    final DateTime to = dayOf(end);
    if (to.isBefore(from)) return const <DateTime>[];

    final List<DateTime> days = <DateTime>[];
    for (
      DateTime cursor = from;
      !cursor.isAfter(to);
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1)
    ) {
      days.add(cursor);
    }
    return days;
  }

  /// Whole days from [start] to [end], ignoring time of day.
  static int daysApart(DateTime start, DateTime end) =>
      dayOf(end).difference(dayOf(start)).inDays;
}
