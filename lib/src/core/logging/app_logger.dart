import "package:takion/src/core/logging/talker_setup.dart";

/// Sanitizes sensitive information (tokens, authorization headers, passwords) from logs.
class LogSanitizer {
  static final RegExp _bearerRegex = RegExp(
    r"Bearer\s+([A-Za-z0-9_\-\.]+)",
    caseSensitive: false,
  );
  static final RegExp _authHeaderRegex = RegExp(
    r"Authorization:\s*([^,\n\r]+)",
    caseSensitive: false,
  );
  static final RegExp _passwordRegex = RegExp(
    r'"password"\s*:\s*"([^"]+)"',
    caseSensitive: false,
  );
  static final RegExp _tokenParamRegex = RegExp(
    r"([?&]token=)([^&]+)",
    caseSensitive: false,
  );

  static String sanitize(String message) {
    var result = message;
    result = result.replaceAllMapped(_bearerRegex, (m) => "Bearer [REDACTED]");
    result = result.replaceAllMapped(
      _authHeaderRegex,
      (m) => "Authorization: [REDACTED]",
    );
    result = result.replaceAllMapped(
      _passwordRegex,
      (m) => '"password":"[REDACTED]"',
    );
    result = result.replaceAllMapped(
      _tokenParamRegex,
      (m) => "${m.group(1)}[REDACTED]",
    );
    return result;
  }
}

class AppLogger {
  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    talker.info(LogSanitizer.sanitize(message), error, stackTrace);
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    talker.warning(LogSanitizer.sanitize(message), error, stackTrace);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    talker.error(LogSanitizer.sanitize(message), error, stackTrace);
  }

  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    talker.debug(LogSanitizer.sanitize(message), error, stackTrace);
  }

  static void verbose(String message, {Object? error, StackTrace? stackTrace}) {
    talker.verbose(LogSanitizer.sanitize(message), error, stackTrace);
  }
}
