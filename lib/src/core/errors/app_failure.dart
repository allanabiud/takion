/// Base class for typed application failures across network, cache, auth, and sync boundaries.
sealed class AppFailure {
  const AppFailure();

  String get userMessage;
}

class NetworkFailure extends AppFailure {
  final String message;
  const NetworkFailure(this.message);

  @override
  String get userMessage =>
      "Network connection issue. Please check your internet connection.";
}

class AuthFailure extends AppFailure {
  final bool isExpired;
  const AuthFailure({this.isExpired = false});

  @override
  String get userMessage => isExpired
      ? "Your session has expired. Please re-authenticate."
      : "Authentication failed. Please check your credentials.";
}

class RateLimitFailure extends AppFailure {
  final int remaining;
  final DateTime? resetAt;
  const RateLimitFailure({this.remaining = 0, this.resetAt});

  @override
  String get userMessage =>
      "Rate limit exceeded. Please wait a moment before trying again.";
}

class ValidationFailure extends AppFailure {
  final String message;
  const ValidationFailure(this.message);

  @override
  String get userMessage =>
      message.isNotEmpty ? message : "Invalid request data.";
}

class NotFoundFailure extends AppFailure {
  final String resourceType;
  final int? resourceId;
  const NotFoundFailure(this.resourceType, [this.resourceId]);

  @override
  String get userMessage => resourceId != null
      ? "$resourceType #$resourceId was not found."
      : "$resourceType was not found.";
}

class ServerFailure extends AppFailure {
  final int statusCode;
  const ServerFailure(this.statusCode);

  @override
  String get userMessage =>
      "Server error ($statusCode). Please try again later.";
}

class CacheFailure extends AppFailure {
  final String message;
  const CacheFailure(this.message);

  @override
  String get userMessage => "Unable to load cached data.";
}

class DriveAuthFailure extends AppFailure {
  const DriveAuthFailure();

  @override
  String get userMessage =>
      "Google Drive authentication failed. Please sign in again.";
}

class DriveQuotaFailure extends AppFailure {
  const DriveQuotaFailure();

  @override
  String get userMessage => "Google Drive storage quota exceeded.";
}

class UnknownFailure extends AppFailure {
  final String message;
  final StackTrace? stackTrace;
  const UnknownFailure(this.message, [this.stackTrace]);

  @override
  String get userMessage => "An unexpected error occurred.";
}
