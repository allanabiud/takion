import 'package:flutter/material.dart';

class AsyncStatePanel extends StatelessWidget {
  const AsyncStatePanel.loading({
    super.key,
    this.message,
    this.padding = const EdgeInsets.all(24),
  }) : title = null,
       errorMessage = null,
       onRetry = null,
       retryLabel = 'Retry',
       icon = null,
       _isLoading = true;

  const AsyncStatePanel.error({
    super.key,
    required this.errorMessage,
    this.title,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.error_outline,
    this.padding = const EdgeInsets.all(24),
  }) : message = null,
       _isLoading = false;

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
                    errorMessage ?? 'Something went wrong.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    FilledButton(
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