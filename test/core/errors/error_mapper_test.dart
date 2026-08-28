import "dart:io";
import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/errors/app_failure.dart";
import "package:takion/src/core/errors/error_mapper.dart";

void main() {
  group("ErrorMapper", () {
    test("maps connection timeout DioException to NetworkFailure", () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: "/api/issue/"),
        type: DioExceptionType.connectionTimeout,
      );

      final failure = ErrorMapper.fromException(dioException);
      expect(failure, isA<NetworkFailure>());
      expect(failure.userMessage, contains("Network connection issue"));
    });

    test("maps 401 response to AuthFailure", () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: "/api/issue/"),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: "/api/issue/"),
          statusCode: 401,
        ),
      );

      final failure = ErrorMapper.fromException(dioException);
      expect(failure, isA<AuthFailure>());
      expect(failure.userMessage, contains("Authentication failed"));
    });

    test("maps 429 response to RateLimitFailure", () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: "/api/issue/"),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: "/api/issue/"),
          statusCode: 429,
        ),
      );

      final failure = ErrorMapper.fromException(dioException);
      expect(failure, isA<RateLimitFailure>());
      expect(failure.userMessage, contains("Rate limit exceeded"));
    });

    test("maps 404 response to NotFoundFailure", () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: "/api/issue/999/"),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: "/api/issue/999/"),
          statusCode: 404,
        ),
      );

      final failure = ErrorMapper.fromException(dioException);
      expect(failure, isA<NotFoundFailure>());
      expect(failure.userMessage, contains("not found"));
    });

    test("maps 500 response to ServerFailure", () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: "/api/issue/"),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: "/api/issue/"),
          statusCode: 500,
        ),
      );

      final failure = ErrorMapper.fromException(dioException);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
      expect(failure.userMessage, contains("Server error (500)"));
    });

    test("maps SocketException to NetworkFailure", () {
      const socketException = SocketException("Failed to host lookup");
      final failure = ErrorMapper.fromException(socketException);
      expect(failure, isA<NetworkFailure>());
    });

    test("maps FormatException to ValidationFailure", () {
      const formatException = FormatException("Invalid JSON payload");
      final failure = ErrorMapper.fromException(formatException);
      expect(failure, isA<ValidationFailure>());
    });

    test("passes through existing AppFailure", () {
      const existingFailure = DriveQuotaFailure();
      final failure = ErrorMapper.fromException(existingFailure);
      expect(failure, isA<DriveQuotaFailure>());
    });
  });
}
