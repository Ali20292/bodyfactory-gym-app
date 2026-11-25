import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/data/models/models.dart';

void main() {
  group('GymCapacity', () {
    GymCapacity at(int occupancy, {int max = 120}) => GymCapacity(
      currentOccupancy: occupancy,
      maxCapacity: max,
      updatedAt: DateTime(2026, 8, 6, 18),
    );

    test('bands match the spec against a max of 120', () {
      // green < 40% (0-47), amber 40-70% (48-83),
      // orange 70-90% (84-107), red > 90% (108+)
      expect(at(0).level, OccupancyLevel.quiet);
      expect(at(47).level, OccupancyLevel.quiet);
      expect(at(48).level, OccupancyLevel.moderate);
      expect(at(83).level, OccupancyLevel.moderate);
      expect(at(84).level, OccupancyLevel.busy);
      expect(at(107).level, OccupancyLevel.busy);
      expect(at(108).level, OccupancyLevel.packed);
      expect(at(120).level, OccupancyLevel.packed);
    });

    test('41 of 120 reads 34% / Quiet', () {
      // CLAUDE.md's worked example labels this one "Moderate", which
      // contradicts its own bands (green < 40%, i.e. 0-47). The bands win --
      // confirmed with the product owner on 2026-08-06.
      final GymCapacity capacity = at(41);

      expect(capacity.occupancyPercent, 34);
      expect(capacity.level, OccupancyLevel.quiet);
      expect(capacity.countLabel, '41 of 120 members in the gym');
    });

    test('over capacity reports honestly but does not overflow the bar', () {
      final GymCapacity capacity = at(130);

      expect(capacity.occupancyPercent, 108);
      expect(capacity.fillRatio, 1.0);
    });

    test('a zero max does not divide by zero', () {
      expect(at(5, max: 0).occupancyRatio, 0);
      expect(at(5, max: 0).fillRatio, 0);
    });

    test('round-trips through JSON', () {
      final GymCapacity capacity = at(41);

      expect(GymCapacity.fromJson(capacity.toJson()), capacity);
      expect(capacity.toJson()['currentOccupancy'], 41);
      expect(capacity.toJson()['maxCapacity'], 120);
    });
  });

  group('CheckIn', () {
    final DateTime enteredAt = DateTime(2026, 8, 6, 18);
    const Duration window = Duration(minutes: 75);

    CheckIn checkIn() => CheckIn(
      memberId: 'GM-1001',
      enteredAt: enteredAt,
      expiresAt: enteredAt.add(window),
      source: CheckInSource.turnstile,
    );

    test('counts the member from entry until the window closes', () {
      expect(checkIn().isActiveAt(enteredAt), isTrue);
      expect(
        checkIn().isActiveAt(enteredAt.add(const Duration(minutes: 74))),
        isTrue,
      );
      // The window is half-open: at exactly +75 the member drops out.
      expect(checkIn().isActiveAt(enteredAt.add(window)), isFalse);
      expect(
        checkIn().isActiveAt(enteredAt.subtract(const Duration(minutes: 1))),
        isFalse,
      );
    });

    test(
      'a re-scan inside the window pushes expiry forward, not a new row',
      () {
        final DateTime rescan = enteredAt.add(const Duration(minutes: 20));
        final CheckIn refreshed = checkIn().refreshed(rescan, window);

        expect(refreshed.expiresAt, rescan.add(window));
        expect(refreshed.memberId, 'GM-1001');
      },
    );

    test('an exit signal can close the window early', () {
      final DateTime exit = enteredAt.add(const Duration(minutes: 30));

      expect(checkIn().closedAt(exit).isActiveAt(exit), isFalse);
    });
  });

  group('AuthSession', () {
    final AuthSession session = AuthSession(
      accessToken: 'access-token-value',
      refreshToken: 'refresh-token-value',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      member: Member(
        id: 'GM-1001',
        username: 'yasser',
        phoneMasked: '+20 1** *** 4471',
        membershipTier: 'Standard',
        membershipExpiry: DateTime(2027),
        invitationsRemaining: 3,
      ),
    );

    test('never puts a token in its toString', () {
      expect(session.toString(), isNot(contains('access-token-value')));
      expect(session.toString(), isNot(contains('refresh-token-value')));
      expect(session.toString(), contains('<redacted>'));
    });

    test('flags a session that is close to expiry', () {
      expect(session.isExpired, isFalse);
      expect(
        session
            .copyWith(
              expiresAt: DateTime.now().add(const Duration(seconds: 30)),
            )
            .needsRefresh,
        isTrue,
      );
    });
  });

  group('CalendarNote', () {
    test('serialises the day without a time or offset', () {
      final CalendarNote note = CalendarNote(
        id: 'n1',
        date: DateTime(2026, 8, 6, 23, 30),
        label: 'Legs',
      );

      expect(note.toJson()['date'], '2026-08-06');
      // Round-tripping normalises to midnight local, so the marker lands on
      // the day the member picked regardless of timezone.
      expect(CalendarNote.fromJson(note.toJson()).date, DateTime(2026, 8, 6));
    });
  });

  group('GymClass', () {
    GymClass classWith({required int capacity, required int booked}) =>
        GymClass(
          id: 'c1',
          name: 'Spin',
          description: '45 minutes on the bike.',
          instructorName: 'Nada',
          startsAt: DateTime(2026, 8, 7, 19),
          durationMinutes: 45,
          capacity: capacity,
          bookedCount: booked,
          room: 'Studio 2',
        );

    test('reports remaining spots and fullness', () {
      expect(classWith(capacity: 20, booked: 12).spotsRemaining, 8);
      expect(classWith(capacity: 20, booked: 12).spotsLabel, '12/20 spots');
      expect(classWith(capacity: 20, booked: 20).isFull, isTrue);
    });

    test('never reports negative spots if the backend overshoots', () {
      expect(classWith(capacity: 20, booked: 23).spotsRemaining, 0);
      expect(classWith(capacity: 20, booked: 23).isFull, isTrue);
    });
  });

  group('SplitTemplate', () {
    const SplitTemplate ppl = SplitTemplate(
      id: 't1',
      name: 'PPL',
      days: <String>['Push', 'Pull', 'Legs', 'Rest'],
    );

    test('wraps around the cycle', () {
      expect(ppl.cycleLength, 4);
      expect(ppl.labelAt(0), 'Push');
      expect(ppl.labelAt(5), 'Pull');
    });

    test('an empty template returns null instead of throwing', () {
      const SplitTemplate empty = SplitTemplate(
        id: 't2',
        name: 'Empty',
        days: <String>[],
      );

      expect(empty.labelAt(0), isNull);
      expect(empty.isValid, isFalse);
    });
  });
}
