import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:takion/src/presentation/features/onboarding/widgets/onboarding_page_scaffold.dart";

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnboardingPageScaffold(
      icon: SvgPicture.asset(
        "assets/branding/takion_logo.svg",
        height: 48,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
      title: Text.rich(
        TextSpan(
          text: "Welcome to ",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          children: [
            TextSpan(
              text: "Takion",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      subtitle:
          "Track your pulls, manage your collection and never miss a release.",
      content: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FeatureCard(
            icon: Icons.shopping_bag_outlined,
            title: "Track Pulls",
            description: "Add comics to your pull list and never miss an issue.",
          ),
          SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.inventory_2_outlined,
            title: "Manage Collection",
            description: "Keep track of every comic you own with ease.",
          ),
          SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.notifications_outlined,
            title: "Release Alerts",
            description: "Get notified when new issues are released.",
          ),
          SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.explore_outlined,
            title: "Discover Comics",
            description: "Browse new releases and explore the catalogue.",
          ),
        ],
      ),
      buttons: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: onNext,
            child: const Text("Get Started"),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}