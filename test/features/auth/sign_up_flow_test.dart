import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/config/app_config.dart';
import 'package:gym_app/core/storage/session_store.dart';
import 'package:gym_app/data/mock/mock_data.dart';
import 'package:gym_app/features/splash/controllers/app_boot_controller.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    // The default 800x600 test surface is shorter than a phone, which pushes
    // the sign-up button off-screen and makes taps miss. Use a phone shape.
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
  }

  /// Scrolls a control into view before tapping it. The auth screens scroll,
  /// so a control can be present but outside the viewport.
  Future<void> tapControl(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  Future<void> settleBoot(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(splashHold + const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  /// Drains a mock repository's artificial latency, which `pumpAndSettle`
  /// alone leaves pending because nothing schedules a frame while it runs.
  Future<void> settleMockCall(WidgetTester tester) async {
    await tester.pump(AppConfig.mockLatency + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
  }

  /// Login → Sign up.
  Future<void> goToSignUp(WidgetTester tester) async {
    await pumpApp(tester);
    await settleBoot(tester);
    await tapControl(tester, find.widgetWithText(TextButton, 'Sign up'));
    await tester.pumpAndSettle();
  }

  Future<void> fillSignUp(
    WidgetTester tester, {
    required String membershipId,
    String username = 'newmember',
    String password = 'password123',
    String? confirm,
  }) async {
    final Finder fields = find.byType(TextField);
    await tester.enterText(fields.at(0), username);
    await tester.enterText(fields.at(1), membershipId);
    await tester.enterText(fields.at(2), password);
    await tester.enterText(fields.at(3), confirm ?? password);
    await tester.pump();
  }

  group('Sign up', () {
    testWidgets('reaches the form from Login', (WidgetTester tester) async {
      await goToSignUp(tester);

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
    });

    testWidgets('validates inline before ever calling the backend', (
      WidgetTester tester,
    ) async {
      await goToSignUp(tester);

      await tapControl(tester, find.widgetWithText(FilledButton, 'Send code'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a username.'), findsOneWidget);
      expect(find.text('Enter your membership ID.'), findsOneWidget);
      expect(find.text('Choose a password.'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('catches mismatched passwords', (WidgetTester tester) async {
      await goToSignUp(tester);
      await fillSignUp(
        tester,
        membershipId: MockData.signUpReadyMembershipId,
        confirm: 'password124',
      );

      await tapControl(tester, find.widgetWithText(FilledButton, 'Send code'));
      await tester.pumpAndSettle();

      expect(find.text('Both passwords must match.'), findsOneWidget);
    });

    testWidgets('rejects a weak password with a specific reason', (
      WidgetTester tester,
    ) async {
      await goToSignUp(tester);
      await fillSignUp(
        tester,
        membershipId: MockData.signUpReadyMembershipId,
        password: 'lettersonly',
      );

      await tapControl(tester, find.widgetWithText(FilledButton, 'Send code'));
      await tester.pumpAndSettle();

      expect(
        find.text('Include at least one letter and one number.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'blurs an unknown ID and an already-registered one into one message',
      (WidgetTester tester) async {
        // Unknown to the gym.
        await goToSignUp(tester);
        await fillSignUp(tester, membershipId: 'GM-9999');
        await tapControl(
          tester,
          find.widgetWithText(FilledButton, 'Send code'),
        );
        await settleMockCall(tester);

        expect(
          find.textContaining('front desk'),
          findsOneWidget,
          reason: 'unknown ID should get the generic message',
        );

        // Known, but already has an account.
        await tester.enterText(
          find.byType(TextField).at(1),
          MockData.demoMembershipId,
        );
        await tester.pump();
        await tapControl(
          tester,
          find.widgetWithText(FilledButton, 'Send code'),
        );
        await settleMockCall(tester);

        // Identical wording — nothing distinguishes the two cases.
        expect(find.textContaining('front desk'), findsOneWidget);
      },
    );

    testWidgets('a usable ID moves on to OTP showing the masked number', (
      WidgetTester tester,
    ) async {
      await goToSignUp(tester);
      await fillSignUp(tester, membershipId: MockData.signUpReadyMembershipId);

      await tapControl(tester, find.widgetWithText(FilledButton, 'Send code'));
      await settleMockCall(tester);

      expect(find.text('Verify your number'), findsOneWidget);
      expect(
        find.textContaining(MockData.demoMaskedPhone),
        findsOneWidget,
        reason: 'the user needs to know which phone to check',
      );
    });
  });

  group('OTP', () {
    Future<void> goToOtp(WidgetTester tester) async {
      await goToSignUp(tester);
      await fillSignUp(tester, membershipId: MockData.signUpReadyMembershipId);
      await tapControl(tester, find.widgetWithText(FilledButton, 'Send code'));
      await settleMockCall(tester);
    }

    testWidgets('holds resend behind a countdown', (WidgetTester tester) async {
      await goToOtp(tester);

      expect(
        find.textContaining('You can request a new code in'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Resend code'), findsNothing);
    });

    testWidgets('a wrong code clears the boxes and counts down attempts', (
      WidgetTester tester,
    ) async {
      await goToOtp(tester);

      await tester.enterText(find.byType(TextField), '000000');
      await settleMockCall(tester);

      expect(find.textContaining('4 tries left'), findsOneWidget);
      // Boxes emptied, ready for another go.
      expect(find.text('0'), findsNothing);
    });

    testWidgets('locks the challenge after five wrong codes', (
      WidgetTester tester,
    ) async {
      await goToOtp(tester);

      for (int attempt = 0; attempt < 5; attempt++) {
        await tester.enterText(find.byType(TextField), '000000');
        await settleMockCall(tester);
      }

      expect(find.textContaining('Too many incorrect codes'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Start again'), findsOneWidget);
    });

    testWidgets('the right code creates the account and returns to Login', (
      WidgetTester tester,
    ) async {
      await goToOtp(tester);

      await tester.enterText(find.byType(TextField), MockData.demoOtpCode);
      await settleMockCall(tester);

      expect(find.text('Account created'), findsOneWidget);

      await tapControl(tester, find.widgetWithText(TextButton, 'Go to log in'));
      await tester.pumpAndSettle();

      // Back at Login, and not signed in — verifying a phone does not hand
      // out a session.
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('warns before abandoning a code that is in flight', (
      WidgetTester tester,
    ) async {
      await goToOtp(tester);

      // `pumpAndSettle` cannot be used from here on: the resend countdown is
      // a one-second periodic timer, so the frame queue never empties and
      // settling times out. Explicit pumps advance past the dialog animation
      // instead.
      Future<void> pumpDialog() async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      }

      await tester.tap(find.byType(BackButton));
      await pumpDialog();
      expect(find.text('Leave verification?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Stay'));
      await pumpDialog();
      expect(find.text('Verify your number'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await pumpDialog();
      await tester.tap(find.widgetWithText(TextButton, 'Leave'));
      await pumpDialog();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Create your account'), findsOneWidget);
    });
  });
}
