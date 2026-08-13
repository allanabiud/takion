import 'package:flutter/material.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/domain/common/string_extensions.dart';

Future<List<IssueList>?> showIssuePickerSheet(
  BuildContext context,
  List<IssueList> issues,
) {
  return showModalBottomSheet<List<IssueList>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      final selectedIds = <int>{};
      final filterController = TextEditingController();
      var filterText = '';

      List<IssueList> filteredIssues() {
        if (filterText.isEmpty) return issues;
        final query = filterText.toLowerCase();
        return issues.where((issue) {
          if (issue.name.toLowerCase().contains(query)) return true;
          if (issue.number.toLowerCase().contains(query)) return true;
          final series = issue.series;
          if (series != null && series.name.toLowerCase().contains(query)) {
            return true;
          }
          return false;
        }).toList();
      }

      bool allSelected() => issues
          .where((i) => i.id != null)
          .every((i) => selectedIds.contains(i.id));

      String issueTitle(IssueList issue) {
        if (issue.name.contains('#${issue.number}') || issue.number.isEmpty) {
          return issue.name;
        }
        return '${issue.name} #${issue.number}';
      }

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          final filtered = filteredIssues();
          final selectedCount = selectedIds.length;

          return TakionBottomSheet(
            title: 'Select Issues',
            titleHeader: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Issues',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$selectedCount of ${issues.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: filterController,
                    decoration: const InputDecoration(
                      hintText: 'Search issues...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      filterText = value;
                      setSheetState(() {});
                    },
                  ),
                ),
                if (issues.length > 1)
                  CheckboxListTile(
                    value: allSelected(),
                    onChanged: (v) {
                      setSheetState(() {
                        if (v == true) {
                          selectedIds.addAll(
                            issues.map((i) => i.id).whereType<int>(),
                          );
                        } else {
                          selectedIds.clear();
                        }
                      });
                    },
                    title: Text(
                      allSelected() ? 'Deselect all' : 'Select all',
                      style: theme.textTheme.bodyMedium,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No issues match "$filterText"',
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
                            issueId != null && selectedIds.contains(issueId);
                        final title = issueTitle(issue);

                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: issueId == null
                              ? null
                              : (v) {
                                  setSheetState(() {
                                    if (v == true) {
                                      selectedIds.add(issueId);
                                    } else {
                                      selectedIds.remove(issueId);
                                    }
                                  });
                                },
                          secondary: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 42,
                              height: 63,
                              child: EntityCover(
                                imageUrl: issue.image,
                                placeholderLabel: initials(title),
                                width: 42,
                                height: 63,
                                borderRadius: 0,
                                aspectRatio: 42 / 63,
                                iconSize: 20,
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
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
                          subtitle:
                              issue.storeDate != null || issue.coverDate != null
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
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: selectedCount == 0
                          ? null
                          : () {
                              final selected = issues
                                  .where((i) => selectedIds.contains(i.id))
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
        },
      );
    },
  );
}
