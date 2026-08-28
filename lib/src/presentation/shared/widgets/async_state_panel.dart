import "package:flutter/material.dart";
import "package:takion/src/core/errors/app_failure.dart";

class AsyncStatePanel extends StatelessWidget {
  const AsyncStatePanel.loading({
    super.key,
    this.message,
    this.padding = const EdgeInsets.all(24),
  }) : title = null,
       errorMessage = null,
       onRetry = null,
       retryLabel = "Retry",
       icon = null,
       _isLoading = true;

  const AsyncStatePanel.error({
    super.key,
    required this.errorMessage,
    this.title,
    this.onRetry,
    this.retryLabel = "Retry",
    this.icon = Icons.error_outline,
    this.padding = const EdgeInsets.all(24),
  }) : message = null,
       _isLoading = false;

  factory AsyncStatePanel.fromFailure({
    Key? key,
    required AppFailure failure,
    VoidCallback? onRetry,
    VoidCallback? onAction,
    String? actionLabel,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
  }) {
    IconData icon;
    String title;
    String? customAction = actionLabel;
    final VoidCallback? customCallback = onAction ?? onRetry;

    switch (failure) {
      case NetworkFailure():
        icon = Icons.wifi_off_outlined;
        title = "No Connection";
        customAction ??= "Retry";
      case AuthFailure():
        icon = Icons.lock_outline;
        title = failure.isExpired ? "Session Expired" : "Authentication Required";
        customAction ??= "Log In";
      case RateLimitFailure():
        icon = Icons.speed_outlined;
        title = "Rate Limit Reached";
        customAction ??= "Retry";
      case ServerFailure(:final statusCode):
        icon = Icons.cloud_off_outlined;
        title = "Server Error ($statusCode)";
        customAction ??= "Retry";
      case NotFoundFailure():
        icon = Icons.search_off_outlined;
        title = "Not Found";
        customAction ??= "Back";
      case DriveQuotaFailure():
        icon = Icons.disc_full_outlined;
        title = "Drive Full";
        customAction = null;
      case DriveAuthFailure():
        icon = Icons.account_circle_outlined;
        title = "Drive Authentication";
        customAction ??= "Sign In";
      case CacheFailure():
        icon = Icons.storage_outlined;
        title = "Cache Error";
        customAction ??= "Retry";
      case ValidationFailure():
        icon = Icons.rule_outlined;
        title = "Invalid Request";
        customAction = null;
      case UnknownFailure():
        icon = Icons.error_outline;
        title = "Something went wrong";
        customAction ??= "Retry";
    }

    return AsyncStatePanel.error(
      key: key,
      title: title,
      errorMessage: failure.userMessage,
      icon: icon,
      onRetry: customCallback,
      retryLabel: customAction ?? "Retry",
      padding: padding,
    );
  }

  final bool _isLoading;
  final String? message;
  final String? title;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: _isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (title != null) ...[
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    errorMessage ?? "Something went wrong.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    FilledButton(onPressed: onRetry, child: Text(retryLabel)),
                  ],
                ],
              ),
      ),
    );
  }
}
