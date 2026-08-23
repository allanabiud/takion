import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:takion/src/presentation/features/onboarding/widgets/onboarding_page_scaffold.dart";

class RestoreBackupPage extends StatelessWidget {
  const RestoreBackupPage({
    super.key,
    required this.restoreCompleted,
    required this.isDriveRestoring,
    required this.isLocalRestoring,
    required this.onLocalRestore,
    required this.onDriveRestore,
    required this.onContinue,
  });

  final bool restoreCompleted;
  final bool isDriveRestoring;
  final bool isLocalRestoring;
  final VoidCallback onLocalRestore;
  final VoidCallback onDriveRestore;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnboardingPageScaffold(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          restoreCompleted ? LucideIcons.badgeCheck : LucideIcons.rotateCcw,
          key: ValueKey(restoreCompleted),
          size: 48,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        restoreCompleted ? "Backup Restored" : "Restore from Backup",
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: restoreCompleted
          ? "Your data has been restored successfully."
          : "If you have a previous Takion backup, you can restore your data now.",
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!restoreCompleted && !isDriveRestoring && !isLocalRestoring)
            Column(
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.tonalIcon(
                    onPressed: onLocalRestore,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text("Restore from Local File"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.tonalIcon(
                    onPressed: onDriveRestore,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text("Restore from Google Drive"),
                  ),
                ),
              ],
            ),
          if (isDriveRestoring)
            const Column(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                SizedBox(height: 16),
                Text("Restoring from Google Drive..."),
              ],
            ),
          if (isLocalRestoring)
            const Column(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                SizedBox(height: 16),
                Text("Restoring from local file..."),
              ],
            ),
        ],
      ),
      buttons: [
        if (restoreCompleted)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: onContinue,
              child: const Text("Continue"),
            ),
          )
        else if (!isDriveRestoring && !isLocalRestoring)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: onContinue,
              child: const Text("Skip"),
            ),
          ),
      ],
    );
  }
}
