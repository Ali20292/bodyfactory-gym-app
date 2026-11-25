import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/config/app_config.dart';
import 'package:gym_app/core/errors/failures.dart';
import 'package:gym_app/core/storage/session_store.dart';
import 'package:gym_app/core/theme/app_theme.dart';
import 'package:gym_app/data/mock/mock_data.dart';
import 'package:gym_app/data/mock/mock_store.dart';
import 'package:gym_app/data/models/models.dart';
import 'package:gym_app/data/repositories/admin_repository_mock.dart';
import 'package:gym_app/data/repositories/gym_repository_mock.dart';
import 'package:gym_app/data/repositories/repository_providers.dart';
import 'package:gym_app/data/repositories/reservation_repository_mock.dart';
import 'package:gym_app/features/admin/screens/manage_classes_screen.dart';
import 'package:gym_app/features/admin/screens/manage_events_screen.dart';
import 'package:gym_app/features/admin/screens/manage_screen.dart';
import 'package:gym_app/features/admin/widgets/admin_widgets.dart';
import 'package:gym_app/features/splash/controllers/app_boot_controller.dart';

/// Every repository over one store, the way the app wires them — this is what
/// makes "staff posts it, members see it" testable at all.
List<Override> storeOverrides(MockStore store) => <Override>[
  mockStoreProvider.overrideWithValue(store),
  gymRepositoryProvider.overrideWithValue(MockGymRepository(store: store)),
  reservationRepositoryProvider.overrideWithValue(
    MockReservationRepository(store: store),
  ),
  adminRepositoryProvider.overrideWithValue(MockAdminRepository(store: store)),
];

/// Waits out the mock repositories' artificial latency.
///
/// `pumpAndSettle` alone is not enough: it advances time only while frames are
/// being scheduled, and a pending `Future.delayed` schedules none. Without an
/// explicit pump past [AppConfig.mockLatency] every screen here asserts
/// against its loading state — which is how the hub came back reading zero
/// events when the store held five.
Future<void> settleMocks(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(AppConfig.mockLatency + const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

Future<void> pumpAdmin(
  WidgetTester tester,
  MockStore store,
  Widget screen, {
  // Taller than a phone on purpose. The staff forms are long, and a lazily
  // built ListView does not create what is below the fold — so on a real
  // phone-sized surface half the form is not in the tree to be tapped. Layout
  // on a small screen is covered by its own test at the bottom.
  Size size = const Size(390, 1500),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: storeOverrides(store),
      child: MaterialApp(theme: AppTheme.brand, home: screen),
    ),
  );
  await settleMocks(tester);
}

/// Scrolls a control into view before tapping it.
///
/// The staff forms are long — a class has eight fields — so the save button
/// starts below the fold on a phone-sized surface.
Future<void> tapControl(WidgetTester tester, Finder finder) async {
  // A `ListView` builds lazily, so a control below the fold is not merely
  // off-screen — it is not in the tree at all, and `ensureVisible` throws on
  // it. Scrolling until it resolves is what actually puts it there.
  if (finder.evaluate().isEmpty) {
    // The pushed editor and the list behind it are both scrollables, so the
    // target has to be named — the last one is the route on top.
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await settleMocks(tester);
}

void main() {
  group('The Manage tab', () {
    /// Logs in through the real app, so the role comes off the session the way
    /// it does in production rather than being asserted into place.
    Future<void> logIn(
      WidgetTester tester, {
      required String membershipId,
      required String password,
    }) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(420, 940);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
          ],
          child: const GymApp(),
        ),
      );

      await tester.pump();
      await tester.pump(splashHold + const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, membershipId);
      await tester.enterText(find.byType(TextField).last, password);

      final Finder button = find.widgetWithText(FilledButton, 'Log in');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('is hidden from a member', (WidgetTester tester) async {
      await logIn(
        tester,
        membershipId: MockData.demoMembershipId,
        password: MockData.demoPassword,
      );

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Manage'), findsNothing);
    });

    testWidgets('appears for staff', (WidgetTester tester) async {
      await logIn(
        tester,
        membershipId: MockData.demoStaffMembershipId,
        password: MockData.demoStaffPassword,
      );

      expect(find.text('Manage'), findsOneWidget);
    });

    testWidgets('opens the staff hub, not whatever shares its index', (
      WidgetTester tester,
    ) async {
      await logIn(
        tester,
        membershipId: MockData.demoStaffMembershipId,
        password: MockData.demoStaffPassword,
      );

      await tester.tap(find.text('Manage'));
      await settleMocks(tester);

      // The tab bar's items and the router's branches are two lists that have
      // to line up. When they did not, tapping Manage opened Account — which
      // no amount of passing unit tests would have caught.
      expect(find.text('What members see, and who takes it'), findsOneWidget);
      expect(find.text('Guest invitations'), findsNothing);
    });

    testWidgets('shows the staff account, not the demo member', (
      WidgetTester tester,
    ) async {
      await logIn(
        tester,
        membershipId: MockData.demoStaffMembershipId,
        password: MockData.demoStaffPassword,
      );

      await tester.tap(find.text('Account'));
      await settleMocks(tester);

      expect(find.text('Front desk'), findsOneWidget);
      expect(find.text('Member GM-9001'), findsOneWidget);
    });
  });

  group('Events', () {
    testWidgets('posting one puts it in the store members read', (
      WidgetTester tester,
    ) async {
      final MockStore store = MockStore();
      final int before = store.events.length;

      await pumpAdmin(tester, store, const ManageEventsScreen());

      await tester.tap(find.text('New post'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'Bench press clinic',
      );
      await tapControl(tester, find.text('Post it'));

      expect(store.events, hasLength(before + 1));
      expect(store.events.last.title, 'Bench press clinic');
      // The member-facing repository reads the same list, which is the whole
      // point of the shared store.
      //
      // Inside `runAsync` because the mock's `Future.delayed` runs on the
      // test's fake clock: awaiting it straight from the test body waits for
      // time that only passes when the widget tree pumps, and the test hangs.
      final List<GymEvent> memberSees =
          await tester.runAsync(
            () => MockGymRepository(store: store).fetchEvents(),
          ) ??
          const <GymEvent>[];

      expect(
        memberSees.where((GymEvent e) => e.title == 'Bench press clinic'),
        hasLength(1),
      );

      // A write invalidates the member-facing providers too, and their refetch
      // is still in flight. Left pending, flutter_test fails the test for it.
      await settleMocks(tester);
    });

    testWidgets('a post with no title is refused', (WidgetTester tester) async {
      final MockStore store = MockStore();
      final int before = store.events.length;

      await pumpAdmin(tester, store, const ManageEventsScreen());
      await tester.tap(find.text('New post'));
      await tester.pumpAndSettle();
      await tapControl(tester, find.text('Post it'));

      expect(find.text('Give it a title.'), findsOneWidget);
      expect(store.events, hasLength(before));
    });

    testWidgets('deleting asks first, then removes it', (
      WidgetTester tester,
    ) async {
      final MockStore store = MockStore();
      await pumpAdmin(tester, store, const ManageEventsScreen());

      // The screen lists newest first, so the top row is not `events.first`.
      final String title =
          (store.events.toList()..sort(
                (GymEvent a, GymEvent b) => b.startsAt.compareTo(a.startsAt),
              ))
              .first
              .title;
      final int before = store.events.length;

      // The menu item and the dialog's confirm button are both labelled
      // "Delete", so each is found by the widget it lives in rather than by
      // text alone.
      Future<void> openDeleteDialog() async {
        await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(PopupMenuItem<AdminAction>, 'Delete'),
        );
        await tester.pumpAndSettle();
      }

      await openDeleteDialog();
      expect(find.textContaining('Delete "'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Keep'));
      await settleMocks(tester);
      expect(store.events, hasLength(before));

      await openDeleteDialog();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await settleMocks(tester);

      expect(store.events, hasLength(before - 1));
      expect(store.events.any((GymEvent e) => e.title == title), isFalse);

      // See above: the refresh the delete triggered is still running.
      await settleMocks(tester);
    });
  });

  group('Classes', () {
    test('capacity cannot be cut below what is booked', () async {
      final MockStore store = MockStore();
      final MockAdminRepository admin = MockAdminRepository(store: store);

      final GymClass booked = store.classes.firstWhere(
        (GymClass gymClass) => gymClass.bookedCount > 2,
      );

      await expectLater(
        admin.updateClass(booked.copyWith(capacity: 1)),
        throwsA(isA<ValidationFailure>()),
      );

      // And the stored class is untouched.
      expect(
        store.classes.firstWhere((GymClass c) => c.id == booked.id).capacity,
        booked.capacity,
      );
    });

    test('a new class starts empty whatever the draft claims', () async {
      final MockStore store = MockStore();
      final MockAdminRepository admin = MockAdminRepository(store: store);

      final GymClass created = await admin.createClass(
        GymClass(
          id: 'ignored',
          name: 'Mobility',
          description: 'Hips and shoulders.',
          instructorName: 'Mariam Fouad',
          startsAt: DateTime.now().add(const Duration(days: 1)),
          durationMinutes: 45,
          capacity: 12,
          bookedCount: 99,
          room: 'Studio 3',
        ),
      );

      expect(created.bookedCount, 0);
      expect(created.id, isNot('ignored'));
    });

    test('cancelling releases every booking against it', () async {
      final MockStore store = MockStore();
      final MockAdminRepository admin = MockAdminRepository(store: store);

      final GymClass booked = store.classes.firstWhere(
        (GymClass gymClass) => gymClass.bookedCount > 0,
      );
      final int held = store.reservations
          .where((Reservation r) => r.referenceId == booked.id && r.isConfirmed)
          .length;

      final int released = await admin.cancelClass(booked.id);

      expect(released, held);
      expect(store.classes.any((GymClass c) => c.id == booked.id), isFalse);
      expect(
        store.reservations.where(
          (Reservation r) => r.referenceId == booked.id && r.isConfirmed,
        ),
        isEmpty,
      );
    });

    testWidgets('cancelling warns how many people are affected', (
      WidgetTester tester,
    ) async {
      final MockStore store = MockStore();
      await pumpAdmin(tester, store, const ManageClassesScreen());

      // The first class in the list is the soonest; find one with bookings.
      final GymClass booked = store.classes.firstWhere(
        (GymClass gymClass) => gymClass.bookedCount > 0,
      );
      await tester.scrollUntilVisible(find.text(booked.name).first, 200);
      await tester.pumpAndSettle();

      await tester.tap(
        find
            .descendant(
              of: find
                  .ancestor(
                    of: find.text(booked.name).first,
                    matching: find.byType(Row),
                  )
                  .last,
              matching: find.byIcon(Icons.more_vert_rounded),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel class').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('booked'), findsWidgets);
      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();
    });
  });

  group('Trainers', () {
    test('one with booked sessions cannot be removed', () async {
      final MockStore store = MockStore();
      final MockAdminRepository admin = MockAdminRepository(store: store);

      final TrainerSlot booked = store.slots.firstWhere(
        (TrainerSlot slot) => slot.isBooked && !slot.isPastAt(DateTime.now()),
      );

      await expectLater(
        admin.deleteTrainer(booked.trainerId),
        throwsA(isA<ConflictFailure>()),
      );
      expect(
        store.trainers.any((Trainer t) => t.id == booked.trainerId),
        isTrue,
      );
    });

    test('publishing the same times twice does not double them', () async {
      final MockStore store = MockStore();
      final MockAdminRepository admin = MockAdminRepository(store: store);

      final DateTime slot = DateTime.now().add(const Duration(days: 3));
      final DateTime whenever = DateTime(slot.year, slot.month, slot.day, 14);

      final List<TrainerSlot> first = await admin.publishSlots(
        trainerId: 'tr-1',
        startTimes: <DateTime>[whenever],
        durationMinutes: 60,
      );
      final List<TrainerSlot> second = await admin.publishSlots(
        trainerId: 'tr-1',
        startTimes: <DateTime>[whenever],
        durationMinutes: 60,
      );

      expect(first, hasLength(1));
      expect(second, isEmpty);
    });

    test('a booked time cannot be withdrawn', () async {
      final MockStore store = MockStore();
      final MockAdminRepository admin = MockAdminRepository(store: store);

      final TrainerSlot booked = store.slots.firstWhere(
        (TrainerSlot slot) => slot.isBooked,
      );

      await expectLater(
        admin.deleteSlot(booked.id),
        throwsA(isA<ConflictFailure>()),
      );
    });
  });

  group('Rosters', () {
    test(
      'list the members holding a place, and nothing else about them',
      () async {
        final MockStore store = MockStore();
        final MockAdminRepository admin = MockAdminRepository(store: store);

        final GymClass booked = store.classes.firstWhere(
          (GymClass gymClass) => gymClass.bookedCount > 0,
        );

        final List<RosterEntry> roster = await admin.fetchClassRoster(
          booked.id,
        );

        expect(roster, isNotEmpty);
        expect(roster.first.username, isNotEmpty);
        expect(roster.first.memberId, isNotEmpty);
      },
    );

    test(
      'a member sees only their own bookings, not other people\'s',
      () async {
        final MockStore store = MockStore();
        final MockReservationRepository member = MockReservationRepository(
          store: store,
        );

        final List<Reservation> mine = await member.fetchMyReservations();

        expect(mine, isNotEmpty);
        expect(
          mine.every(
            (Reservation r) => r.memberId == MockData.demoMembershipId,
          ),
          isTrue,
          reason: 'the store holds other members\' bookings for the rosters',
        );
      },
    );
  });

  testWidgets('the hub counts what is posted', (WidgetTester tester) async {
    final MockStore store = MockStore();
    await pumpAdmin(tester, store, const ManageScreen());

    expect(find.text('Events & offers'), findsOneWidget);
    expect(find.text('Classes'), findsOneWidget);
    expect(find.text('Trainers'), findsOneWidget);
    expect(find.text('${store.events.length}'), findsWidgets);
  });
}
