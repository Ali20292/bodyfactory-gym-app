import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/errors/failures.dart';
import 'package:gym_app/core/storage/session_store.dart';
import 'package:gym_app/data/mock/mock_data.dart';
import 'package:gym_app/data/models/models.dart';
import 'package:gym_app/data/repositories/account_repository_mock.dart';
import 'package:gym_app/data/repositories/auth_repository_mock.dart';
import 'package:gym_app/data/repositories/calendar_repository.dart';
import 'package:gym_app/data/repositories/calendar_repository_mock.dart';
import 'package:gym_app/data/repositories/gym_repository_mock.dart';
import 'package:gym_app/data/repositories/reservation_repository_mock.dart';

void main() {
  group('MockGymRepository occupancy', () {
    const Duration window = Duration(minutes: 75);

    MockGymRepository repositoryAt(DateTime now) => MockGymRepository(
      random: Random(7),
      clock: () => now,
      sessionWindow: window,
      maxCapacity: 120,
    );

    test('a re-scan inside the window does not count the member twice', () {
      final DateTime now = DateTime(2026, 8, 6, 3);
      final MockGymRepository repository = repositoryAt(now);

      repository.recordEntry(memberId: 'GM-1001', at: now);
      repository.recordEntry(
        memberId: 'GM-1001',
        at: now.add(const Duration(minutes: 20)),
      );

      expect(repository.occupancyAt(now.add(const Duration(minutes: 20))), 1);
    });

    test(
      'a re-scan pushes expiry forward rather than starting a second row',
      () {
        final DateTime now = DateTime(2026, 8, 6, 3);
        final MockGymRepository repository = repositoryAt(now);

        repository.recordEntry(memberId: 'GM-1001', at: now);
        // Without the refresh this member would drop out at +75.
        expect(repository.occupancyAt(now.add(const Duration(minutes: 80))), 0);

        repository.recordEntry(
          memberId: 'GM-1001',
          at: now.add(const Duration(minutes: 20)),
        );
        expect(repository.occupancyAt(now.add(const Duration(minutes: 80))), 1);
        expect(repository.occupancyAt(now.add(const Duration(minutes: 96))), 0);
      },
    );

    test('expiry is evaluated on read, so a long gap needs no catch-up', () {
      final DateTime now = DateTime(2026, 8, 6, 3);
      final MockGymRepository repository = repositoryAt(now);

      repository.recordEntry(memberId: 'GM-1001', at: now);

      // Nothing ran in between; the count is still right hours later.
      expect(repository.occupancyAt(now.add(const Duration(hours: 5))), 0);
    });

    test('simulates a busy evening and a quiet morning', () async {
      final GymCapacity evening = await repositoryAt(
        DateTime(2026, 8, 6, 19),
      ).fetchCapacity();
      expect(evening.currentOccupancy, inInclusiveRange(95, 115));

      final GymCapacity morning = await repositoryAt(
        DateTime(2026, 8, 6, 7),
      ).fetchCapacity();
      expect(morning.currentOccupancy, inInclusiveRange(15, 25));
    });

    test(
      'shows an empty gym in the small hours, not yesterday\'s leftovers',
      () async {
        final GymCapacity capacity = await repositoryAt(
          DateTime(2026, 8, 6, 4),
        ).fetchCapacity();

        expect(capacity.currentOccupancy, 0);
      },
    );

    test('the debug override reaches every colour band', () async {
      for (final OccupancyLevel level in OccupancyLevel.values) {
        final MockGymRepository repository = repositoryAt(
          DateTime(2026, 8, 6, 11),
        )..debugForceLevel(level);

        expect((await repository.fetchCapacity()).level, level);
      }
    });
  });

  group('MockAuthRepository', () {
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository(store: InMemorySessionStore());
    });

    tearDown(() => repository.dispose());

    test('signs in the demo member', () async {
      final AuthSession session = await repository.logIn(
        membershipId: MockData.demoMembershipId,
        password: MockData.demoPassword,
      );

      expect(session.member.id, MockData.demoMembershipId);
      expect(session.isExpired, isFalse);
    });

    test(
      'gives the same message for an unknown ID and a wrong password',
      () async {
        final Object unknownId = await _failureOf(
          () => repository.logIn(
            membershipId: 'GM-9999',
            password: MockData.demoPassword,
          ),
        );
        final Object wrongPassword = await _failureOf(
          () => repository.logIn(
            membershipId: MockData.demoMembershipId,
            password: 'not-the-password',
          ),
        );

        expect(unknownId, isA<AuthFailure>());
        expect(wrongPassword, isA<AuthFailure>());
        // The whole point: nothing distinguishes the two.
        expect(
          (unknownId as Failure).message,
          (wrongPassword as Failure).message,
        );
      },
    );

    test(
      'sign-up blurs "no such ID" and "already registered" together',
      () async {
        final Object unknown = await _failureOf(
          () => repository.signUp(
            username: 'newuser',
            membershipId: 'GM-9999',
            password: 'password123',
          ),
        );
        final Object taken = await _failureOf(
          () => repository.signUp(
            username: 'newuser',
            membershipId: MockData.demoMembershipId,
            password: 'password123',
          ),
        );

        expect((unknown as Failure).message, (taken as Failure).message);
        expect(unknown.message, contains('front desk'));
      },
    );

    test(
      'rejects a weak password server-side even if the client let it past',
      () async {
        final Object failure = await _failureOf(
          () => repository.signUp(
            username: 'newuser',
            membershipId: MockData.signUpReadyMembershipId,
            password: 'lettersonly',
          ),
        );

        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).fieldErrors,
          contains('password'),
        );
      },
    );

    test('accepts the right OTP and locks after five wrong ones', () async {
      SignUpChallenge challenge = await repository.signUp(
        username: 'newuser',
        membershipId: MockData.signUpReadyMembershipId,
        password: 'password123',
      );
      expect(challenge.maskedPhone, MockData.demoMaskedPhone);
      expect(challenge.attemptsRemaining, 5);

      for (int attempt = 4; attempt >= 1; attempt--) {
        final Object failure = await _failureOf(
          () => repository.verifyOtp(
            challengeId: challenge.challengeId,
            code: '000000',
          ),
        );
        expect((failure as OtpFailure).attemptsRemaining, attempt);
        expect(failure.isLocked, isFalse);
      }

      final Object locked = await _failureOf(
        () => repository.verifyOtp(
          challengeId: challenge.challengeId,
          code: '000000',
        ),
      );
      expect((locked as OtpFailure).isLocked, isTrue);

      // Starting over issues a fresh challenge, which accepts the right code.
      challenge = await repository.signUp(
        username: 'newuser',
        membershipId: MockData.signUpReadyMembershipId,
        password: 'password123',
      );
      await expectLater(
        repository.verifyOtp(
          challengeId: challenge.challengeId,
          code: MockData.demoOtpCode,
        ),
        completes,
      );
    });

    test('rate-limits resend inside the cooldown', () async {
      final SignUpChallenge challenge = await repository.signUp(
        username: 'newuser',
        membershipId: MockData.signUpReadyMembershipId,
        password: 'password123',
      );

      final Object failure = await _failureOf(
        () => repository.resendOtp(challengeId: challenge.challengeId),
      );

      expect(failure, isA<RateLimitFailure>());
      expect((failure as RateLimitFailure).retryAfter, isNotNull);
    });

    test('logging out clears the stored session', () async {
      final InMemorySessionStore store = InMemorySessionStore();
      final MockAuthRepository repo = MockAuthRepository(store: store);
      addTearDown(repo.dispose);

      await repo.logIn(
        membershipId: MockData.demoMembershipId,
        password: MockData.demoPassword,
      );
      expect(await repo.restoreSession(), isNotNull);

      await repo.logOut();
      expect(await store.read(), isNull);
      expect(await repo.restoreSession(), isNull);
    });
  });

  group('MockReservationRepository', () {
    test('booking a slot takes it, and cancelling gives it back', () async {
      final MockReservationRepository repository = MockReservationRepository();

      final List<TrainerSlot> slots = await repository.fetchTrainerSlots(
        'tr-1',
      );
      final TrainerSlot free = slots.firstWhere(
        (TrainerSlot slot) => slot.isBookableAt(DateTime.now()),
      );

      final Reservation reservation = await repository.bookTrainerSlot(free.id);
      expect(reservation.status, ReservationStatus.confirmed);

      final List<TrainerSlot> after = await repository.fetchTrainerSlots(
        'tr-1',
      );
      expect(
        after.firstWhere((TrainerSlot slot) => slot.id == free.id).isBooked,
        isTrue,
      );

      // Booking the same slot again is a conflict, not a second reservation.
      expect(
        await _failureOf(() => repository.bookTrainerSlot(free.id)),
        isA<ConflictFailure>(),
      );

      await repository.cancelReservation(reservation.id);
      final List<TrainerSlot> restored = await repository.fetchTrainerSlots(
        'tr-1',
      );
      expect(
        restored.firstWhere((TrainerSlot slot) => slot.id == free.id).isBooked,
        isFalse,
      );
    });

    test('a full class cannot be booked', () async {
      final MockReservationRepository repository = MockReservationRepository();
      final List<GymClass> classes = await repository.fetchClasses();
      final GymClass full = classes.firstWhere(
        (GymClass gymClass) => gymClass.isFull,
        orElse: () => classes.first,
      );

      if (!full.isFull) return; // no full class seeded today

      expect(
        await _failureOf(() => repository.bookClass(full.id)),
        isA<ConflictFailure>(),
      );
    });
  });

  group('MockCalendarRepository split templates', () {
    const SplitTemplate ppl = SplitTemplate(
      id: 'tpl-ppl',
      name: 'PPL',
      days: <String>['Push', 'Pull', 'Legs', 'Rest'],
    );

    // A future range, so it does not collide with the seeded four weeks of
    // history.
    final DateTime from = DateTime(2027, 3, 1);
    final DateTime to = DateTime(2027, 3, 14);

    test('rotating rolls the cycle forward regardless of weekday', () async {
      final MockCalendarRepository repository = MockCalendarRepository();

      final ApplyTemplateResult result = await repository.applyTemplate(
        template: ppl,
        from: from,
        to: to,
        mode: SplitRepeatMode.rotating,
        onConflict: OverwritePolicy.overwrite,
      );

      expect(result.written, 14);
      final List<CalendarNote> notes = await repository.fetchNotes(
        from: from,
        to: to,
      );
      expect(
        notes.map((CalendarNote note) => note.label).take(5).toList(),
        <String>['Push', 'Pull', 'Legs', 'Rest', 'Push'],
      );
    });

    test('weekly pins each label to a weekday', () async {
      final MockCalendarRepository repository = MockCalendarRepository();

      await repository.applyTemplate(
        template: ppl,
        from: from,
        to: to,
        mode: SplitRepeatMode.weekly,
        onConflict: OverwritePolicy.overwrite,
      );

      final List<CalendarNote> notes = await repository.fetchNotes(
        from: from,
        to: to,
      );
      final Iterable<CalendarNote> mondays = notes.where(
        (CalendarNote note) => note.date.weekday == DateTime.monday,
      );

      expect(mondays, isNotEmpty);
      expect(
        mondays.every((CalendarNote note) => note.label == 'Push'),
        isTrue,
      );
    });

    test('keepExisting leaves existing notes alone', () async {
      final MockCalendarRepository repository = MockCalendarRepository();
      await repository.upsertNote(date: from, label: 'Do not touch');

      final ApplyTemplateResult result = await repository.applyTemplate(
        template: ppl,
        from: from,
        to: to,
        mode: SplitRepeatMode.rotating,
        onConflict: OverwritePolicy.keepExisting,
      );

      expect(result.skipped, 1);
      expect(result.written, 13);
      expect(result.replaced, isEmpty);

      final List<CalendarNote> notes = await repository.fetchNotes(
        from: from,
        to: from,
      );
      expect(notes.single.label, 'Do not touch');
    });

    test('an overwrite is undoable for the session', () async {
      final MockCalendarRepository repository = MockCalendarRepository();
      await repository.upsertNote(date: from, label: 'Original');

      final ApplyTemplateResult result = await repository.applyTemplate(
        template: ppl,
        from: from,
        to: to,
        mode: SplitRepeatMode.rotating,
        onConflict: OverwritePolicy.overwrite,
      );

      expect(result.replaced.single.label, 'Original');
      expect(result.createdDays, hasLength(13));
      expect(result.hasUndo, isTrue);

      await repository.restoreNotes(
        notes: result.replaced,
        clearedDays: result.createdDays,
      );

      final List<CalendarNote> notes = await repository.fetchNotes(
        from: from,
        to: to,
      );
      expect(notes.single.label, 'Original');
    });
  });

  group('MockAccountRepository', () {
    test('rejects a taken username', () async {
      final MockAccountRepository repository = MockAccountRepository();

      expect(
        await _failureOf(() => repository.updateUsername('admin')),
        isA<ValidationFailure>(),
      );
      expect(
        await _failureOf(() => repository.updateUsername('ab')),
        isA<ValidationFailure>(),
      );

      final Member updated = await repository.updateUsername('  yasser.a  ');
      expect(updated.username, 'yasser.a');
    });

    test('rejects an oversized profile picture', () async {
      final MockAccountRepository repository = MockAccountRepository();

      expect(
        await _failureOf(
          () => repository.updateProfileImage(
            bytes: Uint8List(600 * 1024),
            fileName: 'big.jpg',
          ),
        ),
        isA<ValidationFailure>(),
      );
    });
  });
}

/// Runs [action] and returns the [Failure] it threw.
Future<Object> _failureOf(Future<void> Function() action) async {
  try {
    await action();
  } catch (error) {
    return error;
  }
  fail('Expected a Failure, but the call succeeded.');
}
