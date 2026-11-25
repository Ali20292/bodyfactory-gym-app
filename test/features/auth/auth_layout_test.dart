import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/storage/session_store.dart';
import 'package:gym_app/data/models/models.dart';
import 'package:gym_app/features/auth/screens/login_screen.dart';
import 'package:gym_app/features/auth/screens/otp_screen.dart';
import 'package:gym_app/features/auth/screens/sign_up_screen.dart';
import 'package:gym_app/features/splash/screens/splash_screen.dart';

/// Phone widths worth proving: the tightest common device, a normal one, and
/// the size the flow tests drive.
const List<Size> _screens = <Size>[
  Size(320, 800),
  Size(390, 940),
  Size(420, 940),
];

void useScreen(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Future<void> pump(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // A RenderFlex overflow raises a FlutterError, which fails the test on its
  // own — pumping at each size is the assertion.
  for (final Size size in _screens) {
    testWidgets('splash fits ${size.width.toInt()}px wide', (
      WidgetTester tester,
    ) async {
      useScreen(tester, size);
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SplashScreen())),
      );
      // Step through the whole animation; the wordmark is widest at the end.
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }

      expect(find.text('GYM'), findsOneWidget);
    });

    testWidgets('login fits ${size.width.toInt()}px wide', (
      WidgetTester tester,
    ) async {
      useScreen(tester, size);
      await pump(tester, const LoginScreen());

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('sign up fits ${size.width.toInt()}px wide', (
      WidgetTester tester,
    ) async {
      useScreen(tester, size);
      await pump(tester, const SignUpScreen());

      expect(find.text('Create your account'), findsOneWidget);
    });

    testWidgets('otp fits ${size.width.toInt()}px wide', (
      WidgetTester tester,
    ) async {
      useScreen(tester, size);
      await pump(
        tester,
        OtpScreen(
          challenge: SignUpChallenge(
            challengeId: 'chg-1',
            maskedPhone: '+20 1** *** 4471',
            expiresAt: DateTime.now().add(const Duration(minutes: 5)),
            attemptsRemaining: 5,
          ),
        ),
      );

      expect(find.text('Verify your number'), findsOneWidget);
    });
  }
}
