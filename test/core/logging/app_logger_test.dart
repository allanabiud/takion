import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/logging/app_logger.dart";

void main() {
  group("LogSanitizer", () {
    test("redacts Bearer tokens", () {
      final input = "Request with Bearer abc123secret_token.xyz";
      final result = LogSanitizer.sanitize(input);
      expect(result, equals("Request with Bearer [REDACTED]"));
    });

    test("redacts Authorization headers", () {
      final input = "Headers: Authorization: Basic dXNlcjpwYXNz, Content-Type: json";
      final result = LogSanitizer.sanitize(input);
      expect(result, equals("Headers: Authorization: [REDACTED], Content-Type: json"));
    });

    test("redacts password fields in json payloads", () {
      final input = 'User payload: {"email": "user@test.com", "password": "supersecretpassword123"}';
      final result = LogSanitizer.sanitize(input);
      expect(result, equals('User payload: {"email": "user@test.com", "password":"[REDACTED]"}'));
    });

    test("redacts token query parameters", () {
      final input = "GET https://api.metron.cloud/endpoint?token=my_secret_token&limit=20";
      final result = LogSanitizer.sanitize(input);
      expect(result, equals("GET https://api.metron.cloud/endpoint?token=[REDACTED]&limit=20"));
    });
  });
}
