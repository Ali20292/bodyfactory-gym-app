import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/utils/date_format.dart';

void main() {
  group('dayLabel', () {
    final DateTime now = DateTime(2026, 8, 8, 18, 30);

    test('uses relative words only for the days either side of today', () {
      expect(
        AppDateFormat.dayLabel(DateTime(2026, 8, 8, 7), now: now),
        'Today',
      );
      expect(
        AppDateFormat.dayLabel(DateTime(2026, 8, 9), now: now),
        'Tomorrow',
      );
      expect(
        AppDateFormat.dayLabel(DateTime(2026, 8, 7), now: now),
        'Yesterday',
      );
      expect(
        AppDateFormat.dayLabel(DateTime(2026, 8, 10), now: now),
        'Mon 10 Aug',
      );
    });

    test('reads the day from the calendar date, not from the hour', () {
      // 11 PM today and 1 AM tomorrow are two hours apart but different days;
      // comparing instants rather than days is the classic way to get this
      // wrong.
      expect(
        AppDateFormat.dayLabel(DateTime(2026, 8, 8, 23), now: now),
        'Today',
      );
      expect(
        AppDateFormat.dayLabel(DateTime(2026, 8, 9, 1), now: now),
        'Tomorrow',
      );
    });
  });

  group('timeLabel', () {
    test('turns midnight and noon into 12, not 0', () {
      expect(AppDateFormat.timeLabel(DateTime(2026, 8, 8, 0, 5)), '12:05 AM');
      expect(AppDateFormat.timeLabel(DateTime(2026, 8, 8, 12)), '12:00 PM');
      expect(AppDateFormat.timeLabel(DateTime(2026, 8, 8, 19)), '7:00 PM');
    });
  });

  group('relativeSince', () {
    final DateTime now = DateTime(2026, 8, 8, 18, 30);

    test('never says "0 min ago"', () {
      expect(
        AppDateFormat.relativeSince(
          now.subtract(const Duration(seconds: 20)),
          now: now,
        ),
        'just now',
      );
    });

    test('a clock that is slightly ahead still reads as just now', () {
      expect(
        AppDateFormat.relativeSince(
          now.add(const Duration(seconds: 30)),
          now: now,
        ),
        'just now',
      );
    });

    test('counts minutes, then hours, then days', () {
      expect(
        AppDateFormat.relativeSince(
          now.subtract(const Duration(minutes: 2)),
          now: now,
        ),
        '2 min ago',
      );
      expect(
        AppDateFormat.relativeSince(
          now.subtract(const Duration(hours: 1)),
          now: now,
        ),
        '1 hour ago',
      );
      expect(
        AppDateFormat.relativeSince(
          now.subtract(const Duration(days: 3)),
          now: now,
        ),
        '3 days ago',
      );
    });
  });
}
