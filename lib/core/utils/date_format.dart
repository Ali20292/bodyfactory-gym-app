import 'app_date.dart';

/// Human-facing date and time strings.
///
/// Written by hand rather than with `intl`: the app has one locale today and
/// pulling in a formatting package for six strings is not worth it. When the
/// Arabic question in CLAUDE.md gets answered this file is the thing to
/// replace — everything user-visible about dates goes through here, so there
/// is one place to change and no formatting scattered through the widgets.
class AppDateFormat {
  const AppDateFormat._();

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _weekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// "Today", "Tomorrow", or "Sat 8 Aug". The relative words only apply to the
  /// next two days — past that they stop being easier to read than the date.
  static String dayLabel(DateTime date, {DateTime? now}) {
    final DateTime today = AppDate.dayOf(now ?? DateTime.now());
    final int days = AppDate.daysApart(today, date);

    return switch (days) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ =>
        '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}',
    };
  }

  /// "7:00 PM".
  static String timeLabel(DateTime time) {
    final int hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
  }

  /// "8 Aug" — a date with no weekday, for ranges.
  static String shortDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]}';

  /// How long ago something happened, for "Updated 2 min ago".
  ///
  /// Rounds down, and treats anything under a minute as "just now" — a bar
  /// that says "Updated 0 min ago" reads like a bug.
  static String relativeSince(DateTime time, {DateTime? now}) {
    final Duration elapsed = (now ?? DateTime.now()).difference(time);

    if (elapsed.isNegative || elapsed.inMinutes < 1) return 'just now';
    if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes} min ago';
    }
    if (elapsed.inHours < 24) {
      return '${elapsed.inHours} ${elapsed.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    return '${elapsed.inDays} ${elapsed.inDays == 1 ? 'day' : 'days'} ago';
  }
}
