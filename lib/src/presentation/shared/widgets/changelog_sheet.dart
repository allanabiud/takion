import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:markdown/markdown.dart" as md;
import "package:url_launcher/url_launcher.dart";

const _collapsedSize = 0.6;
const _expandedSize = 0.95;
const _githubChangelogUrl =
    "https://github.com/allanabiud/takion/blob/master/CHANGELOG.md";

final _releaseHeadingRegex = RegExp(r"^\[([^\]]+)\]\s*[-–—]\s*(.+)$");

Future<void> showChangelogSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _ChangelogSheet(),
  );
}

class _ChangelogSheet extends StatefulWidget {
  const _ChangelogSheet();

  @override
  State<_ChangelogSheet> createState() => _ChangelogSheetState();
}

class _ChangelogSheetState extends State<_ChangelogSheet> {
  final _sheetController = DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _handlePopInvoked(bool didPop, Object? result) {
    if (didPop) return;
    if (_sheetController.size > _collapsedSize + 0.01) {
      _sheetController.animateTo(
        _collapsedSize,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePopInvoked,
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: _collapsedSize,
        minChildSize: _collapsedSize,
        maxChildSize: _expandedSize,
        snap: true,
        snapSizes: const [_collapsedSize, _expandedSize],
        shouldCloseOnMinExtent: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Stack(
              children: [
                CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Center(
                              child: Container(
                                width: 32,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/branding/takion_logo.svg",
                                  height: 32,
                                  colorFilter: ColorFilter.mode(
                                    primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Changelog",
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: FutureBuilder<String>(
                        future: rootBundle.loadString("CHANGELOG.md"),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text("Couldn't load the changelog."),
                              ),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                            child: MarkdownBody(
                              data: _prepareChangelog(snapshot.data!),
                              styleSheet: _changelogStyleSheet(theme),
                              builders: {"h2": _ReleaseHeadingBuilder()},
                              onTapLink: (text, href, title) {
                                final uri = Uri.tryParse(href ?? "");
                                if (uri != null) {
                                  launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 40,
                  child: _ViewOnGithubButton(
                    onPressed: () => launchUrl(
                      Uri.parse(_githubChangelogUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  MarkdownStyleSheet _changelogStyleSheet(ThemeData theme) {
    final base = MarkdownStyleSheet.fromTheme(theme);
    final primary = theme.colorScheme.primary;
    return base.copyWith(
      p: base.p?.copyWith(
        fontSize: (base.p?.fontSize ?? 14) + 1,
        fontWeight: FontWeight.w600,
      ),
      h1: base.h1?.copyWith(color: primary, fontWeight: FontWeight.bold),
      h3: base.h3?.copyWith(
        color: theme.colorScheme.secondary,
        fontWeight: FontWeight.bold,
      ),
      h4: base.h4?.copyWith(
        color: theme.colorScheme.secondary,
        fontWeight: FontWeight.bold,
      ),
      listBullet: (base.listBullet ?? const TextStyle()).copyWith(
        color: theme.colorScheme.secondary,
      ),
    );
  }

  String _prepareChangelog(String markdown) {
    final lines = markdown.split("\n");
    final start = lines.indexWhere((line) => line.startsWith("## "));
    if (start > 0) {
      lines.removeRange(0, start);
    }
    final unreleasedIndex = lines.indexWhere(
      (line) => line.startsWith("## [Unreleased]"),
    );
    if (unreleasedIndex >= 0) {
      var end = unreleasedIndex + 1;
      while (end < lines.length && lines[end].trim().isEmpty) {
        end += 1;
      }
      lines.removeRange(unreleasedIndex, end);
    }
    return lines.join("\n");
  }
}

class _ReleaseHeadingBuilder extends MarkdownElementBuilder {
  bool _seenRelease = false;

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) =>
      const SizedBox.shrink();

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final theme = Theme.of(context);
    final match = _releaseHeadingRegex.firstMatch(element.textContent.trim());
    if (match == null) {
      return const SizedBox.shrink();
    }
    final isFirst = !_seenRelease;
    _seenRelease = true;
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 20, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFirst) ...[
            Container(height: 1, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  match.group(1)!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                match.group(2)!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewOnGithubButton extends StatelessWidget {
  const _ViewOnGithubButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.code,
                size: 18,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                "View on GitHub",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
