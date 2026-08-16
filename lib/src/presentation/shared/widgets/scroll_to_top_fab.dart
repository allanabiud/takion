import "package:flutter/material.dart";

class ScrollToTopFab extends StatefulWidget {
  const ScrollToTopFab({
    super.key,
    required this.controller,
    this.showAt = 400,
  });

  final ScrollController controller;
  final double showAt;

  @override
  State<ScrollToTopFab> createState() => _ScrollToTopFabState();
}

class _ScrollToTopFabState extends State<ScrollToTopFab> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients) return;
    final shouldShow = widget.controller.offset > widget.showAt;
    if (shouldShow != _show) {
      setState(() => _show = shouldShow);
    }
  }

  void _scrollToTop() {
    if (!widget.controller.hasClients) return;
    widget.controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    return FloatingActionButton(
      heroTag: null,
      onPressed: _scrollToTop,
      child: const Icon(Icons.arrow_upward, size: 26),
    );
  }
}