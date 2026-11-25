import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/repository_providers.dart';

/// The session every screen treats as ground truth. Null means logged out.
///
/// The first value is one read from secure storage (`restoreSession`); every
/// value after that comes from `watchSession`, so an explicit logout and a
/// token expiring mid-session both flow through here and out to the router's
/// redirect — never through a widget calling `context.go` by hand.
final StreamProvider<AuthSession?> authSessionProvider =
    StreamProvider<AuthSession?>((Ref ref) async* {
      final AuthRepository repository = ref.watch(authRepositoryProvider);
      yield await repository.restoreSession();
      yield* repository.watchSession();
    });
