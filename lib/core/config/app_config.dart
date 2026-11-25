/// Runtime configuration, resolved at compile time.
///
/// Values come from `--dart-define-from-file=.env` (see `.env.example`). Every
/// key falls back to a sane default so the app still builds and runs on mock
/// data when no file is supplied:
///
/// ```
/// flutter run --dart-define-from-file=.env
/// ```
///
/// Nothing here is secret. Every value is baked into the binary and is
/// extractable from the APK/IPA — see the Security section of CLAUDE.md. No
/// database credentials, no admin keys, no SMS provider secrets.
class AppConfig {
  const AppConfig._();

  /// True in a `flutter build --release` binary.
  static const bool isRelease = bool.fromEnvironment('dart.vm.product');

  /// Master switch for the data layer. True means every repository serves
  /// in-memory dummy data and the app opens no sockets at all.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );

  /// Backend API root. Ignored while [useMockData] is true.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  static const Duration connectTimeout = Duration(
    milliseconds: int.fromEnvironment(
      'API_CONNECT_TIMEOUT_MS',
      defaultValue: 10000,
    ),
  );

  static const Duration receiveTimeout = Duration(
    milliseconds: int.fromEnvironment(
      'API_RECEIVE_TIMEOUT_MS',
      defaultValue: 15000,
    ),
  );

  static const String _appEnvRaw = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static AppEnv get appEnv => switch (_appEnvRaw) {
    'prod' => AppEnv.prod,
    'staging' => AppEnv.staging,
    _ => AppEnv.dev,
  };

  static const bool _enableHttpLoggingRaw = bool.fromEnvironment(
    'ENABLE_HTTP_LOGGING',
    defaultValue: true,
  );

  /// Verbose HTTP logging. Forced off in release builds regardless of the
  /// configured value — request bodies carry passwords and OTP codes.
  static bool get enableHttpLogging => !isRelease && _enableHttpLoggingRaw;

  /// Debug-only affordances, such as long-pressing the capacity bar to cycle
  /// through occupancy levels. Never available in a release build.
  static bool get enableDevTools => !isRelease && appEnv == AppEnv.dev;

  /// How often the Home tab re-polls the capacity endpoint while visible.
  static const Duration capacityRefreshInterval = Duration(
    seconds: int.fromEnvironment(
      'CAPACITY_REFRESH_INTERVAL_SECONDS',
      defaultValue: 60,
    ),
  );

  /// Used by the mock repository, and as a display fallback if an API response
  /// arrives without `maxCapacity`. The backend value is authoritative.
  static const int maxOccupancyFallback = int.fromEnvironment(
    'GYM_MAX_OCCUPANCY_FALLBACK',
    defaultValue: 120,
  );

  /// How long after check-in a member is assumed to still be in the gym.
  /// Mirrors the backend's `SESSION_WINDOW_MINUTES`; the mock repository
  /// applies the same window so it exercises the real code path.
  static const Duration sessionWindow = Duration(
    minutes: int.fromEnvironment('SESSION_WINDOW_MINUTES', defaultValue: 75),
  );

  static const int otpLength = int.fromEnvironment(
    'OTP_LENGTH',
    defaultValue: 6,
  );

  static const Duration otpResendCooldown = Duration(
    seconds: int.fromEnvironment(
      'OTP_RESEND_COOLDOWN_SECONDS',
      defaultValue: 60,
    ),
  );

  static const String _sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Null when crash reporting is disabled.
  static String? get sentryDsn => _sentryDsn.isEmpty ? null : _sentryDsn;

  /// Artificial latency the mock repositories wait before returning, so
  /// loading states are visible and actually get built.
  static const Duration mockLatency = Duration(milliseconds: 600);
}

enum AppEnv { dev, staging, prod }
