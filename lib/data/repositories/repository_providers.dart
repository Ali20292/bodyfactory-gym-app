import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/session_store.dart';
import '../mock/mock_store.dart';
import 'account_repository.dart';
import 'admin_repository.dart';
import 'admin_repository_mock.dart';
import 'account_repository_mock.dart';
import 'auth_repository.dart';
import 'auth_repository_mock.dart';
import 'calendar_repository.dart';
import 'calendar_repository_mock.dart';
import 'gym_repository.dart';
import 'gym_repository_mock.dart';
import 'reservation_repository.dart';
import 'reservation_repository_mock.dart';

/// The dummy-to-real swap lives here and nowhere else.
///
/// Every provider below returns an **abstract** repository type. No widget and
/// no controller may import a `_mock` or `_api` class directly — they depend
/// only on the interface, which is what makes flipping `USE_MOCK_DATA` a
/// configuration change rather than a rewrite.
///
/// The API implementations arrive in build-order step 13. Until then the false
/// branch fails loudly rather than silently serving fake data from what looks
/// like a real backend.
Never _notYetImplemented(String className) => throw UnimplementedError(
  '$className lands in build-order step 13. '
  'Run with USE_MOCK_DATA=true until then.',
);

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) {
      if (!AppConfig.useMockData) _notYetImplemented('ApiAuthRepository');

      final MockAuthRepository repository = MockAuthRepository(
        store: ref.watch(sessionStoreProvider),
        data: ref.watch(mockStoreProvider),
      );
      ref.onDispose(repository.dispose);
      return repository;
    });

final Provider<GymRepository> gymRepositoryProvider = Provider<GymRepository>((
  Ref ref,
) {
  if (!AppConfig.useMockData) _notYetImplemented('ApiGymRepository');
  return MockGymRepository(store: ref.watch(mockStoreProvider));
});

final Provider<ReservationRepository> reservationRepositoryProvider =
    Provider<ReservationRepository>((Ref ref) {
      if (!AppConfig.useMockData) {
        _notYetImplemented('ApiReservationRepository');
      }
      return MockReservationRepository(store: ref.watch(mockStoreProvider));
    });

/// Staff writes.
///
/// Reached only from the Manage tab, which only appears for
/// [MemberRole.staff] — but that is a UI decision, not a security one. The
/// server authorizes every call. See [AdminRepository].
final Provider<AdminRepository> adminRepositoryProvider =
    Provider<AdminRepository>((Ref ref) {
      if (!AppConfig.useMockData) _notYetImplemented('ApiAdminRepository');
      return MockAdminRepository(store: ref.watch(mockStoreProvider));
    });

final Provider<CalendarRepository> calendarRepositoryProvider =
    Provider<CalendarRepository>((Ref ref) {
      if (!AppConfig.useMockData) _notYetImplemented('ApiCalendarRepository');
      return MockCalendarRepository();
    });

final Provider<AccountRepository> accountRepositoryProvider =
    Provider<AccountRepository>((Ref ref) {
      if (!AppConfig.useMockData) _notYetImplemented('ApiAccountRepository');
      return MockAccountRepository(store: ref.watch(mockStoreProvider));
    });
