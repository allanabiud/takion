import "package:flutter/material.dart";
import "package:takion/src/presentation/features/onboarding/widgets/onboarding_page_scaffold.dart";

class AllDonePage extends StatelessWidget {
  const AllDonePage({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: OnboardingPageScaffold(
        icon: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: Transform.rotate(
              angle: (1 - value) * -0.26,
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            ),
          ),
          child: Icon(
            Icons.verified,
            size: 56,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          "All Done!",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle:
            "All set to start discovering, tracking and collecting new comics.",
        content: const SizedBox.shrink(),
        buttons: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: onFinish,
              child: const Text("Finish Setup"),
            ),
          ),
        ],
      ),
    );
  }
}