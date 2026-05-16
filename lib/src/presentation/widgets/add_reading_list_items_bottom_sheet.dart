import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/data/repositories/reading_list_repository_impl.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/providers/reading_list_details_provider.dart';
import 'package:takion/src/presentation/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/series_search_provider.dart';

class AddReadingListItemsBottomSheet extends ConsumerStatefulWidget {
  final ReadingList list;

  const AddReadingListItemsBottomSheet({super.key, required this.list});

  @override
  ConsumerState<AddReadingListItemsBottomSheet> createState() => _AddReadingListItemsBottomSheetState();
}

enum _AddStep { selection, configuration }

class _AddReadingListItemsBottomSheetState extends ConsumerState<AddReadingListItemsBottomSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  SeriesList? _selectedSeries;
  bool _addAllIssues = true;
  bool _useManualRange = false;
  RangeValues _issueRange = const RangeValues(1, 10);
  ItemRole _selectedRole = ItemRole.standard;
  bool _isAdding = false;
  _AddStep _currentStep = _AddStep.selection;

  void _onAddPressed() async {
    if (_selectedSeries == null) return;

    setState(() => _isAdding = true);

    try {
      final itemsToAdd = <ReadingListItem>[];
      final repository = ref.read(readingListRepositoryProvider);
      final metronRepo = ref.read(metronRepositoryProvider);

      if (widget.list.contentType == ListContentType.series) {
        itemsToAdd.add(ReadingListItem(
          targetId: 'series-${_selectedSeries!.id}',
          isSeries: true,
          role: _selectedRole,
          isRead: false,
        ));
      } else {
        final allIssues = <IssueList>[];
        int currentPage = 1;
        bool hasNext = true;

        while (hasNext) {
          final page = await metronRepo.getSeriesIssueList(_selectedSeries!.id, page: currentPage);
          allIssues.addAll(page.results);
          hasNext = page.next != null;
          currentPage++;
          if (currentPage > 20) break;
        }

        if (_addAllIssues) {
          for (final issue in allIssues) {
            itemsToAdd.add(ReadingListItem(
              targetId: 'issue-${issue.id}',
              isSeries: false,
              role: _selectedRole,
              isRead: false,
            ));
          }
        } else {
          final start = _issueRange.start.toInt() - 1;
          final end = _issueRange.end.toInt() - 1;

          for (int i = 0; i < allIssues.length; i++) {
            if (i >= start && i <= end) {
              itemsToAdd.add(ReadingListItem(
                targetId: 'issue-${allIssues[i].id}',
                isSeries: false,
                role: _selectedRole,
                isRead: false,
              ));
            }
          }
        }
      }

      await repository.addItemsToList(widget.list.id, itemsToAdd);

      ref.invalidate(readingListsProvider);
      ref.invalidate(readingListDetailsProvider(widget.list.id));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add items: $e')));
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Widget _buildSeriesSelectionStep(WidgetRef ref) {
    final searchArgs = SeriesSearchArgs(query: _query, page: 1);
    final searchResults = _query.trim().isEmpty ? null : ref.watch(seriesSearchResultsProvider(searchArgs));

    return Column(
      children: [
        TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Search Series',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: searchResults?.when(
            data: (page) => ListView.separated(
              itemCount: page.results.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = page.results[index];
                final maxIssues = (item.issueCount ?? 1).toDouble();
                return ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.yearBegan ?? 'N/A'} • ${item.issueCount ?? 0} Issues'),
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
            error: (e, _) => Center(child: Text('Error: $e')),
          ) ?? const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildConfigurationStep() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(Icons.arrow_back),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _currentStep = _AddStep.selection)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedSeries!.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('Item Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ItemRole.values.map((role) {
                    final label = role == ItemRole.tieIn
                        ? 'Tie-In'
                        : role.name.substring(0, 1).toUpperCase() + role.name.substring(1);
                    return ChoiceChip(
                      label: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      selected: _selectedRole == role,
                      shape: const StadiumBorder(),
                      onSelected: (selected) => setState(() => _selectedRole = role),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                if (widget.list.contentType == ListContentType.issue) ...[
                  const Text('Issue Selection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('#${_issueRange.start.toInt()} to #${_issueRange.end.toInt()}',
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: () => setState(() => _useManualRange = !_useManualRange),
                                child: Text(_useManualRange ? 'Use Slider' : 'Use Inputs'),
                              ),
                            ],
                          ),
                          if (_useManualRange)
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _issueRange.start.toInt().toString(),
                                    decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      final val = double.tryParse(v);
                                      if (val != null) setState(() => _issueRange = RangeValues(val, _issueRange.end));
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _issueRange.end.toInt().toString(),
                                    decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      final val = double.tryParse(v);
                                      if (val != null) setState(() => _issueRange = RangeValues(_issueRange.start, val));
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            RangeSlider(
                              values: _issueRange,
                              min: 1,
                              max: (_selectedSeries!.issueCount ?? 1).toDouble(),
                              divisions: ((_selectedSeries!.issueCount ?? 1) - 1).toInt().clamp(1, 100),
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
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: FilledButton(
              onPressed: _isAdding ? null : _onAddPressed,
              child: _isAdding
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Add to List'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
        left: 24,
        right: 24,
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          if (_currentStep == _AddStep.selection)
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Add Reading List Items',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: _currentStep == _AddStep.selection
                ? _buildSeriesSelectionStep(ref)
                : _buildConfigurationStep(),
          ),
        ],
      ),
    );
  }
}
