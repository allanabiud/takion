import "package:flutter/material.dart";
import "package:takion/src/presentation/shared/alerts/takion_flash.dart";

class TakionAlerts {
  const TakionAlerts._();

  static void info(BuildContext context, String message) {
    TakionFlash.info(context, message);
  }

  static void success(BuildContext context, String message) {
    TakionFlash.success(context, message);
  }

  static void error(BuildContext context, String message) {
    TakionFlash.error(context, message);
  }

  static void successWithUndo(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onUndo,
    IconData? icon,
  }) {
    TakionFlash.show(
      context: context,
      message: message,
      icon: icon ?? Icons.check_circle,
      color: Theme.of(context).colorScheme.primary,
      actionLabel: actionLabel,
      onAction: onUndo,
    );
  }

  static void infoWithUndo(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onUndo,
    IconData? icon,
  }) {
    TakionFlash.show(
      context: context,
      message: message,
      icon: icon ?? Icons.info_outline,
      color: Theme.of(context).colorScheme.primary,
      actionLabel: actionLabel,
      onAction: onUndo,
    );
  }

  static void comingSoon(
    BuildContext context,
    String feature, {
    String? scope,
  }) {
    final scopeText = scope == null || scope.trim().isEmpty
        ? ""
        : " ${scope.trim()}";
    info(context, "$feature$scopeText coming soon");
  }

  static void noShareUrl(BuildContext context, String resource) {
    info(context, "No share URL for this $resource");
  }

  static void noBrowserUrl(BuildContext context, String resource) {
    info(context, "No browser URL for this $resource");
  }

  static void couldNotOpenInBrowser(BuildContext context, String resource) {
    error(context, "Could not open this $resource");
  }

  static void signupLaunchFailed(BuildContext context) {
    error(context, "Could not open signup page");
  }

  static void authLoginSuccess(BuildContext context) {
    success(context, "Logged In");
  }

  static void authLogoutSuccess(BuildContext context) {
    info(context, "Logged Out");
  }

  static void authMissingCredentials(BuildContext context) {
    info(context, "Enter email and password");
  }

  static String cleanError(
    Object? error, {
    String fallback = "Something went wrong",
  }) {
    final raw = error?.toString().trim() ?? "";
    var cleaned = raw
        .replaceFirst(
          RegExp(
            r"^(Exception|StateError|DioException|PlatformException|FormatException"
            r"|HttpException|ArgumentError|TypeError|RangeError|TimeoutException"
            r"|BadStateError|ConcurrentModificationError): ",
          ),
          "",
        )
        .trim();

    if (cleaned.isEmpty ||
        cleaned.length > 120 ||
        cleaned.contains("file://") ||
        cleaned.contains("package:") ||
        cleaned.contains("dart:")) {
      cleaned = fallback;
    }

    return cleaned;
  }

  static void safeError(
    BuildContext context,
    Object? error, {
    String? userMessage,
  }) {
    TakionAlerts.error(
      context,
      cleanError(error, fallback: userMessage ?? "Something went wrong"),
    );
  }

  static void authError(BuildContext context, Object error) {
    final raw = error.toString().trim();
    final cleaned = raw
        .replaceFirst("Exception: ", "")
        .replaceFirst("AuthFlowException: ", "")
        .trim();

    TakionAlerts.error(
      context,
      cleaned.isEmpty ? "Authentication failed" : cleaned,
    );
  }

  static void libraryAddedToCollection(BuildContext context) {
    success(context, "Added to Collection");
  }

  static void libraryMarkedAsRead(BuildContext context) {
    success(context, "Marked as Read");
  }

  static void libraryUpdated(BuildContext context) {
    success(context, "Library Updated");
  }

  static void noLinkedSeriesForIssue(BuildContext context) {
    info(context, "No linked series");
  }
}
