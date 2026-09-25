import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

mixin LookaheadImagePrecacher<T extends StatefulWidget> on State<T> {
  ScrollController? _scrollController;
  int _lastPrecachedIndex = -1;
  static const _lookaheadCount = 8;

  WidgetRef get ref;

  void attachScrollController(ScrollController controller) {
    _scrollController?.removeListener(_onScroll);
    _scrollController = controller;
    _scrollController!.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;

    final position = controller.position;
    final viewportStart = position.pixels;
    final viewportEnd = viewportStart + position.viewportDimension;

    final startIndex = _estimateVisibleIndex(viewportStart);
    final endIndex = _estimateVisibleIndex(viewportEnd);

    final precachEnd = endIndex + _lookaheadCount;

    if (precachEnd <= _lastPrecachedIndex) return;
    _lastPrecachedIndex = precachEnd;

    onLookaheadNeeded(startIndex, precachEnd);
  }

  int _estimateVisibleIndex(double scrollPixels) {
    const estimatedItemHeight = 110.0;
    return (scrollPixels / estimatedItemHeight).floor();
  }

  @protected
  void onLookaheadNeeded(int startIndex, int endIndex);

  void precacheFromUrlList(List<String?> urls, int startIndex, int endIndex) {
    if (!mounted) return;
    final safeEnd = endIndex.clamp(0, urls.length);
    for (var i = startIndex; i < safeEnd; i++) {
      final url = urls[i];
      if (url != null && url.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }
  }
}
