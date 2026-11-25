import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/errors/failures.dart';
import 'package:gym_app/core/theme/app_theme.dart';
import 'package:gym_app/data/models/models.dart';
import 'package:gym_app/data/repositories/repository_providers.dart';
import 'package:gym_app/data/repositories/reservation_repository.dart';
import 'package:gym_app/features/reservations/screens/reservations_screen.dart';
import 'package:gym_app/features/reservations/screens/trainer_detail_screen.dart';

/// Writes mutate the in-memory lists, the way the real mock does, so a test
/// can book a slot and then assert the schedule reflects it.
class FakeReservationRepository implements ReservationRepository {
  FakeReservationRepository({
    List<Trainer>? trainers,
    List<TrainerSlot>? slots,
    List<GymClass>? classes,
    List<Reservation>? reservations,
    this.bookSlotFailure,
    this.joinClassFailure,
  }) : trainers = trainers ?? <Trainer>[demoTrainer],
       slots = slots ?? demoSlots(),
       classes = classes ?? <GymClass>[demoClass()],
       reservations = reservations ?? <Reservation>[];

  final List<Trainer> trainers;
  final List<TrainerSlot> slots;
  final List<GymClass> classes;
  final List<Reservation> reservations;

  /// When set, [bookTrainerSlot] throws it — the "someone took it first" case.
  final Failure? bookSlotFailure;
  final Failure? joinClassFailure;

  final List<String> bookedSlotIds = <String>[];
  final List<String> joinedClassIds = <String>[];
  final List<String> cancelledIds = <String>[];

  @override
  Future<List<Trainer>> fetchTrainers() async => trainers;

  @override
  Future<Trainer> fetchTrainer(String trainerId) async =>
      trainers.firstWhere((Trainer trainer) => trainer.id == trainerId);

  @override
  Future<List<TrainerSlot>> fetchTrainerSlots(String trainerId) async =>
      slots.where((TrainerSlot slot) => slot.trainerId == trainerId).toList();

  @override
  Future<List<GymClass>> fetchClasses() async => classes;

  @override
  Future<List<Reservation>> fetchMyReservations() async => reservations;

  @override
  Future<Reservation> bookTrainerSlot(String slotId) async {
    final Failure? failure = bookSlotFailure;
    if (failure != null) throw failure;

    bookedSlotIds.add(slotId);
    final int index = slots.indexWhere((TrainerSlot slot) => slot.id == slotId);
    slots[index] = slots[index].copyWith(isBooked: true);

    final Reservation reservation = Reservation(
      id: 'rs-new',
      memberId: 'GM-1001',
      kind: ReservationKind.trainer,
      referenceId: slotId,
      startsAt: slots[index].startsAt,
      status: ReservationStatus.confirmed,
    );
    reservations.add(reservation);
    return reservation;
  }

  @override
  Future<Reservation> bookClass(String classId) async {
    final Failure? failure = joinClassFailure;
    if (failure != null) throw failure;

    joinedClassIds.add(classId);
    final int index = classes.indexWhere((GymClass c) => c.id == classId);
    classes[index] = classes[index].copyWith(
      bookedCount: classes[index].bookedCount + 1,
    );

    final Reservation reservation = Reservation(
      id: 'rs-new',
      memberId: 'GM-1001',
      kind: ReservationKind.gymClass,
      referenceId: classId,
      startsAt: classes[index].startsAt,
      status: ReservationStatus.confirmed,
    );
    reservations.add(reservation);
    return reservation;
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    cancelledIds.add(reservationId);
    reservations.removeWhere((Reservation r) => r.id == reservationId);
  }
}

const Trainer demoTrainer = Trainer(
  id: 'tr-1',
  name: 'Karim Adel',
  specialties: <String>['Powerlifting', 'Strength'],
  bio: 'Twelve years coaching barbell lifts.',
  rating: 4.8,
);

/// Tomorrow at 10:00 and 11:00, the second one already taken.
List<TrainerSlot> demoSlots() {
  final DateTime day = DateTime.now().add(const Duration(days: 1));
  final DateTime base = DateTime(day.year, day.month, day.day, 10);

  return <TrainerSlot>[
    TrainerSlot(
      id: 'tr-1-slot-10',
      trainerId: 'tr-1',
      startsAt: base,
      durationMinutes: 60,
      isBooked: false,
    ),
    TrainerSlot(
      id: 'tr-1-slot-11',
      trainerId: 'tr-1',
      startsAt: base.add(const Duration(hours: 1)),
      durationMinutes: 60,
      isBooked: true,
    ),
  ];
}

GymClass demoClass({int capacity = 20, int booked = 12}) {
  final DateTime day = DateTime.now().add(const Duration(days: 1));

  return GymClass(
    id: 'cl-1',
    name: 'Spin',
    description: 'Intervals on the bike.',
    instructorName: 'Nada Hassan',
    startsAt: DateTime(day.year, day.month, day.day, 18),
    durationMinutes: 45,
    capacity: capacity,
    bookedCount: booked,
    room: 'Studio 2',
  );
}

Future<void> pumpScreen(
  WidgetTester tester,
  FakeReservationRepository repository,
  Widget screen, {
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        reservationRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(theme: AppTheme.brand, home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

/// Taps a tab by its label.
///
/// The tab strip is scrollable, and at test widths the third tab can sit past
/// the right edge — where a tap resolves to nothing. Scrolling it in first is
/// what a user's thumb would do anyway.
Future<void> openTab(WidgetTester tester, String label) async {
  final Finder tab = find.text(label);
  await tester.ensureVisible(tab);
  await tester.pumpAndSettle();
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

void main() {
  group('Trainers', () {
    testWidgets('lists each trainer with what they specialise in', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        FakeReservationRepository(),
        const ReservationsScreen(),
      );

      expect(find.text('Karim Adel'), findsOneWidget);
      expect(find.text('Powerlifting'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
    });

    testWidgets('shows free times as tappable and taken ones crossed out', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        FakeReservationRepository(),
        const TrainerDetailScreen(trainerId: 'tr-1'),
      );

      expect(find.text('Karim Adel'), findsOneWidget);
      expect(find.text('Twelve years coaching barbell lifts.'), findsOneWidget);
      expect(find.text('10:00 AM'), findsOneWidget);
      expect(find.text('11:00 AM'), findsOneWidget);

      // The taken one is announced as taken, not merely styled differently.
      expect(find.bySemanticsLabel(RegExp('11:00 AM, taken')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('10:00 AM, available')),
        findsOneWidget,
      );
    });

    testWidgets('booking a slot confirms first, then writes it', (
      WidgetTester tester,
    ) async {
      final FakeReservationRepository repository = FakeReservationRepository();
      await pumpScreen(
        tester,
        repository,
        const TrainerDetailScreen(trainerId: 'tr-1'),
      );

      await tester.tap(find.text('10:00 AM'));
      await tester.pumpAndSettle();

      // Nothing is written until the sheet is confirmed.
      expect(find.text('Book a session'), findsOneWidget);
      expect(repository.bookedSlotIds, isEmpty);

      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      expect(repository.bookedSlotIds, <String>['tr-1-slot-10']);
      expect(find.textContaining('Booked — Karim Adel'), findsOneWidget);
    });

    testWidgets('backing out of the sheet books nothing', (
      WidgetTester tester,
    ) async {
      final FakeReservationRepository repository = FakeReservationRepository();
      await pumpScreen(
        tester,
        repository,
        const TrainerDetailScreen(trainerId: 'tr-1'),
      );

      await tester.tap(find.text('10:00 AM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(repository.bookedSlotIds, isEmpty);
    });

    testWidgets('a slot taken between load and tap surfaces the reason', (
      WidgetTester tester,
    ) async {
      final FakeReservationRepository repository = FakeReservationRepository(
        bookSlotFailure: const ConflictFailure(
          'That slot has just been taken. Please pick another time.',
        ),
      );
      await pumpScreen(
        tester,
        repository,
        const TrainerDetailScreen(trainerId: 'tr-1'),
      );

      await tester.tap(find.text('10:00 AM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      expect(find.textContaining('just been taken'), findsOneWidget);
    });
  });

  group('Classes', () {
    testWidgets('shows the class with its spots and a Join button', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        FakeReservationRepository(),
        const ReservationsScreen(),
      );
      await openTab(tester, 'Classes');

      expect(find.text('Spin'), findsOneWidget);
      expect(find.text('with Nada Hassan'), findsOneWidget);
      // Counted down, not up: 12 of 20 taken means 8 left, and the badge says
      // the thing the member actually needs to know.
      expect(find.text('8 spots left'), findsOneWidget);
      expect(find.text('Studio 2'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Join'), findsOneWidget);
    });

    testWidgets('joining confirms, writes, and updates the spot count', (
      WidgetTester tester,
    ) async {
      final FakeReservationRepository repository = FakeReservationRepository();
      await pumpScreen(tester, repository, const ReservationsScreen());
      await openTab(tester, 'Classes');

      await tester.tap(find.widgetWithText(FilledButton, 'Join'));
      await tester.pumpAndSettle();

      expect(find.text('Join this class'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Join class'));
      await tester.pumpAndSettle();

      expect(repository.joinedClassIds, <String>['cl-1']);
      expect(find.text('7 spots left'), findsOneWidget);
      // Already in it, so the button is gone rather than offering a second
      // booking of the same class.
      expect(find.widgetWithText(FilledButton, 'Join'), findsNothing);
      expect(find.text("You're in"), findsOneWidget);
    });

    testWidgets('a full class cannot be joined', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        FakeReservationRepository(
          classes: <GymClass>[demoClass(capacity: 12, booked: 12)],
        ),
        const ReservationsScreen(),
      );
      await openTab(tester, 'Classes');

      expect(find.text('Class full'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Join'), findsNothing);
    });
  });

  group('Booked', () {
    testWidgets('lists an upcoming booking and cancels it after confirming', (
      WidgetTester tester,
    ) async {
      final GymClass gymClass = demoClass();
      final FakeReservationRepository repository = FakeReservationRepository(
        classes: <GymClass>[gymClass],
        reservations: <Reservation>[
          Reservation(
            id: 'rs-1',
            memberId: 'GM-1001',
            kind: ReservationKind.gymClass,
            referenceId: gymClass.id,
            startsAt: gymClass.startsAt,
            status: ReservationStatus.confirmed,
          ),
        ],
      );

      await pumpScreen(tester, repository, const ReservationsScreen());

      // The tab label carries the count.
      expect(find.text('Booked (1)'), findsOneWidget);

      await openTab(tester, 'Booked (1)');

      expect(find.text('Spin'), findsOneWidget);
      expect(find.text('with Nada Hassan · Studio 2'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Confirmed first — a cancel is destructive.
      expect(repository.cancelledIds, isEmpty);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel booking'));
      await tester.pumpAndSettle();

      expect(repository.cancelledIds, <String>['rs-1']);
      expect(find.text('Booking cancelled.'), findsOneWidget);
    });

    testWidgets('says so when nothing is booked', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        FakeReservationRepository(),
        const ReservationsScreen(),
      );

      await openTab(tester, 'Booked');

      expect(find.text('Nothing booked yet'), findsOneWidget);
    });

    testWidgets('a past booking is not offered for cancellation', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        FakeReservationRepository(
          reservations: <Reservation>[
            Reservation(
              id: 'rs-old',
              memberId: 'GM-1001',
              kind: ReservationKind.gymClass,
              referenceId: 'cl-1',
              startsAt: DateTime.now().subtract(const Duration(days: 2)),
              status: ReservationStatus.confirmed,
            ),
          ],
        ),
        const ReservationsScreen(),
      );

      await openTab(tester, 'Booked');

      expect(find.text('Nothing booked yet'), findsOneWidget);
    });
  });

  testWidgets('lays out on a small phone without overflowing', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      FakeReservationRepository(),
      const ReservationsScreen(),
      size: const Size(320, 640),
    );

    expect(find.text('Karim Adel'), findsOneWidget);

    await openTab(tester, 'Classes');
    expect(find.text('Spin'), findsOneWidget);
  });
}
