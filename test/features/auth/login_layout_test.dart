import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/storage/session_store.dart';
import 'package:gym_app/features/auth/screens/login_screen.dart';

/// Sizes the surface in logical pixels and restores it afterwards.
void useScreen(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Future<void> pumpLogin(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
      ],
      child: const MaterialApp(home: LoginScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // A RenderFlex overflow raises a FlutterError, which fails the test on its
  // own — no assertion needed beyond pumping at each size.
  testWidgets('lays out on a small phone without overflowing', (
    WidgetTester tester,
  ) async {
    useScreen(tester, const Size(320, 640)); // iPhone SE, the tightest case
    await pumpLogin(tester);

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('lays out on a normal phone', (WidgetTester tester) async {
    useScreen(tester, const Size(390, 844));
    await pumpLogin(tester);

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('caps and centres the form on a tablet', (
    WidgetTester tester,
  ) async {
    const double screenWidth = 900;
    useScreen(tester, const Size(screenWidth, 1200));
    await pumpLogin(tester);

    final Rect button = tester.getRect(
      find.widgetWithText(FilledButton, 'Log in'),
    );

    // Capped, not stretched across the tablet. Mirrors _maxFormWidth in
    // auth_scaffold.dart.
    expect(button.width, lessThanOrEqualTo(440));
    // Centred: equal gutters either side.
    expect(button.left, closeTo(screenWidth - button.right, 1.0));
  });

  testWidgets('stays reachable when the keyboard covers most of the screen', (
    WidgetTester tester,
  ) async {
    useScreen(tester, const Size(390, 400)); // keyboard up
    await pumpLogin(tester);

    // The body scrolls rather than overflowing.
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
  });
}
