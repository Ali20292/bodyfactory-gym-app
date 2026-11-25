import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/storage/session_store.dart';
import 'package:gym_app/core/theme/app_theme.dart';
import 'package:gym_app/data/models/models.dart';
import 'package:gym_app/data/repositories/gym_repository.dart';
import 'package:gym_app/data/repositories/repository_providers.dart';
import 'package:gym_app/features/home/screens/home_screen.dart';
import 'package:gym_app/features/home/widgets/event_card.dart';
import 'package:gym_app/features/home/widgets/events_empty.dart';

/// Counts its calls so the tests can assert *when* the screen asks for data,
/// which is the whole point of the polling rules.
class FakeGymRepository implements GymRepository {
  FakeGymRepository({required this.capacity, this.events = const <GymEvent>[]});

  GymCapacity capacity;
  List<GymEvent> events;

  int capacityCalls = 0;
  int eventCalls = 0;
  OccupancyLevel? forcedLevel;

  @override
  Future<GymCapacity> fetchCapacity() async {
    capacityCalls++;
    return capacity;
  }

  @override
  Future<List<GymEvent>> fetchEvents() async {
    eventCalls++;
    return events;
  }

  @override
  void debugForceLevel(OccupancyLevel? level) => forcedLevel = level;
}

GymCapacity capacityOf(int occupancy) => GymCapacity(
  currentOccupancy: occupancy,
  maxCapacity: 120,
  updatedAt: DateTime.now(),
);

GymEvent eventAt(String id, {required GymEventType type}) => GymEvent(
  id: id,
  title: 'Deadlift workshop $id',
  description: 'Two hours on setup, bracing, and lockout.',
  startsAt: DateTime.now().add(const Duration(days: 2)),
  endsAt: DateTime.now().add(const Duration(days: 3)),
  type: type,
);

Future<void> pumpHome(
  WidgetTester tester,
  FakeGymRepository repository, {
  Size size = const Size(390, 844),
  bool visible = true,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
        gymRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.brand,
        // Mirrors what the tab shell does to a branch it is keeping alive off
        // screen, which is how the screen knows to stop polling.
        home: TickerMode(enabled: visible, child: const HomeScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the percentage, the level, and the raw count', (
    WidgetTester tester,
  ) async {
    // 41 of 120 is 34% — the worked example from CLAUDE.md, and Quiet under
    // the colour bands.
    await pumpHome(tester, FakeGymRepository(capacity: capacityOf(41)));

    expect(find.text('34%', findRichText: true), findsOneWidget);
    expect(find.text('Quiet'), findsOneWidget);
    expect(find.text('41 of 120 members in the gym'), findsOneWidget);
    expect(find.textContaining('Updated'), findsOneWidget);
  });

  testWidgets('reports over-capacity honestly without overflowing the bar', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester, FakeGymRepository(capacity: capacityOf(130)));

    expect(find.text('108%', findRichText: true), findsOneWidget);
    expect(find.text('Packed'), findsOneWidget);
  });

  testWidgets('lands each occupancy on the band the spec gives it', (
    WidgetTester tester,
  ) async {
    for (final (int occupancy, String label) in <(int, String)>[
      (47, 'Quiet'), // last of the green band
      (48, 'Moderate'), // first of the amber band
      (83, 'Moderate'),
      (84, 'Busy'),
      (107, 'Busy'),
      (108, 'Packed'),
    ]) {
      await pumpHome(
        tester,
        FakeGymRepository(capacity: capacityOf(occupancy)),
      );
      expect(find.text(label), findsOneWidget, reason: '$occupancy is $label');
    }
  });

  testWidgets('lists events and offers, badged apart', (
    WidgetTester tester,
  ) async {
    await pumpHome(
      tester,
      FakeGymRepository(
        capacity: capacityOf(41),
        events: <GymEvent>[
          eventAt('ev-1', type: GymEventType.event),
          eventAt('of-1', type: GymEventType.offer),
        ],
      ),
    );

    expect(find.byType(EventsEmpty), findsNothing);
    expect(find.text('Event'), findsOneWidget);

    // The list is lazy, so the second card only exists once it is scrolled
    // into view — which is the behaviour we want on a list that will grow.
    await tester.scrollUntilVisible(find.text('Offer'), 240);
    expect(find.text('Offer'), findsOneWidget);
    expect(find.byType(EventCard), findsWidgets);
  });

  testWidgets('shows the empty state when nothing is on', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester, FakeGymRepository(capacity: capacityOf(41)));

    expect(find.byType(EventsEmpty), findsOneWidget);
    expect(find.text('No upcoming events right now'), findsOneWidget);
  });

  testWidgets('re-reads capacity every minute while the tab is visible', (
    WidgetTester tester,
  ) async {
    final FakeGymRepository repository = FakeGymRepository(
      capacity: capacityOf(41),
    );
    await pumpHome(tester, repository);
    expect(repository.capacityCalls, 1);

    repository.capacity = capacityOf(96);
    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();

    expect(repository.capacityCalls, 2);
    expect(find.text('80%', findRichText: true), findsOneWidget);
    expect(find.text('Busy'), findsOneWidget);
  });

  testWidgets('does not poll while the tab is off screen', (
    WidgetTester tester,
  ) async {
    final FakeGymRepository repository = FakeGymRepository(
      capacity: capacityOf(41),
    );
    await pumpHome(tester, repository, visible: false);

    // The first read still happens — the branch was built — but nothing after
    // it, because a timer left running here is the leak the spec calls out.
    expect(repository.capacityCalls, 1);

    await tester.pump(const Duration(minutes: 5));
    await tester.pumpAndSettle();

    expect(repository.capacityCalls, 1);
  });

  testWidgets('pull to refresh re-reads both sections', (
    WidgetTester tester,
  ) async {
    final FakeGymRepository repository = FakeGymRepository(
      capacity: capacityOf(41),
    );
    await pumpHome(tester, repository);

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 320),
      800,
    );
    await tester.pumpAndSettle();

    expect(repository.capacityCalls, 2);
    expect(repository.eventCalls, 2);
  });

  testWidgets('long-pressing the bar cycles the level in a debug build', (
    WidgetTester tester,
  ) async {
    final FakeGymRepository repository = FakeGymRepository(
      capacity: capacityOf(41),
    );
    await pumpHome(tester, repository);

    await tester.longPress(find.text('41 of 120 members in the gym'));
    await tester.pumpAndSettle();

    expect(repository.forcedLevel, OccupancyLevel.quiet);
  });

  testWidgets('lays out on a small phone without overflowing', (
    WidgetTester tester,
  ) async {
    await pumpHome(
      tester,
      FakeGymRepository(
        capacity: capacityOf(108),
        events: <GymEvent>[eventAt('ev-1', type: GymEventType.event)],
      ),
      size: const Size(320, 640),
    );

    expect(find.text('90%', findRichText: true), findsOneWidget);
  });
}
