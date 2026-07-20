import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/logic/string_extensions.dart';

Future<List<IssueList>?> showIssuePickerSheet(
  BuildContext context,
  List<IssueList> issues,
) {
  return showModalBottomSheet<List<IssueList>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _IssuePickerSheet(issues: issues),
  );
}

class _IssuePickerSheet extends StatefulWidget {
  final List<IssueList> issues;

  const _IssuePickerSheet({required this.issues});

  @override
  State<_IssuePickerSheet> createState() => _IssuePickerSheetState();
}

class _IssuePickerSheetState extends State<_IssuePickerSheet> {
  final _filterController = TextEditingController();
  final _selectedIds = <int>{};
  String _filterText = '';

  List<IssueList> get _filteredIssues {
    if (_filterText.isEmpty) return widget.issues;
    final query = _filterText.toLowerCase();
    return widget.issues.where((issue) {
      if (issue.name.toLowerCase().contains(query)) return true;
      if (issue.number.toLowerCase().contains(query)) return true;
      final series = issue.series;
      if (series != null && series.name.toLowerCase().contains(query)) {
        return true;
      }
      return false;
    }).toList();
  }

  bool get _allSelected =>
      widget.issues.where((i) => i.id != null).every(
        (i) => _selectedIds.contains(i.id),
      );

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  String _issueTitle(IssueList issue) {
    if (issue.name.contains('#${issue.number}') || issue.number.isEmpty) {
      return issue.name;
    }
    return '${issue.name} #${issue.number}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredIssues;
    final selectedCount = _selectedIds.length;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text(
                  'Select Issues',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '$selectedCount of ${widget.issues.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _filterController,
              decoration: const InputDecoration(
                hintText: 'Search issues...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _filterText = value),
            ),
          ),
          if (widget.issues.length > 1)
            CheckboxListTile(
              value: _allSelected,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedIds.addAll(
                      widget.issues.map((i) => i.id).whereType<int>(),
                    );
                  } else {
                    _selectedIds.clear();
                  }
                });
              },
              title: Text(
                _allSelected ? 'Deselect all' : 'Select all',
                style: theme.textTheme.bodyMedium,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No issues match "$_filterText"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final issue = filtered[index];
                  final issueId = issue.id;
                  final isSelected =
                      issueId != null && _selectedIds.contains(issueId);
                  final title = _issueTitle(issue);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: issueId == null
                        ? null
                        : (v) {
                            setState(() {
                              if (v == true) {
                                _selectedIds.add(issueId);
                              } else {
                                _selectedIds.remove(issueId);
                              }
                            });
                          },
                    secondary: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 42,
                        height: 63,
                        child: issue.image != null
                            ? CachedNetworkImage(
                                imageUrl: issue.image!,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest,
                                ),
                                errorWidget: (_, _, _) =>
                                    _PlaceholderInitials(
                                      initials: initials(title),
                                      theme: theme,
                                    ),
                              )
                            : _PlaceholderInitials(
                                initials: initials(title),
                                theme: theme,
                              ),
                      ),
                    ),
                    title: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: issue.storeDate != null || issue.coverDate != null
                        ? Text(
                            DateFormatter.comicDate(
                              issue.storeDate ?? issue.coverDate!,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        : null,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: selectedCount == 0
                    ? null
                    : () {
                        final selected = widget.issues
                            .where((i) => _selectedIds.contains(i.id))
                            .toList();
                        Navigator.of(context).pop(selected);
                      },
                child: Text('ADD ($selectedCount)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderInitials extends StatelessWidget {
  final String initials;
  final ThemeData theme;

  const _PlaceholderInitials({
    required this.initials,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
