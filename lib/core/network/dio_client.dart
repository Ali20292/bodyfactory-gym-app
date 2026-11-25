import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/failures.dart';

/// The single [Dio] instance the API repositories share.
///
/// Nothing here knows about the database — the app speaks HTTP to the backend
/// and the backend owns every query. Auth token attachment is wired in with
/// the auth feature (build order step 13); the interceptor hook is below.
final Provider<Dio> dioClientProvider = Provider<Dio>((Ref ref) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.connectTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      // Let the interceptor classify status codes instead of Dio throwing on
      // every non-2xx, so error bodies survive long enough to be mapped.
      validateStatus: (int? status) => status != null && status < 500,
    ),
  );

  if (AppConfig.enableHttpLogging) {
    dio.interceptors.add(
      LogInterceptor(
        // Request bodies carry passwords and OTP codes. Headers carry bearer
        // tokens. Neither is ever logged, in any build.
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (Object object) => debugPrint('[http] $object'),
      ),
    );
  }

  ref.onDispose(dio.close);
  return dio;
});

/// Translates transport-level errors into the [Failure] type the UI knows.
///
/// Every API repository funnels its calls through this so a `DioException`
/// never escapes the data layer.
class DioFailureMapper {
  const DioFailureMapper._();

  static Failure map(Object error) {
    if (error is! DioException) return const UnknownFailure();

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.cancel => const UnknownFailure('Request cancelled.'),
      DioExceptionType.badCertificate => const NetworkFailure(
        'Could not establish a secure connection.',
      ),
      DioExceptionType.badResponse ||
      DioExceptionType.unknown => fromStatus(error.response?.statusCode),
    };
  }

  /// Maps an HTTP status code to a [Failure]. Public because repositories use
  /// `validateStatus` and therefore inspect successful-but-non-2xx responses
  /// themselves.
  static Failure fromStatus(int? status) => switch (status) {
    400 || 422 => const ValidationFailure('Please check the details entered.'),
    401 || 403 => const AuthFailure(),
    404 => const NotFoundFailure(),
    409 => const ConflictFailure(),
    429 => const RateLimitFailure(),
    _ when status != null && status >= 500 => const ServerFailure(),
    _ => const UnknownFailure(),
  };
}
