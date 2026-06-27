import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_status_provider.dart';
import 'package:takion/src/presentation/components/timeline_item_tile.dart';
import 'package:timelines_plus/timelines_plus.dart';

class ReadingListTimelineTile extends ConsumerWidget {
  final ReadingList list;
  final int index; // 1-based index in the timeline
  final ReadingListItem item;
  final Color roleColor;
  final bool isEditing;
  final bool isSelected;
  final bool isRemoving;
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
    this.isRemoving = false,
    this.onSelected,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isReadAsync = ref.watch(
      readingListItemEffectiveReadStatusProvider(item),
    );
    final isRead = isReadAsync.value ?? item.isRead;

    // startConnector is solid if the PREVIOUS item was read
    bool prevIsRead = false;
    if (index - 1 > 0 && index - 2 < list.items.length) {
      final prevItem = list.items[index - 2];
      final prevReadAsync = ref.watch(
        readingListItemEffectiveReadStatusProvider(prevItem),
      );
      prevIsRead = prevReadAsync.value ?? prevItem.isRead;
    }

    final contents = item.isSeries
        ? TimelineSeriesTile(item: item, horizontalPadding: 0, role: item.role)
        : TimelineIssueTile(item: item, horizontalPadding: 0, role: item.role);

    final unreadConnectorColor = theme.colorScheme.outline;

    if (isEditing) {
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isRemoving ? 0 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: AnimatedScale(
              scale: isSelected ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            index: index - 1,
                            child: Container(
                              width: 36,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.drag_indicator_rounded,
                                  size: 24,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: InkWell(
                                onTap: onSelected,
                                child: IgnorePointer(child: contents),
                              ),
                            ),
                          ),
                          if (onRemove != null)
                            GestureDetector(
                              onTap: onRemove,
                              child: Container(
                                width: 36,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(12),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: true,
                          onChanged: (_) => onSelected?.call(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Color getRoleColor(ItemRole role) {
      switch (role) {
        case ItemRole.core:
          return Colors.red;
        case ItemRole.prologue:
          return Colors.orange;
        case ItemRole.tieIn:
          return Colors.blue;
        case ItemRole.epilogue:
          return Colors.purple;
        case ItemRole.standard:
          return theme.colorScheme.primary;
      }
    }

    final nextRoleColor = index < list.items.length
        ? getRoleColor(list.items[index].role)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TimelineTile(
        nodeAlign: TimelineNodeAlign.start,
        node: TimelineNode(
          indicator: DotIndicator(
            size: 28,
            color: isRead ? roleColor : Colors.transparent,
            border: Border.all(
              color: isRead ? roleColor : unreadConnectorColor,
              width: 2,
            ),
            child: isRead
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: unreadConnectorColor,
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
                        color: unreadConnectorColor,
                        thickness: 3,
                        dash: 2,
                        gap: 2,
                      )),
          endConnector: index - 1 == list.items.length - 1
              ? null
              : (isRead
                    ? (nextRoleColor == null
                          ? SolidLineConnector(color: roleColor, thickness: 3)
                          : DecoratedLineConnector(
                              thickness: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.4, 1.0],
                                  colors: [roleColor, nextRoleColor],
                                ),
                              ),
                            ))
                    : DashedLineConnector(
                        color: unreadConnectorColor,
                        thickness: 3,
                        dash: 2,
                        gap: 2,
                      )),
        ),
        contents: contents,
      ),
    );
  }
}
