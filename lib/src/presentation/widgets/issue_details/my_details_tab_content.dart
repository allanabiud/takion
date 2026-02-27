import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/issue_my_details_provider.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';

class IssueMyDetailsTabContent extends ConsumerStatefulWidget {
  const IssueMyDetailsTabContent({
    super.key,
    required this.issueId,
    this.collectionStatus,
  });

  final int issueId;
  final IssueCollectionStatus? collectionStatus;

  @override
  ConsumerState<IssueMyDetailsTabContent> createState() =>
      _IssueMyDetailsTabContentState();
}

class _IssueMyDetailsTabContentState
    extends ConsumerState<IssueMyDetailsTabContent> {
  final _notesController = TextEditingController();
  final _conditionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  DateTime? _purchaseDate;
  LibraryItemFormat _format = LibraryItemFormat.print;
  bool _isCollected = false;
  bool _isRead = false;
  int? _rating;
  bool _hydrated = false;

  DateTime? _initialPurchaseDate;
  LibraryItemFormat _initialFormat = LibraryItemFormat.print;
  String _initialNotes = '';
  String _initialCondition = '';
  String _initialPrice = '';
  String _initialQuantity = '1';

  @override
  void dispose() {
    _notesController.dispose();
    _conditionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _hydrateFromData(IssueMyDetailsData data) {
    if (_hydrated) return;

    final item = data.item;
    _isCollected = item?.ownershipStatus == LibraryOwnershipStatus.owned;
    _isRead = item?.isRead ?? false;
    _rating = item?.rating;
    _purchaseDate = item?.purchaseDate;
    _format = item?.format ?? LibraryItemFormat.print;
    _notesController.text = item?.notes ?? '';
    _conditionController.text = item?.conditionGrade ?? '';
    _priceController.text = item?.pricePaid?.toStringAsFixed(2) ?? '';
    _quantityController.text = '${item?.quantityOwned ?? 1}';

    _initialPurchaseDate = _purchaseDate;
    _initialFormat = _format;
    _initialNotes = _notesController.text;
    _initialCondition = _conditionController.text;
    _initialPrice = _priceController.text;
    _initialQuantity = _quantityController.text;
    _hydrated = true;
  }

  bool _hasChanges() {
    final currentNotes = _notesController.text.trim();
    final currentCondition = _conditionController.text.trim();
    final currentPrice = _priceController.text.trim();
    final currentQuantity = _quantityController.text.trim();

    final initialPurchase = _initialPurchaseDate?.toUtc().toIso8601String();
    final currentPurchase = _purchaseDate?.toUtc().toIso8601String();

    return currentNotes != _initialNotes.trim() ||
        currentCondition != _initialCondition.trim() ||
        currentPrice != _initialPrice.trim() ||
        currentQuantity != _initialQuantity.trim() ||
        _format != _initialFormat ||
        currentPurchase != initialPurchase;
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      _purchaseDate = picked;
    });
  }

  Future<void> _save() async {
    final controller = ref.read(issueMyDetailsControllerProvider(widget.issueId).notifier);
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final price = double.tryParse(_priceController.text.trim());
    final trimmedCondition = _conditionController.text.trim();
    final trimmedNotes = _notesController.text.trim();

    final inferredCollected =
        _isCollected ||
        quantity > 0 ||
        _purchaseDate != null ||
        price != null ||
        trimmedCondition.isNotEmpty ||
        trimmedNotes.isNotEmpty;

    await controller.saveDetails(
      isCollected: inferredCollected,
      isRead: _isRead,
      rating: _isRead ? _rating : null,
      purchaseDate: _purchaseDate,
      pricePaid: price,
      quantityOwned: quantity < 0 ? 0 : quantity,
      format: _format,
      conditionGrade: trimmedCondition.isEmpty ? null : trimmedCondition,
      notes: trimmedNotes.isEmpty ? null : trimmedNotes,
    );

    final state = ref.read(issueMyDetailsControllerProvider(widget.issueId));
    if (state.hasError) {
      TakionAlerts.error(context, state.error.toString());
      return;
    }

    _initialPurchaseDate = _purchaseDate;
    _initialFormat = _format;
    _initialNotes = _notesController.text;
    _initialCondition = _conditionController.text;
    _initialPrice = _priceController.text;
    _initialQuantity = _quantityController.text;

    if (mounted) {
      setState(() {});
    }

    TakionAlerts.libraryUpdated(context);
  }

  Future<void> _logReadWithPicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 2),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    final resolvedTime = pickedTime ?? TimeOfDay.fromDateTime(now);
    final selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      resolvedTime.hour,
      resolvedTime.minute,
    );

    final controller = ref.read(issueMyDetailsControllerProvider(widget.issueId).notifier);
    await controller.addReadLogAt(selectedDateTime);

    final state = ref.read(issueMyDetailsControllerProvider(widget.issueId));
    if (state.hasError) {
      TakionAlerts.error(context, state.error.toString());
      return;
    }
    TakionAlerts.libraryMarkedAsRead(context);
  }

  Future<void> _deleteReadLog(String readLogId) async {
    final controller = ref.read(issueMyDetailsControllerProvider(widget.issueId).notifier);
    await controller.deleteReadLogById(readLogId);

    final state = ref.read(issueMyDetailsControllerProvider(widget.issueId));
    if (state.hasError) {
      TakionAlerts.error(context, state.error.toString());
      return;
    }
    TakionAlerts.libraryUpdated(context);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat.yMMMd().format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(issueMyDetailsProvider(widget.issueId));
    final saveState = ref.watch(issueMyDetailsControllerProvider(widget.issueId));

    return detailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Failed to load details: $error'),
      data: (data) {
        _hydrateFromData(data);
        final item = data.item;
        final readingHistory = data.readLogs;
        final hasChanges = _hasChanges();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(label: 'Date Added', value: _formatDate(item?.createdAt)),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 10.0;
                        final itemWidth = (constraints.maxWidth - spacing) / 2;

                        return Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: itemWidth,
                                  child: TextFormField(
                                    controller: _quantityController,
                                    enabled: !saveState.isLoading,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Quantity Owned',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: spacing),
                                SizedBox(
                                  width: itemWidth,
                                  child: DropdownButtonFormField<LibraryItemFormat>(
                                    value: _format,
                                    decoration: const InputDecoration(labelText: 'Format'),
                                    items: const [
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
                                        : (value) {
                                            if (value == null) return;
                                            setState(() => _format = value);
                                          },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: spacing),
                            Row(
                              children: [
                                SizedBox(
                                  width: itemWidth,
                                  child: TextFormField(
                                    controller: _priceController,
                                    enabled: !saveState.isLoading,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(labelText: 'Price Paid'),
                                  ),
                                ),
                                const SizedBox(width: spacing),
                                SizedBox(
                                  width: itemWidth,
                                  child: TextFormField(
                                    key: ValueKey(
                                      _purchaseDate?.toIso8601String() ?? 'purchase-none',
                                    ),
                                    initialValue: _formatDate(_purchaseDate),
                                    readOnly: true,
                                    onTap: saveState.isLoading ? null : _pickPurchaseDate,
                                    decoration: const InputDecoration(
                                      labelText: 'Purchase Date',
                                      suffixIcon: Icon(Icons.calendar_today_outlined),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _conditionController,
                      enabled: !saveState.isLoading,
                      decoration: const InputDecoration(labelText: 'Condition Grade'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      enabled: !saveState.isLoading,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Additional Notes'),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: (saveState.isLoading || !hasChanges) ? null : _save,
                        child: saveState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Reading History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: saveState.isLoading ? null : _logReadWithPicker,
                  icon: const Icon(Icons.add),
                  label: const Text('Log Read'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (readingHistory.isEmpty)
              Text(
                'No reading history yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: List.generate(readingHistory.length, (index) {
                    final log = readingHistory[index];
                    return ListTile(
                      dense: true,
                      title: Text(DateFormat.yMMMd().add_jm().format(log.readAt.toLocal())),
                      subtitle: (log.notes?.trim().isNotEmpty ?? false)
                          ? Text(log.notes!.trim())
                          : null,
                      trailing: IconButton(
                        tooltip: 'Delete read log',
                        onPressed: saveState.isLoading
                            ? null
                            : () => _deleteReadLog(log.id),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    );
                  }),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
