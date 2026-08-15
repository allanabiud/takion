import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/features/browse/providers/browse_providers.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/browse_paged_list_screen.dart";

class GenericBrowseScreen<T> extends ConsumerStatefulWidget {
  const GenericBrowseScreen({
    super.key,
    required this.title,
    required this.providerBuilder,
    required this.itemBuilder,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.errorPrefix,
    this.searchHint = "Filter by name...",
    this.refreshNotifierGetter,
  });

  final String title;
  final AsyncValue<BrowsePagedData<T>> Function(
    WidgetRef ref,
    BrowseFilter filter,
  )
  providerBuilder;
  final Future<int> Function(WidgetRef ref, BrowseFilter filter)?
  refreshNotifierGetter;
  final Widget Function(BuildContext context, T item, int index, int total)
  itemBuilder;
  final String emptyMessage;
  final IconData emptyIcon;
  final String errorPrefix;
  final String searchHint;

  @override
  ConsumerState<GenericBrowseScreen<T>> createState() =>
      _GenericBrowseScreenState<T>();
}

class _GenericBrowseScreenState<T>
    extends ConsumerState<GenericBrowseScreen<T>> {
  int _page = 1;
  String? _searchQuery;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  BrowseFilter get _filter => BrowseFilter(
    page: _page,
    name: _searchQuery?.trim().isEmpty == true ? null : _searchQuery?.trim(),
  );

  @override
  Widget build(BuildContext context) {
    final async = widget.providerBuilder(ref, _filter);
    return BrowsePagedListScreen<T>(
      title: widget.title,
      pageAsync: async,
      onRefresh: () async {
        if (widget.refreshNotifierGetter == null) return;
        try {
          final count = await widget.refreshNotifierGetter!(ref, _filter);
          if (count > 0 && context.mounted) {
            TakionAlerts.info(context, "Updated $count items");
          }
        } catch (e) {
          if (context.mounted) {
            TakionAlerts.safeError(context, e, userMessage: "Refresh failed");
          }
        }
      },
      onPrevious: () => setState(() => _page--),
      onNext: () => setState(() => _page++),
      emptyMessage: widget.emptyMessage,
      emptyIcon: widget.emptyIcon,
      errorPrefix: widget.errorPrefix,
      header: _SearchHeader(
        controller: _searchController,
        hintText: widget.searchHint,
        onChanged: (val) {
          setState(() {
            _page = 1;
            _searchQuery = val.trim().isEmpty ? null : val.trim();
          });
        },
      ),
      itemBuilder: widget.itemBuilder,
    );
  }
}

class _SearchHeader extends StatefulWidget {
  const _SearchHeader({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<_SearchHeader> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  isDense: true,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.bodyLarge,
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    widget.onChanged(value);
                  });
                },
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged("");
                },
              ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
