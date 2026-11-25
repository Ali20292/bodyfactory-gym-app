import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/core/storage/session_store.dart';

void main() {
  testWidgets('app boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          // No keystore in a widget test.
          sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
        ],
        child: const GymApp(),
      ),
    );
    await tester.pump();

    expect(find.text('GYM'), findsOneWidget);

    // Let the brand hold and the redirect finish so no timer outlives the test.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
