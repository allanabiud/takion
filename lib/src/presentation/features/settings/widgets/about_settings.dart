import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/settings/providers/debug_mode_provider.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/features/settings/widgets/licenses_viewer.dart';

Future<void> launchGitHubRepo(BuildContext context) async {
  final url = Uri.parse('https://github.com/allanabiud/takion');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;
    TakionAlerts.couldNotOpenInBrowser(context, 'repository');
  }
}

void showAboutSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'About',
    child: const _AboutBody(),
  );
}

class _AboutBody extends ConsumerWidget {
  const _AboutBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugEnabled = ref.watch(debugModeProvider).value ?? false;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onLongPress: () async {
                  await ref.read(debugModeProvider.notifier).toggle();
                  final isEnabled = ref.read(debugModeProvider).value ?? false;
                  if (!context.mounted) return;
                  TakionAlerts.info(
                    context,
                    isEnabled ? 'Debug mode enabled' : 'Debug mode disabled',
                  );
                },
                child: SvgPicture.asset(
                  'assets/branding/takion_logo.svg',
                  height: 64,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Takion',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final versionText = snapshot.hasData
                            ? snapshot.data!.buildNumber.isEmpty
                                  ? snapshot.data!.version
                                  : '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                            : '...';
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Version $versionText',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (debugEnabled) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'DEBUG',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => launchGitHubRepo(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.code,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'GitHub Repository',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          buildSettingsGroup(context, 'Developer', [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: const CachedNetworkImageProvider(
                    'https://avatars.githubusercontent.com/u/66108188?s=96&v=4',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'allanabiud',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Creator and maintainer',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      launchUrl(Uri.parse('https://github.com/allanabiud')),
                  icon: const Icon(Icons.open_in_new),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 24),
          buildSettingsGroup(context, 'Legal', [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: const Text(
                'Open Source Licenses',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('View licenses for third-party libraries'),
              onTap: () => showLicensesSheet(context),
            ),
          ]),
        ],
      ),
    );
  }
}
