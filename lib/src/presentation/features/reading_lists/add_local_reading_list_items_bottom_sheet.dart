import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/common/search_utils.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/local_reading_list_details_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/local_reading_lists_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_search_provider.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';

class AddLocalReadingListItemsBottomSheet extends ConsumerStatefulWidget {
  final LocalReadingList list;

  const AddLocalReadingListItemsBottomSheet({super.key, required this.list});

  static Future<void> show(BuildContext context, LocalReadingList list) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => AddLocalReadingListItemsBottomSheet(list: list),
    );
  }

  @override
  ConsumerState<AddLocalReadingListItemsBottomSheet> createState() =>
      _AddLocalReadingListItemsBottomSheetState();
}

enum _AddStep { selection, configuration }

class _AddLocalReadingListItemsBottomSheetState
    extends ConsumerState<AddLocalReadingListItemsBottomSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  SeriesList? _selectedSeries;
  bool _addAllIssues = true;
  bool _useManualRange = false;
  RangeValues _issueRange = const RangeValues(1, 10);
  ItemRole _selectedRole = ItemRole.standard;
  bool _isAdding = false;
  _AddStep _currentStep = _AddStep.selection;

  String _normalizeTargetId(String targetId, bool isSeries) {
    final normalized = targetId.trim().toLowerCase();
    final expectedPrefix = isSeries ? 'series-' : 'issue-';
    if (normalized.startsWith(expectedPrefix)) return normalized;

    final alternatePrefix = isSeries ? 'issue-' : 'series-';
    if (normalized.startsWith(alternatePrefix)) {
      return '$expectedPrefix${normalized.substring(alternatePrefix.length)}';
    }

    return '$expectedPrefix$normalized';
  }

  void _onAddPressed() async {
    if (_selectedSeries == null) return;

    setState(() => _isAdding = true);

    try {
      final itemsToAdd = <LocalReadingListItem>[];
      final repository = ref.read(localReadingListRepositoryProvider);
      final metronRepo = ref.read(metronRepositoryProvider);

      if (widget.list.contentType == ListContentType.series) {
        itemsToAdd.add(
          LocalReadingListItem(
            targetId: 'series-${_selectedSeries!.id}',
            isSeries: true,
            role: _selectedRole,
            isRead: false,
          ),
        );
      } else {
        final allIssues = <IssueList>[];
        int currentPage = 1;
        bool hasNext = true;

        while (hasNext) {
          final page = await metronRepo.getSeriesIssueList(
            _selectedSeries!.id,
            page: currentPage,
          );
          allIssues.addAll(page.results);
          hasNext = page.next != null;
          currentPage++;
          if (currentPage > 20) break;
        }

        if (_addAllIssues) {
          for (final issue in allIssues) {
            itemsToAdd.add(
              LocalReadingListItem(
                targetId: 'issue-${issue.id}',
                isSeries: false,
                role: _selectedRole,
                isRead: false,
              ),
            );
          }
        } else {
          final start = _issueRange.start.toInt() - 1;
          final end = _issueRange.end.toInt() - 1;

          for (int i = 0; i < allIssues.length; i++) {
            if (i >= start && i <= end) {
              itemsToAdd.add(
                LocalReadingListItem(
                  targetId: 'issue-${allIssues[i].id}',
                  isSeries: false,
                  role: _selectedRole,
                  isRead: false,
                ),
              );
            }
          }
        }
      }

      final existingIds = widget.list.items
          .map((i) => _normalizeTargetId(i.targetId, i.isSeries))
          .toSet();
      final newItems = itemsToAdd
          .map(
            (item) => item.copyWith(
              targetId: _normalizeTargetId(item.targetId, item.isSeries),
            ),
          )
          .whereType<LocalReadingListItem>()
          .where((i) => !existingIds.contains(i.targetId))
          .toList();

      if (newItems.isEmpty && itemsToAdd.isNotEmpty) {
        if (mounted) {
          TakionAlerts.info(context, 'Already in this list');
          Navigator.pop(context);
        }
        return;
      }

      final skippedCount = itemsToAdd.length - newItems.length;

      await repository.addItemsToList(widget.list.id, newItems);

      ref.invalidate(localReadingListsProvider);
      ref.invalidate(localReadingListDetailsProvider(widget.list.id));

      if (mounted) {
        if (skippedCount > 0) {
          TakionAlerts.success(context, 'Added ${newItems.length} Items');
        } else {
          TakionAlerts.success(context, 'Added to Reading List');
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(context, e, userMessage: 'Failed to add items');
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Widget _buildSeriesSelectionStep(WidgetRef ref) {
    final searchArgs = SearchArgs(query: _query, page: 1);
    final searchResults = _query.trim().isEmpty
        ? null
        : ref.watch(seriesSearchProvider(searchArgs));

    return Column(
      children: [
        TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Search Series',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 16),
        Expanded(
          child:
              searchResults?.when(
                data: (page) => ListView.separated(
                  itemCount: page.results.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = page.results[index];
                    final maxIssues = (item.issueCount ?? 1).toDouble();
                    return ListTile(
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${item.yearBegan ?? 'N/A'} • ${item.issueCount ?? 0} Issues',
                      ),
                      onTap: () {
                        setState(() {
                          _selectedSeries = item;
                          if (item.issueCount != null) {
                            _issueRange = RangeValues(1, maxIssues);
                          }
                          _currentStep = _AddStep.configuration;
                        });
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    TakionAlerts.cleanError(e, fallback: 'Failed to add items'),
                  ),
                ),
              ) ??
              const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildConfigurationStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Item Role',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ItemRole.values.map((role) {
                    final label = role == ItemRole.tieIn
                        ? 'Tie-In'
                        : role.name.substring(0, 1).toUpperCase() +
                              role.name.substring(1);
                    return ChoiceChip(
                      label: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      selected: _selectedRole == role,
                      shape: const StadiumBorder(),
                      onSelected: (selected) =>
                          setState(() => _selectedRole = role),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                if (widget.list.contentType == ListContentType.issue) ...[
                  const Text(
                    'Issue Selection',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('Add all issues'),
                    contentPadding: EdgeInsets.zero,
                    value: _addAllIssues,
                    onChanged: (v) => setState(() => _addAllIssues = v),
                  ),
                  if (!_addAllIssues) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${_issueRange.start.toInt()} to #${_issueRange.end.toInt()}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () => setState(
                                  () => _useManualRange = !_useManualRange,
                                ),
                                child: Text(
                                  _useManualRange ? 'Use Slider' : 'Use Inputs',
                                ),
                              ),
                            ],
                          ),
                          if (_useManualRange)
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _issueRange.start
                                        .toInt()
                                        .toString(),
                                    decoration: const InputDecoration(
                                      labelText: 'From',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      final val = double.tryParse(v);
                                      if (val != null) {
                                        setState(
                                          () => _issueRange = RangeValues(
                                            val,
                                            _issueRange.end,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _issueRange.end
                                        .toInt()
                                        .toString(),
                                    decoration: const InputDecoration(
                                      labelText: 'To',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      final value = double.tryParse(val);
                                      if (value != null) {
                                        setState(
                                          () => _issueRange = RangeValues(
                                            _issueRange.start,
                                            value,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            RangeSlider(
                              values: _issueRange,
                              min: 1,
                              max: (_selectedSeries!.issueCount ?? 1)
                                  .toDouble(),
                              divisions:
                                  ((_selectedSeries!.issueCount ?? 1) - 1)
                                      .toInt()
                                      .clamp(1, 100),
                              onChanged: (v) => setState(() => _issueRange = v),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton.icon(
              onPressed: _isAdding
                  ? null
                  : () => setState(() => _currentStep = _AddStep.selection),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _isAdding ? null : _onAddPressed,
              child: _isAdding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Add to List'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TakionBottomSheet(
      title: _currentStep == _AddStep.selection
          ? 'Add Items'
          : _selectedSeries!.name,
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height *
            (_currentStep == _AddStep.selection ? 0.7 : 0.5),
        child: _currentStep == _AddStep.selection
            ? _buildSeriesSelectionStep(ref)
            : _buildConfigurationStep(),
      ),
    );
  }
}
