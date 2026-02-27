import 'package:flutter/material.dart';
import 'package:takion/src/presentation/widgets/takion_flash.dart';

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

  static void comingSoon(
    BuildContext context,
    String feature, {
    String? scope,
  }) {
    final scopeText = scope == null || scope.trim().isEmpty
        ? ''
        : ' ${scope.trim()}';
    info(context, '$feature$scopeText coming soon.');
  }

  static void noShareUrl(BuildContext context, String resource) {
    info(context, 'No share URL available for this $resource.');
  }

  static void noBrowserUrl(BuildContext context, String resource) {
    info(context, 'No browser URL available for this $resource.');
  }

  static void couldNotOpenInBrowser(BuildContext context, String resource) {
    error(context, 'Could not open this $resource in browser.');
  }

  static void signupLaunchFailed(BuildContext context) {
    error(context, 'Could not launch signup page.');
  }

  static void authLoginSuccess(BuildContext context) {
    success(context, 'Successfully logged in.');
  }

  static void authLogoutSuccess(BuildContext context) {
    info(context, 'Logged out successfully.');
  }

  static void authMissingCredentials(BuildContext context) {
    info(context, 'Please enter both email and password.');
  }

  static void authError(BuildContext context, Object error) {
    final raw = error.toString().trim();
    final cleaned = raw
        .replaceFirst('Exception: ', '')
        .replaceFirst('AuthFlowException: ', '')
        .trim();

    TakionAlerts.error(
      context,
      cleaned.isEmpty ? 'Authentication failed. Please try again.' : cleaned,
    );
  }

  static void libraryAddedToCollection(BuildContext context) {
    success(context, 'Added to Collection.');
  }

  static void libraryMarkedAsRead(BuildContext context) {
    success(context, 'Marked as Read.');
  }

  static void libraryUpdated(BuildContext context) {
    success(context, 'Library updated.');
  }

  static void noLinkedSeriesForIssue(BuildContext context) {
    info(context, 'No series is linked to this issue.');
  }
}