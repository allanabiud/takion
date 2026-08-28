import "dart:io";
import "package:dio/dio.dart";
import "package:takion/src/core/errors/app_failure.dart";

/// Central error mapper converting network, transport, and unexpected exceptions into typed [AppFailure]s.
class ErrorMapper {
  ErrorMapper._();

  static AppFailure fromException(Object error, [StackTrace? stackTrace]) {
    if (error is AppFailure) {
      return error;
    }

    if (error is DioException) {
      return fromDioException(error);
    }

    if (error is SocketException || error is HttpException) {
      return NetworkFailure(error.toString());
    }

    if (error is FormatException) {
      return ValidationFailure(error.message);
    }

    return UnknownFailure(error.toString(), stackTrace);
  }

  static AppFailure fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return NetworkFailure(error.message ?? "Connection error");

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        if (statusCode == 401 || statusCode == 403) {
          return const AuthFailure();
        }
        if (statusCode == 404) {
          return const NotFoundFailure("Resource");
        }
        if (statusCode == 429) {
          return const RateLimitFailure();
        }
        if (statusCode >= 400 && statusCode < 500) {
          return ValidationFailure(error.message ?? "Bad request");
        }
        return ServerFailure(statusCode);

      case DioExceptionType.cancel:
        return const NetworkFailure("Request cancelled");

      case DioExceptionType.badCertificate:
        return const NetworkFailure("SSL certificate error");

      case DioExceptionType.unknown:
        if (error.error is SocketException || error.error is HttpException) {
          return NetworkFailure(error.error.toString());
        }
        return UnknownFailure(
          error.message ?? error.toString(),
          error.stackTrace,
        );
    }
  }
}
