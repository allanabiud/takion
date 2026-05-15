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

class _AddReadingListItemsBottomSheetState extends ConsumerState<AddReadingListItemsBottomSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  SeriesList? _selectedSeries;
  bool _addAllIssues = true;
  RangeValues _issueRange = const RangeValues(1, 10);
  bool _isAdding = false;

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
          role: ItemRole.standard,
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
              role: ItemRole.standard,
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
                role: ItemRole.standard,
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

  @override
  Widget build(BuildContext context) {
    final searchArgs = SeriesSearchArgs(query: _query, page: 1);
    final searchResults = _query.isEmpty ? null : ref.watch(seriesSearchResultsProvider(searchArgs));

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
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Add Reading List Items', 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(height: 16),
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
                  final isSelected = _selectedSeries?.id == item.id;
                  final maxIssues = (item.issueCount ?? 1).toDouble();
                  return Column(
                    children: [
                      CheckboxListTile(
                        value: isSelected,
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.yearBegan ?? 'N/A'} • ${item.issueCount ?? 0} Issues'),
                        onChanged: (v) => setState(() {
                          _selectedSeries = v == true ? item : null;
                          if (item.issueCount != null) {
                            _issueRange = RangeValues(1, maxIssues);
                          }
                        }),
                      ),
                      if (isSelected && widget.list.contentType == ListContentType.issue) ...[
                        SwitchListTile(
                          title: const Text('Add all Issues'),
                          value: _addAllIssues,
                          onChanged: (v) => setState(() => _addAllIssues = v),
                        ),
                        if (!_addAllIssues) ...[
                          Text('Range: ${_issueRange.start.toInt()} - ${_issueRange.end.toInt()}'),
                          RangeSlider(
                            values: _issueRange,
                            min: 1,
                            max: maxIssues,
                            divisions: (maxIssues - 1).toInt().clamp(1, 100),
                            labels: RangeLabels(_issueRange.start.toInt().toString(), _issueRange.end.toInt().toString()),
                            onChanged: (v) => setState(() => _issueRange = v),
                          ),
                        ],
                      ],
                    ],
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ) ?? const SizedBox.shrink(),
          ),
          if (_selectedSeries != null)
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
      ),
    );
  }
}
