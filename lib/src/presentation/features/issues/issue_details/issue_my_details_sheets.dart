import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_my_details_provider.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';

Future<void> showEditMyDetailsSheet(
  BuildContext context,
  WidgetRef ref,
  int issueId,
) async {
  ref.invalidate(issueMyDetailsProvider(issueId));
  final detailsAsync = await ref.read(issueMyDetailsProvider(issueId).future);
  if (!context.mounted) return;
  final item = detailsAsync.item;
  final quantityController = TextEditingController(
    text: item != null ? item.quantityOwned.toString() : '',
  );
  final priceController = TextEditingController(
    text: item?.pricePaid?.toStringAsFixed(2) ?? '',
  );
  final conditionController = TextEditingController(
    text: item?.conditionGrade ?? '',
  );
  final notesController = TextEditingController(text: item?.notes ?? '');
  var format = item?.format;
  var purchaseDate = item?.purchaseDate;
  var isEditing = item == null;

  await TakionBottomSheet.show<void>(
    context: context,
    title: 'My Details',
    child: Consumer(
      builder: (context, ref, _) {
        final saveState = ref.watch(issueMyDetailsControllerProvider(issueId));
        return StatefulBuilder(
          builder: (context, setSheetState) {
            if (isEditing) {
              var quantity = int.tryParse(quantityController.text.trim()) ?? 0;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Quantity Owned'),
                        const Spacer(),
                        IconButton(
                          onPressed: saveState.isLoading
                              ? null
                              : () {
                                  quantity--;
                                  quantityController.text = quantity.toString();
                                  setSheetState(() {});
                                },
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            quantity.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: saveState.isLoading
                              ? null
                              : () {
                                  quantity++;
                                  quantityController.text = quantity.toString();
                                  setSheetState(() {});
                                },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: purchaseDate == null
                            ? ''
                            : DateFormatter.comicDate(purchaseDate!),
                      ),
                      onTap: saveState.isLoading
                          ? null
                          : () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: purchaseDate ?? now,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(now.year + 2),
                              );
                              if (picked != null) {
                                setSheetState(() => purchaseDate = picked);
                              }
                            },
                      decoration: const InputDecoration(
                        labelText: 'Purchase Date',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<LibraryItemFormat?>(
                            isExpanded: true,
                            initialValue: format,
                            decoration: const InputDecoration(
                              labelText: 'Format',
                            ),
                            hint: const Text('Select format'),
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text('Not set'),
                              ),
                              DropdownMenuItem(
                                value: LibraryItemFormat.print,
                                child: Text('Print'),
                              ),
                              DropdownMenuItem(
                                value: LibraryItemFormat.digital,
                                child: Text('Digital'),
                              ),
                              DropdownMenuItem(
                                value: LibraryItemFormat.both,
                                child: Text('Both'),
                              ),
                            ],
                            onChanged: saveState.isLoading
                                ? null
                                : (value) =>
                                      setSheetState(() => format = value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: priceController,
                            enabled: !saveState.isLoading,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Price Paid',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: conditionController,
                      enabled: !saveState.isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Condition Grade',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: notesController,
                      enabled: !saveState.isLoading,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: saveState.isLoading
                              ? null
                              : () => setSheetState(() => isEditing = false),
                          child: const Text('Cancel'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: saveState.isLoading
                              ? null
                              : () async {
                                  final ctrl = ref.read(
                                    issueMyDetailsControllerProvider(
                                      issueId,
                                    ).notifier,
                                  );
                                  final qty =
                                      int.tryParse(
                                        quantityController.text.trim(),
                                      ) ??
                                      0;
                                  final price = double.tryParse(
                                    priceController.text.trim(),
                                  );
                                  await ctrl.saveDetails(
                                    isCollected:
                                        qty > 0 ||
                                        price != null ||
                                        purchaseDate != null ||
                                        conditionController.text
                                            .trim()
                                            .isNotEmpty ||
                                        notesController.text.trim().isNotEmpty,
                                    isRead: item?.isRead ?? false,
                                    rating: item?.rating,
                                    purchaseDate: purchaseDate,
                                    pricePaid: price,
                                    quantityOwned: qty < 0 ? 0 : qty,
                                    format: format ?? LibraryItemFormat.print,
                                    conditionGrade:
                                        conditionController.text.trim().isEmpty
                                        ? null
                                        : conditionController.text.trim(),
                                    notes: notesController.text.trim().isEmpty
                                        ? null
                                        : notesController.text.trim(),
                                  );
                                  final s = ref.read(
                                    issueMyDetailsControllerProvider(issueId),
                                  );
                                  if (s.hasError) {
                                    if (context.mounted) {
                                      TakionAlerts.safeError(
                                        context,
                                        s.error,
                                        userMessage: 'Failed to save changes',
                                      );
                                    }
                                    return;
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                          child: saveState.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            final theme = Theme.of(context);
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item != null) ...[
                    _detailTile(
                      icon: Icons.inventory_2_outlined,
                      label: 'Quantity Owned',
                      value: item.quantityOwned.toString(),
                      theme: theme,
                    ),
                    _detailTile(
                      icon: Icons.library_books_outlined,
                      label: 'Format',
                      value:
                          item.format.name[0].toUpperCase() +
                          item.format.name.substring(1),
                      theme: theme,
                    ),
                    if (item.pricePaid != null)
                      _detailTile(
                        icon: Icons.attach_money,
                        label: 'Price Paid',
                        value: '\$${item.pricePaid!.toStringAsFixed(2)}',
                        theme: theme,
                      ),
                    if (item.purchaseDate != null)
                      _detailTile(
                        icon: Icons.calendar_month_outlined,
                        label: 'Purchase Date',
                        value: DateFormatter.comicDate(item.purchaseDate!),
                        theme: theme,
                      ),
                    if (item.conditionGrade != null &&
                        item.conditionGrade!.trim().isNotEmpty)
                      _detailTile(
                        icon: Icons.checklist_outlined,
                        label: 'Condition Grade',
                        value: item.conditionGrade!.trim(),
                        theme: theme,
                      ),
                    if (item.notes != null && item.notes!.trim().isNotEmpty)
                      _detailTile(
                        icon: Icons.notes_outlined,
                        label: 'Notes',
                        value: item.notes!.trim(),
                        theme: theme,
                      ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No details saved yet.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => setSheetState(() => isEditing = true),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}

Widget _detailTile({
  required IconData icon,
  required String label,
  required String value,
  required ThemeData theme,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void showReadingHistorySheet(BuildContext context, WidgetRef ref, int issueId) {
  final theme = Theme.of(context);
  TakionBottomSheet.show<void>(
    context: context,
    title: 'Reading History',
    child: Consumer(
      builder: (context, ref, _) {
        final detailsAsync = ref.watch(issueMyDetailsProvider(issueId));
        return detailsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => Text(
            TakionAlerts.cleanError(e, fallback: 'Something went wrong'),
          ),
          data: (data) {
            final logs = data.readLogs;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (logs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No reading history yet.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final dt = DateFormatter.comicDateTime(log.readAt);
                        return ListTile(
                          title: Text(dt),
                          subtitle: (log.notes?.trim().isNotEmpty ?? false)
                              ? Text(log.notes!.trim())
                              : null,
                          trailing: IconButton(
                            tooltip: 'Delete read log',
                            onPressed: () {
                              ref
                                  .read(
                                    issueMyDetailsControllerProvider(
                                      issueId,
                                    ).notifier,
                                  )
                                  .deleteReadLogById(log.id);
                              ref.invalidate(issueMyDetailsProvider(issueId));
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => showLogReadPicker(context, ref, issueId),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Log Read'),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}

void showLogReadPicker(BuildContext context, WidgetRef ref, int issueId) {
  final now = DateTime.now();
  showDatePicker(
    context: context,
    initialDate: now,
    firstDate: DateTime(1900),
    lastDate: DateTime(now.year + 2),
  ).then((picked) {
    if (picked == null || !context.mounted) return;
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    ).then((time) {
      if (time == null || !context.mounted) return;
      final dt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
      ref
          .read(issueMyDetailsControllerProvider(issueId).notifier)
          .addReadLogAt(dt);
    });
  });
}
