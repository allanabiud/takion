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
  LibraryItemFormat? _format;
  bool _isCollected = false;
  bool _isRead = false;
  int? _rating;
  bool _hydrated = false;

  DateTime? _initialPurchaseDate;
  LibraryItemFormat? _initialFormat;
  String _initialNotes = '';
  String _initialCondition = '';
  String _initialPrice = '';
  String _initialQuantity = '';

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
    _format = item?.format;
    _notesController.text = item?.notes ?? '';
    _conditionController.text = item?.conditionGrade ?? '';
    _priceController.text = item?.pricePaid?.toStringAsFixed(2) ?? '';
    _quantityController.text = item?.quantityOwned.toString() ?? '';

    _initialPurchaseDate = _purchaseDate;
    _initialFormat = _format;
    _initialNotes = _notesController.text;
    _initialCondition = _conditionController.text;
    _initialPrice = _priceController.text;
    _initialQuantity = _quantityController.text;
    _hydrated = true;
  }

  Future<void> _save() async {
    final controller = ref.read(
      issueMyDetailsControllerProvider(widget.issueId).notifier,
    );
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
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
      format: _format ?? LibraryItemFormat.print,
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

  String _formatLibraryFormat(LibraryItemFormat? format) {
    return switch (format) {
      LibraryItemFormat.print => 'Print',
      LibraryItemFormat.digital => 'Digital',
      LibraryItemFormat.both => 'Both',
      null => '—',
    };
  }

  String _displayText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '—' : trimmed;
  }

  String _displayPrice(String value) {
    final price = double.tryParse(value.trim());
    if (price == null) return '—';
    return '\$${price.toStringAsFixed(2)}';
  }

  String _displayQuantity(String value) {
    final quantity = int.tryParse(value.trim());
    if (quantity == null) return '—';
    return '$quantity';
  }

  Future<void> _showEditDetailsSheet() async {
    final notesController = TextEditingController(text: _notesController.text);
    final conditionController = TextEditingController(
      text: _conditionController.text,
    );
    final priceController = TextEditingController(text: _priceController.text);
    final quantityController = TextEditingController(
      text: _quantityController.text,
    );
    var purchaseDate = _purchaseDate;
    var format = _format;

    bool hasChanges() {
      final currentNotes = notesController.text.trim();
      final currentCondition = conditionController.text.trim();
      final currentPrice = priceController.text.trim();
      final currentQuantity = quantityController.text.trim();
      final initialPurchase = _initialPurchaseDate?.toUtc().toIso8601String();
      final currentPurchase = purchaseDate?.toUtc().toIso8601String();
      return currentNotes != _initialNotes.trim() ||
          currentCondition != _initialCondition.trim() ||
          currentPrice != _initialPrice.trim() ||
          currentQuantity != _initialQuantity.trim() ||
          format != _initialFormat ||
          currentPurchase != initialPurchase;
    }

    Future<void> pickPurchaseDate(StateSetter setSheetState) async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: purchaseDate ?? now,
        firstDate: DateTime(1900),
        lastDate: DateTime(now.year + 2),
      );
      if (picked == null) return;
      setSheetState(() {
        purchaseDate = picked;
      });
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final saveState = ref.watch(
              issueMyDetailsControllerProvider(widget.issueId),
            );
            return StatefulBuilder(
              builder: (context, setSheetState) {
                final formHasChanges = hasChanges();
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    36 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Edit My Details',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            const spacing = 10.0;
                            final itemWidth =
                                (constraints.maxWidth - spacing) / 2;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: itemWidth,
                                      child: TextFormField(
                                        controller: quantityController,
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
                                      child:
                                          DropdownButtonFormField<
                                            LibraryItemFormat?
                                          >(
                                            isExpanded: true,
                                            initialValue: format,
                                            decoration: const InputDecoration(
                                              labelText: 'Format',
                                            ),
                                            hint: const Text('Select format'),
                                            items: const [
                                              DropdownMenuItem<
                                                LibraryItemFormat?
                                              >(
                                                value: null,
                                                child: Text('Not set'),
                                              ),
                                              DropdownMenuItem(
                                                value: LibraryItemFormat.print,
                                                child: Text('Print'),
                                              ),
                                              DropdownMenuItem(
                                                value:
                                                    LibraryItemFormat.digital,
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
                                                    setSheetState(
                                                      () => format = value,
                                                    );
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
                                        controller: priceController,
                                        enabled: !saveState.isLoading,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: const InputDecoration(
                                          labelText: 'Price Paid',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: spacing),
                                    SizedBox(
                                      width: itemWidth,
                                      child: TextFormField(
                                        key: ValueKey(
                                          purchaseDate?.toIso8601String() ??
                                              'purchase-none',
                                        ),
                                        initialValue: _formatDate(purchaseDate),
                                        readOnly: true,
                                        onTap: saveState.isLoading
                                            ? null
                                            : () => pickPurchaseDate(
                                                setSheetState,
                                              ),
                                        decoration: const InputDecoration(
                                          labelText: 'Purchase Date',
                                          suffixIcon: Icon(
                                            Icons.calendar_today_outlined,
                                          ),
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
                          controller: conditionController,
                          enabled: !saveState.isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Condition Grade',
                          ),
                        ),
                        const SizedBox(height: 8),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: (saveState.isLoading || !formHasChanges)
                                ? null
                                : () async {
                                    _notesController.text =
                                        notesController.text;
                                    _conditionController.text =
                                        conditionController.text;
                                    _priceController.text =
                                        priceController.text;
                                    _quantityController.text =
                                        quantityController.text;
                                    _purchaseDate = purchaseDate;
                                    _format = format;

                                    await _save();
                                    final state = ref.read(
                                      issueMyDetailsControllerProvider(
                                        widget.issueId,
                                      ),
                                    );
                                    if (state.hasError ||
                                        !sheetContext.mounted) {
                                      return;
                                    }
                                    Navigator.of(sheetContext).pop();
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
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    notesController.dispose();
    conditionController.dispose();
    priceController.dispose();
    quantityController.dispose();
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

    final controller = ref.read(
      issueMyDetailsControllerProvider(widget.issueId).notifier,
    );
    await controller.addReadLogAt(selectedDateTime);

    final state = ref.read(issueMyDetailsControllerProvider(widget.issueId));
    if (state.hasError) {
      TakionAlerts.error(context, state.error.toString());
      return;
    }
    TakionAlerts.libraryMarkedAsRead(context);
  }

  Future<void> _deleteReadLog(String readLogId) async {
    final controller = ref.read(
      issueMyDetailsControllerProvider(widget.issueId).notifier,
    );
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

  Widget _buildSectionCard(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(issueMyDetailsProvider(widget.issueId));
    final saveState = ref.watch(
      issueMyDetailsControllerProvider(widget.issueId),
    );

    return detailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Failed to load details: $error'),
      data: (data) {
        _hydrateFromData(data);
        final item = data.item;
        final readingHistory = data.readLogs;
        final sectionHeaderStyle = Theme.of(context).textTheme.titleSmall
            ?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('My Details', style: sectionHeaderStyle),
                      ),
                      IconButton(
                        tooltip: 'Edit details',
                        onPressed: saveState.isLoading
                            ? null
                            : _showEditDetailsSheet,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'Date Added',
                    value: _formatDate(item?.createdAt),
                    italic: true,
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'Quantity Owned',
                    value: _displayQuantity(_quantityController.text),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Format',
                    value: _formatLibraryFormat(_format),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Price Paid',
                    value: _displayPrice(_priceController.text),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Purchase Date',
                    value: _formatDate(_purchaseDate),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Condition Grade',
                    value: _displayText(_conditionController.text),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Additional Notes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _displayText(_notesController.text),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            _buildSectionCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Reading History',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sectionHeaderStyle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: saveState.isLoading
                            ? null
                            : _logReadWithPicker,
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
                    Column(
                      children: List.generate(readingHistory.length, (index) {
                        final log = readingHistory[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            DateFormat.yMMMd().add_jm().format(
                              log.readAt.toLocal(),
                            ),
                          ),
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
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.italic = false,
  });

  final String label;
  final String value;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontStyle: italic ? FontStyle.italic : null,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontStyle: italic ? FontStyle.italic : null,
          ),
        ),
      ],
    );
  }
}
