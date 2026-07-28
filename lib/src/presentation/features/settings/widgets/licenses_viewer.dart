import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showLicensesSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _LicensesSheet(),
  );
}

class _LicensesSheet extends StatefulWidget {
  const _LicensesSheet();

  @override
  State<_LicensesSheet> createState() => _LicensesSheetState();
}

class _LicensesSheetState extends State<_LicensesSheet> {
  List<_LicenseEntry>? _licenses;
  final Set<int> _expandedIndices = {};

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  Future<void> _loadLicenses() async {
    final entries = <_LicenseEntry>[];
    await for (final entry in LicenseRegistry.licenses) {
      entries.add(
        _LicenseEntry(
          packages: entry.packages.toList(),
          paragraphs: entry.paragraphs.toList(),
        ),
      );
    }
    entries.sort((a, b) => a.packages.first.compareTo(b.packages.first));
    if (mounted) setState(() => _licenses = entries);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            color: theme.colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/branding/takion_logo.svg',
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Open Source Licenses',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                Expanded(child: _buildList(scrollController)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(ScrollController scrollController) {
    final theme = Theme.of(context);

    if (_licenses == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: _licenses!.length,
      itemBuilder: (context, index) {
        final entry = _licenses![index];
        final isExpanded = _expandedIndices.contains(index);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedIndices.remove(index);
                  } else {
                    _expandedIndices.add(index);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.packages.join(', '),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  entry.paragraphs.map((p) => p.text).join('\n'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            Divider(
              height: 1,
              indent: isExpanded ? 0 : 24,
              color: theme.colorScheme.outlineVariant,
            ),
          ],
        );
      },
    );
  }
}

class _LicenseEntry {
  final List<String> packages;
  final List<LicenseParagraph> paragraphs;

  const _LicenseEntry({required this.packages, required this.paragraphs});
}
