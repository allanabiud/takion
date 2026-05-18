import 'package:flutter/material.dart';

class PageNavigationBar extends StatelessWidget {
  const PageNavigationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    this.onPrevious,
    this.onNext,
    this.enabled = true,
    this.isLoading = false,
  });

  final int currentPage;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canGoPrevious = enabled && !isLoading && hasPrevious;
    final canGoNext = enabled && !isLoading && hasNext;

    return SizedBox(
      width: double.infinity,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: canGoPrevious ? onPrevious : null,
                    tooltip: 'Previous page',
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Row(
                        key: ValueKey('${currentPage}_$isLoading'),
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading) ...[
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Page $currentPage',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'of $totalPages',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: canGoNext ? onNext : null,
                    tooltip: 'Next page',
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              if (isLoading) ...[
                const SizedBox(height: 8),
                const SizedBox(
                  width: double.infinity,
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
