// A design tool, not a check.
//
// Renders Home to a PNG with the real bundled fonts, so a layout or colour
// change can be looked at without waiting on a device:
//
//   flutter test --update-goldens test/features/home/home_snapshot.dart
//
// Deliberately named without the `_test` suffix so `flutter test` does not
// pick it up: a golden that has to match byte-for-byte would fail on any
// machine whose text rendering differs, which is a maintenance cost with no
// return. The images land in `snapshots/` for eyeballing, and nothing asserts
// against them. Icons render as empty boxes here — the Material Icons font is
// not part of the bundle a test loads — which is a limitation of the harness,
// not of the screen.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/storage/session_store.dart';
import 'package:gym_app/core/theme/app_theme.dart';
import 'package:gym_app/data/models/models.dart';
import 'package:gym_app/data/repositories/gym_repository.dart';
import 'package:gym_app/data/repositories/repository_providers.dart';
import 'package:gym_app/features/home/screens/home_screen.dart';

class SnapshotGymRepository implements GymRepository {
  SnapshotGymRepository(this.capacity, this.events);

  final GymCapacity capacity;
  final List<GymEvent> events;

  @override
  Future<GymCapacity> fetchCapacity() async => capacity;

  @override
  Future<List<GymEvent>> fetchEvents() async => events;

  @override
  void debugForceLevel(OccupancyLevel? level) {}
}

Future<void> loadBundledFonts() async {
  for (final MapEntry<String, String> font in <String, String>{
    'Jost': 'assets/fonts/Jost-Variable.ttf',
    'Oswald': 'assets/fonts/Oswald-Variable.ttf',
  }.entries) {
    final Uint8List bytes = await File(font.value).readAsBytes();
    await (FontLoader(
      font.key,
    )..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)))).load();
  }
}

void main() {
  setUpAll(loadBundledFonts);

  testWidgets('renders Home', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(780, 1688);
    addTearDown(tester.view.reset);

    final DateTime today = DateTime.now();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
          gymRepositoryProvider.overrideWithValue(
            SnapshotGymRepository(
              GymCapacity(
                currentOccupancy: 96,
                maxCapacity: 120,
                updatedAt: today.subtract(const Duration(minutes: 2)),
              ),
              <GymEvent>[
                GymEvent(
                  id: 'ev-1',
                  title: 'Deadlift technique workshop',
                  description:
                      'Two hours with Coach Karim on setup, bracing, and '
                      'lockout. Fifteen places, first come first served.',
                  startsAt: today.add(const Duration(days: 2, hours: 19)),
                  endsAt: today.add(const Duration(days: 2, hours: 21)),
                  type: GymEventType.event,
                ),
                GymEvent(
                  id: 'of-1',
                  title: '20% off personal training packs',
                  description:
                      'Ten-session packs with any trainer, this month only. '
                      'Ask at the front desk to redeem.',
                  startsAt: today.add(const Duration(days: 3)),
                  endsAt: today.add(const Duration(days: 24)),
                  type: GymEventType.offer,
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp(theme: AppTheme.brand, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('snapshots/home.png'),
    );
  });

  testWidgets('renders Home under the tab bar, packed and empty', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(780, 1688);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
          gymRepositoryProvider.overrideWithValue(
            SnapshotGymRepository(
              GymCapacity(
                currentOccupancy: 117,
                maxCapacity: 120,
                updatedAt: DateTime.now(),
              ),
              const <GymEvent>[],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.brand,
          home: Scaffold(
            body: const HomeScreen(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (int _) {},
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_available_outlined),
                  label: 'Reservations',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Account',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('snapshots/home_packed_empty.png'),
    );
  });
}
