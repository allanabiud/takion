import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/tags/providers/tag_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/features/tags/widgets/tag_manager_sheet.dart';
import 'package:takion/src/presentation/components/components.dart';

void showTagSelectorSheet(BuildContext context, WidgetRef ref, int issueId) {
  TakionBottomSheet.show<void>(
    context: context,
    title: 'Tag Issue',
    child: Consumer(
      builder: (context, ref, _) {
        final allTagsAsync = ref.watch(allTagsProvider);
        final issueTagsAsync = ref.watch(issueTagsProvider(issueId));

        return allTagsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(TakionAlerts.cleanError(error, fallback: 'Something went wrong'))),
          data: (allTags) {
            if (allTags.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No tags yet. Create tags to get started.'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Manage Tags'),
                    onTap: () {
                      Navigator.of(context).pop();
                      showTagManagerSheet(context, ref);
                    },
                  ),
                ],
              );
            }

            return issueTagsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SizedBox.shrink(),
              data: (issueTags) {
                final issueTagIds = issueTags.map((t) => t.id).toSet();

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...allTags.map(
                        (tag) {
                          final isSelected = issueTagIds.contains(tag.id);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(tag.colorValue),
                                  radius: 10,
                                ),
                                const SizedBox(width: 12),
                                Text(tag.name),
                              ],
                            ),
                            onChanged: (selected) async {
                              final ops = ref.read(tagOperationsProvider);
                              if (selected == true) {
                                await ops.addTagToIssue(issueId, tag.id);
                              } else {
                                await ops.removeTagFromIssue(issueId, tag.id);
                              }
                            },
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Manage Tags'),
                        onTap: () {
                          Navigator.of(context).pop();
                          showTagManagerSheet(context, ref);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ),
  );
}
