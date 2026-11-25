import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/config/app_config.dart';
import 'package:gym_app/core/storage/session_store.dart';
import 'package:gym_app/data/mock/mock_data.dart';
import 'package:gym_app/features/splash/controllers/app_boot_controller.dart';

void main() {
  /// Boots the real app with a session store that has no keystore behind it.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
        ],
        child: const GymApp(),
      ),
    );
  }

  /// Waits out the splash hold and lets the redirect settle.
  Future<void> settleBoot(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(splashHold + const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  /// Drains a mock repository's artificial latency.
  ///
  /// `pumpAndSettle` alone is not enough: nothing schedules a frame while the
  /// repository's `Future.delayed` is in flight, so it returns early and
  /// leaves the timer pending. Time has to be advanced explicitly.
  Future<void> settleMockCall(WidgetTester tester) async {
    await tester.pump(AppConfig.mockLatency + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
  }

  testWidgets('holds on the splash, then lands on Login when signed out', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.pump();
    expect(find.text('GYM'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);

    await settleBoot(tester);

    expect(find.text('GYM'), findsNothing);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('shows inline errors, not a snackbar, for empty fields', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await settleBoot(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your membership ID.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets(
    'rejects bad credentials without revealing whether the ID exists',
    (WidgetTester tester) async {
      await pumpApp(tester);
      await settleBoot(tester);

      await tester.enterText(find.byType(TextField).first, 'GM-9999');
      await tester.enterText(find.byType(TextField).last, 'wrong-password');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await settleMockCall(tester);

      expect(find.text('Incorrect membership ID or password.'), findsOneWidget);
      // Still on Login.
      expect(find.text('Welcome back'), findsOneWidget);
    },
  );

  testWidgets('a successful log in redirects to Home without the screen '
      'navigating', (WidgetTester tester) async {
    await pumpApp(tester);
    await settleBoot(tester);

    await tester.enterText(
      find.byType(TextField).first,
      MockData.demoMembershipId,
    );
    await tester.enterText(find.byType(TextField).last, MockData.demoPassword);
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));

    // The button disables and shows its spinner while in flight.
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await settleMockCall(tester);

    expect(find.text('Welcome back'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
