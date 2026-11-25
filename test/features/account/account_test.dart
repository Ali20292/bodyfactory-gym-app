import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/errors/failures.dart';
import 'package:gym_app/core/theme/app_theme.dart';
import 'package:gym_app/data/models/models.dart';
import 'package:gym_app/data/repositories/account_repository.dart';
import 'package:gym_app/data/repositories/repository_providers.dart';
import 'package:gym_app/features/account/controllers/account_controller.dart';
import 'package:gym_app/features/account/screens/account_screen.dart';
import 'package:gym_app/features/account/screens/edit_username_screen.dart';
import 'package:gym_app/features/account/screens/invitations_screen.dart';
import 'package:gym_app/features/account/services/profile_image_service.dart';
import 'package:gym_app/features/account/widgets/profile_avatar.dart';
import 'package:image/image.dart' as img;

class FakeAccountRepository implements AccountRepository {
  FakeAccountRepository({Member? member, List<InvitationUsage>? history})
    : member = member ?? demoMember(),
      history = history ?? <InvitationUsage>[];

  Member member;
  List<InvitationUsage> history;

  /// Usernames the "server" refuses, so the rollback path is reachable.
  Set<String> taken = <String>{'admin'};

  Uint8List? uploadedBytes;
  String? uploadedFileName;

  @override
  Future<Member> fetchProfile() async => member;

  @override
  Future<Member> updateUsername(String username) async {
    final String trimmed = username.trim();
    if (taken.contains(trimmed.toLowerCase())) {
      throw const ValidationFailure(
        'That username is taken.',
        fieldErrors: <String, String>{'username': 'That username is taken.'},
      );
    }
    member = member.copyWith(username: trimmed);
    return member;
  }

  @override
  Future<Member> updateProfileImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    uploadedBytes = bytes;
    uploadedFileName = fileName;
    member = member.copyWith(profileImageUrl: 'https://example.test/new.jpg');
    return member;
  }

  @override
  Future<List<InvitationUsage>> fetchInvitationHistory() async => history;
}

/// Hands back a picture without touching a plugin — there is no method
/// channel in a widget test.
class FakeImageSource implements ProfileImageSource {
  FakeImageSource({this.image, this.fileName = 'IMG_0042.HEIC'});

  final Uint8List? image;
  final String fileName;

  int pickCalls = 0;

  @override
  Future<PickedImage?> pick(PhotoOrigin origin) async {
    pickCalls++;
    final Uint8List? bytes = image;
    if (bytes == null) return null;
    return PickedImage(bytes: bytes, fileName: fileName);
  }
}

Member demoMember() => Member(
  id: 'GM-1001',
  username: 'yasser',
  phoneMasked: '+20 1** *** 4471',
  membershipTier: 'Standard',
  membershipExpiry: DateTime.now().add(const Duration(days: 200)),
  invitationsRemaining: 3,
);

/// A real, decodable photo — wider than tall, so the centre crop has
/// something to prove.
Uint8List wideTestPhoto({int width = 1200, int height = 600}) {
  final img.Image image = img.Image(width: width, height: height);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      image.setPixelRgb(x, y, x % 256, y % 256, (x + y) % 256);
    }
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 100));
}

Future<void> pumpAccount(
  WidgetTester tester,
  FakeAccountRepository repository, {
  Widget screen = const AccountScreen(),
  ProfileImageSource? imageSource,
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        accountRepositoryProvider.overrideWithValue(repository),
        if (imageSource != null)
          profileImageSourceProvider.overrideWithValue(imageSource),
      ],
      child: MaterialApp(theme: AppTheme.brand, home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pumps a screen behind a real [GoRouter].
///
/// Edit Username pops itself on success, and `context.pop` needs a router in
/// the tree — a bare `MaterialApp(home:)` throws "No GoRouter found in
/// context", which is exactly the bug this catches if the screen ever loses
/// its route.
Future<void> pumpRouted(
  WidgetTester tester,
  FakeAccountRepository repository,
  Widget screen,
) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);

  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.push('/edit'),
              child: const Text('Go'),
            ),
          ),
        ),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            builder: (BuildContext context, GoRouterState state) => screen,
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        accountRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(theme: AppTheme.brand, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Go'));
  await tester.pumpAndSettle();
}

void main() {
  group('Profile', () {
    testWidgets('shows the name, membership ID and invitations left', (
      WidgetTester tester,
    ) async {
      await pumpAccount(tester, FakeAccountRepository());

      expect(find.text('yasser'), findsOneWidget);
      expect(find.text('Member GM-1001'), findsOneWidget);
      expect(find.text('Guest invitations'), findsOneWidget);
      expect(find.text('3 left on your membership'), findsOneWidget);
    });

    testWidgets('falls back to initials when there is no picture', (
      WidgetTester tester,
    ) async {
      await pumpAccount(tester, FakeAccountRepository());

      // "yasser" is one word, so one initial.
      expect(find.text('Y'), findsOneWidget);
    });
  });

  group('Username', () {
    testWidgets('saving a new one updates the profile', (
      WidgetTester tester,
    ) async {
      final FakeAccountRepository repository = FakeAccountRepository();
      await pumpRouted(tester, repository, const EditUsernameScreen());

      await tester.enterText(find.byType(TextField), 'yasser-lifts');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repository.member.username, 'yasser-lifts');
    });

    testWidgets('a taken name is rejected with the reason under the field', (
      WidgetTester tester,
    ) async {
      final FakeAccountRepository repository = FakeAccountRepository();
      await pumpRouted(tester, repository, const EditUsernameScreen());

      await tester.enterText(find.byType(TextField), 'admin');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('That username is taken.'), findsOneWidget);
      expect(repository.member.username, 'yasser');
    });

    testWidgets('too short is caught before it reaches the server', (
      WidgetTester tester,
    ) async {
      final FakeAccountRepository repository = FakeAccountRepository();
      await pumpRouted(tester, repository, const EditUsernameScreen());

      await tester.enterText(find.byType(TextField), 'ab');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Use between 3 and 30 characters.'), findsOneWidget);
      expect(repository.member.username, 'yasser');
    });

    test('a rejected name is rolled back, not left on screen', () async {
      final FakeAccountRepository repository = FakeAccountRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          accountRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(profileProvider.future);

      final String? error = await container
          .read(profileProvider.notifier)
          .updateUsername('admin');

      expect(error, 'That username is taken.');
      // The optimistic write put "admin" on screen for a moment; what matters
      // is that it did not stay there.
      expect(container.read(profileProvider).requireValue.username, 'yasser');
    });
  });

  group('Profile picture', () {
    testWidgets('picking one crops, compresses and uploads it', (
      WidgetTester tester,
    ) async {
      final FakeAccountRepository repository = FakeAccountRepository();
      final FakeImageSource source = FakeImageSource(image: wideTestPhoto());

      await pumpAccount(tester, repository, imageSource: source);

      await tester.tap(find.byType(ProfileAvatar));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from photos'));
      await tester.pump();

      // Not `pumpAndSettle`, for two reasons: the avatar shows a spinner while
      // the upload runs, so the frame loop never goes quiet, and the crop runs
      // on a real isolate via `compute`, which needs real time rather than the
      // test's fake clock.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 2)),
      );
      await tester.pump();

      expect(source.pickCalls, 1);

      final Uint8List? uploaded = repository.uploadedBytes;
      expect(uploaded, isNotNull);
      expect(uploaded!.lengthInBytes, lessThanOrEqualTo(maxProfileImageBytes));

      // Square, whatever went in.
      final img.Image? decoded = img.decodeImage(uploaded);
      expect(decoded!.width, decoded.height);

      // Re-encoded, so the extension has to match what was actually sent.
      expect(repository.uploadedFileName, 'IMG_0042.jpg');
    });

    testWidgets('backing out of the picker changes nothing', (
      WidgetTester tester,
    ) async {
      final FakeAccountRepository repository = FakeAccountRepository();
      final FakeImageSource source = FakeImageSource();

      await pumpAccount(tester, repository, imageSource: source);

      await tester.tap(find.byType(ProfileAvatar));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take a photo'));
      await tester.pumpAndSettle();

      expect(source.pickCalls, 1);
      expect(repository.uploadedBytes, isNull);
    });
  });

  group('prepareProfileImage', () {
    test('centre-crops a wide photo to a square', () {
      final Uint8List? out = prepareProfileImage(wideTestPhoto());
      final img.Image decoded = img.decodeImage(out!)!;

      expect(decoded.width, decoded.height);
      expect(decoded.width, lessThanOrEqualTo(512));
    });

    test('leaves a small picture at its own size', () {
      final Uint8List? out = prepareProfileImage(
        wideTestPhoto(width: 200, height: 200),
      );
      final img.Image decoded = img.decodeImage(out!)!;

      expect(decoded.width, 200);
    });

    test('holds a large photo under the limit', () {
      final Uint8List? out = prepareProfileImage(
        wideTestPhoto(width: 4000, height: 3000),
      );

      expect(out!.lengthInBytes, lessThanOrEqualTo(maxProfileImageBytes));
    });

    test('returns null for bytes that are not an image', () {
      expect(
        prepareProfileImage(Uint8List.fromList(<int>[1, 2, 3, 4, 5])),
        isNull,
      );
    });
  });

  group('Invitations', () {
    testWidgets('lists what is left and where the rest went', (
      WidgetTester tester,
    ) async {
      await pumpAccount(
        tester,
        FakeAccountRepository(
          history: <InvitationUsage>[
            InvitationUsage(
              id: 'inv-1',
              usedAt: DateTime(2026, 7, 3),
              guestName: 'Omar',
            ),
            InvitationUsage(id: 'inv-2', usedAt: DateTime(2026, 6, 1)),
          ],
        ),
        screen: const InvitationsScreen(),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('invitations left'), findsOneWidget);
      expect(find.text('Omar'), findsOneWidget);
      // No name recorded still gets a row rather than being dropped.
      expect(find.text('Guest'), findsOneWidget);
    });
  });

  testWidgets('lays out on a small phone without overflowing', (
    WidgetTester tester,
  ) async {
    await pumpAccount(
      tester,
      FakeAccountRepository(),
      size: const Size(320, 640),
    );

    expect(find.text('yasser'), findsOneWidget);
  });
}
