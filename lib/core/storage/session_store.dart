import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/models/models.dart';

/// Where the logged-in session lives.
///
/// One place, one rule: session tokens go to the platform keystore and nowhere
/// else. Never `shared_preferences`, never a plain file, never app state that
/// gets serialised for debugging.
abstract class SessionStore {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}

/// Keychain on iOS, EncryptedSharedPreferences on Android.
class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // Android encryption is handled by the plugin's own ciphers now;
            // the old EncryptedSharedPreferences flag is deprecated and
            // ignored.
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  static const String _key = 'auth_session';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthSession?> read() async {
    final String? raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // A payload we can no longer parse is worthless and possibly stale.
      // Drop it rather than leaving the user in a half-restored state.
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(AuthSession session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// Non-persistent store for tests and widget tests, which have no keystore.
class InMemorySessionStore implements SessionStore {
  AuthSession? _session;

  @override
  Future<AuthSession?> read() async => _session;

  @override
  Future<void> write(AuthSession session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
}

final Provider<SessionStore> sessionStoreProvider = Provider<SessionStore>(
  (Ref ref) => SecureSessionStore(),
);
