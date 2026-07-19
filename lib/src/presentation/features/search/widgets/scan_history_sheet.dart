import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/search/providers/barcode_scan_providers.dart';

Future<void> showScanHistorySheet(
  BuildContext context,
  WidgetRef ref, {
  required Future<void> Function(String upc) onSelectUpc,
}) async {
  final history = ref.read(scanHistoryProvider);

  if (history.isEmpty) {
    TakionAlerts.info(context, 'No scan history yet');
    return;
  }

  TakionBottomSheet.show<void>(
    context: context,
    title: 'Scan History',
    child: Consumer(
      builder: (context, ref, _) {
        final entries = ref.watch(scanHistoryProvider);

        if (entries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No scan history yet.')),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: entries.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Dismissible(
              key: ValueKey('${entry.upc}_${entry.scannedAt.millisecondsSinceEpoch}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              onDismissed: (_) {
                ref.read(scanHistoryProvider.notifier).removeEntryAt(index);
              },
              child: ListTile(
                title: Text(
                  entry.issueName ?? entry.upc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      entry.upc,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      DateFormatter.relativeShort(entry.scannedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onSelectUpc(entry.upc);
                },
              ),
            );
          },
        );
      },
    ),
  );
}

