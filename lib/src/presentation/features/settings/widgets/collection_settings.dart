import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';

void showCollectionSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Library',
    child: Consumer(
      builder: (context, ref, _) {
        final formatAsync = ref.watch(collectionDefaultFormatProvider);
        final selected = formatAsync.maybeWhen(
          data: (value) => value,
          orElse: () => CollectionDefaultFormat.print,
        );

        return buildSettingsGroup(context, 'Library Defaults', [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Default format',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Applied when adding new collection items',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RadioGroup<CollectionDefaultFormat>(
            groupValue: selected,
            onChanged: (value) {
              if (formatAsync.isLoading || value == null) return;
              ref
                  .read(collectionDefaultFormatProvider.notifier)
                  .setDefaultFormat(value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<CollectionDefaultFormat>(
                  value: CollectionDefaultFormat.digital,
                  title: const Text('Digital'),
                  contentPadding: EdgeInsets.zero,
                  enabled: !formatAsync.isLoading,
                ),
                RadioListTile<CollectionDefaultFormat>(
                  value: CollectionDefaultFormat.print,
                  title: const Text('Print'),
                  contentPadding: EdgeInsets.zero,
                  enabled: !formatAsync.isLoading,
                ),
                RadioListTile<CollectionDefaultFormat>(
                  value: CollectionDefaultFormat.both,
                  title: const Text('Both'),
                  contentPadding: EdgeInsets.zero,
                  enabled: !formatAsync.isLoading,
                ),
              ],
            ),
          ),
          const Divider(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Auto-Collect on Read',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Automatically add to collection when marked as read',
            ),
            value: ref.watch(autoCollectOnReadProvider).value ?? false,
            onChanged: (v) =>
                ref.read(autoCollectOnReadProvider.notifier).setEnabled(v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Auto-Pull to Collection',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Automatically move released pull list items to owned collection',
            ),
            value: ref.watch(autoPullToCollectionProvider).value ?? false,
            onChanged: (v) =>
                ref.read(autoPullToCollectionProvider.notifier).setEnabled(v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Read Tick Overlay on Cards',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Show a checkmark overlay on issue covers when marked as read',
            ),
            value: ref.watch(showReadIssueTickOverlayProvider).value ?? false,
            onChanged: (v) => ref
                .read(showReadIssueTickOverlayProvider.notifier)
                .setEnabled(v),
          ),
        ]);
      },
    ),
  );
}
