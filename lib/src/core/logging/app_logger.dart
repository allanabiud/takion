import 'package:takion/src/core/logging/talker_setup.dart';

class AppLogger {
  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    talker.info(message, error, stackTrace);
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    talker.warning(message, error, stackTrace);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    talker.error(message, error, stackTrace);
  }

  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    talker.debug(message, error, stackTrace);
  }

  static void verbose(String message, {Object? error, StackTrace? stackTrace}) {
    talker.verbose(message, error, stackTrace);
  }
}
