import "package:flutter/material.dart";
import "package:takion/src/core/errors/app_failure.dart";

class AsyncStatePanel extends StatelessWidget {
  final bool _isLoading;
  final bool _isInline;
  final bool _isError;
  final bool _isEmpty;
  final String? message;
  final String? title;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  const AsyncStatePanel.loading({
    super.key,
    this.message,
    this.padding = const EdgeInsets.all(24),
  }) : title = null,
       errorMessage = null,
       onRetry = null,
       retryLabel = "Retry",
       icon = null,
       _isLoading = true,
       _isInline = false,
       _isError = false,
       _isEmpty = false;

  const AsyncStatePanel.inlineLoading({
    super.key,
    this.message,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : title = null,
       errorMessage = null,
       onRetry = null,
       retryLabel = "Retry",
       icon = null,
       _isLoading = true,
       _isInline = true,
       _isError = false,
       _isEmpty = false;

  const AsyncStatePanel.error({
    super.key,
    required this.errorMessage,
    this.title,
    this.onRetry,
    this.retryLabel = "Retry",
    this.icon = Icons.error_outline,
    this.padding = const EdgeInsets.all(24),
  }) : message = null,
       _isLoading = false,
       _isInline = false,
       _isError = true,
       _isEmpty = false;

  const AsyncStatePanel.staleOffline({
    super.key,
    this.message = "Viewing cached content while offline.",
    this.title = "Offline Mode",
    this.onRetry,
    this.retryLabel = "Refresh",
    this.icon = Icons.cloud_off_outlined,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  }) : errorMessage = message,
       _isLoading = false,
       _isInline = true,
       _isError = false,
       _isEmpty = false;

  const AsyncStatePanel.rateLimitWait({
    super.key,
    required int waitSeconds,
    this.onRetry,
    this.padding = const EdgeInsets.all(24),
  }) : title = "Rate Limit Reached",
       message = null,
       errorMessage = "Please wait $waitSeconds seconds before retrying.",
       retryLabel = "Retry Now",
       icon = Icons.speed_outlined,
       _isLoading = false,
       _isInline = false,
       _isError = false,
       _isEmpty = false;

  const AsyncStatePanel.empty({
    super.key,
    required String message,
    this.title,
    this.icon = Icons.inbox_outlined,
    VoidCallback? onAction,
    String actionLabel = "Explore",
    this.padding = const EdgeInsets.all(24),
  }) : message = null,
       errorMessage = message,
       onRetry = onAction,
       retryLabel = actionLabel,
       _isLoading = false,
       _isInline = false,
       _isError = false,
       _isEmpty = true;

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
        title = failure.isExpired
            ? "Session Expired"
            : "Authentication Required";
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isInline && _isLoading) {
      return Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            if (message != null) ...[
              const SizedBox(width: 12),
              Text(message!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      );
    }

    final Color effectiveIconColor;
    final Color effectiveIconBg;
    if (_isError) {
      effectiveIconColor = theme.colorScheme.error;
      effectiveIconBg = theme.colorScheme.errorContainer.withValues(alpha: 0.4);
    } else if (_isEmpty) {
      effectiveIconColor = theme.colorScheme.primary;
      effectiveIconBg = theme.colorScheme.primaryContainer.withValues(
        alpha: 0.4,
      );
    } else {
      effectiveIconColor = theme.colorScheme.tertiary;
      effectiveIconBg = theme.colorScheme.tertiaryContainer.withValues(
        alpha: 0.4,
      );
    }

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
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: effectiveIconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 36, color: effectiveIconColor),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (title != null) ...[
                    Text(
                      title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    errorMessage ?? "Something went wrong.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: onRetry,
                      child: Text(retryLabel),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
