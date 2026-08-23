import "package:flutter/material.dart";

class _DelayCurve extends Curve {
  final double delayFraction;
  const _DelayCurve(this.delayFraction);

  @override
  double transformInternal(double t) {
    if (t <= delayFraction) return 0;
    final adjusted = (t - delayFraction) / (1 - delayFraction);
    return Curves.easeOutCubic.transform(adjusted);
  }
}

Widget _animateIn({required double delayFraction, required Widget child}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 500),
    curve: _DelayCurve(delayFraction),
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - value)),
        child: child,
      ),
    ),
    child: child,
  );
}

/// Shared chrome for each onboarding page (icon, title, subtitle, content,
/// and bottom action buttons), with the stagger-in animation.
class OnboardingPageScaffold extends StatelessWidget {
  const OnboardingPageScaffold({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.content,
    required this.buttons,
  });

  final Widget icon;
  final Widget title;
  final String? subtitle;
  final Widget content;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: icon,
          ),
          const SizedBox(height: 12),
          _animateIn(delayFraction: 0.12, child: title),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            _animateIn(
              delayFraction: 0.22,
              child: Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else
            const SizedBox(height: 24),
          Expanded(child: _animateIn(delayFraction: 0.35, child: content)),
          const SizedBox(height: 16),
          _animateIn(
            delayFraction: 0.45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buttons,
            ),
          ),
        ],
      ),
    );
  }
}

/// The 5-segment progress bar shown above the onboarding pages.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: index <= currentPage
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
