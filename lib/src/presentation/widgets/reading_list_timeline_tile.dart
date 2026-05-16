import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/providers/reading_list_item_status_provider.dart';
import 'package:takion/src/presentation/widgets/role_badge.dart';
import 'package:takion/src/presentation/widgets/timeline_item_tile.dart';
import 'package:timelines_plus/timelines_plus.dart';

class ReadingListTimelineTile extends ConsumerWidget {
  final ReadingList list;
  final int index; // 1-based index in the timeline
  final ReadingListItem item;
  final Color roleColor;
  final bool isEditing;
  final bool isSelected;
  final VoidCallback? onSelected;
  final VoidCallback? onRemove;

  const ReadingListTimelineTile({
    super.key,
    required this.list,
    required this.index,
    required this.item,
    required this.roleColor,
    this.isEditing = false,
    this.isSelected = false,
    this.onSelected,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isReadAsync = ref.watch(readingListItemEffectiveReadStatusProvider(item));
    final isRead = isReadAsync.value ?? item.isRead;

    // startConnector is solid if the PREVIOUS item was read
    bool prevIsRead = false;
    if (index - 1 > 0 && index - 2 < list.items.length) {
      final prevItem = list.items[index - 2];
      final prevReadAsync = ref.watch(readingListItemEffectiveReadStatusProvider(prevItem));
      prevIsRead = prevReadAsync.value ?? prevItem.isRead;
    }

    final contents = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 8),
          child: RoleBadge(role: item.role),
        ),
        item.isSeries
            ? TimelineSeriesTile(item: item, horizontalPadding: 0)
            : TimelineIssueTile(item: item, horizontalPadding: 0),
      ],
    );

    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (onSelected != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onSelected!(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ReorderableDragStartListener(
                  index: index - 1,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(Icons.drag_handle, size: 20),
                  ),
                ),
                Expanded(child: contents),
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: IconButton(
                    onPressed: onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TimelineTile(
        nodeAlign: TimelineNodeAlign.start,
        node: TimelineNode(
          indicator: DotIndicator(
            size: 28,
            color: isRead ? roleColor : Colors.transparent,
            border: Border.all(color: roleColor, width: 2),
            child: isRead
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: roleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
          ),
          startConnector: index - 1 == 0
              ? null
              : (prevIsRead
                  ? SolidLineConnector(color: roleColor, thickness: 3)
                  : DashedLineConnector(
                      color: roleColor,
                      thickness: 3,
                      dash: 2,
                      gap: 2,
                    )),
          endConnector: index - 1 == list.items.length - 1
              ? null
              : (isRead
                  ? SolidLineConnector(color: roleColor, thickness: 3)
                  : DashedLineConnector(
                      color: roleColor, thickness: 3, dash: 2, gap: 2)),
        ),
        contents: contents,
      ),
    );
  }
}
