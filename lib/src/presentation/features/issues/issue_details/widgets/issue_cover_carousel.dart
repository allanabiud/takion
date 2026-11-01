import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class IssueCoverCarousel extends StatefulWidget {
  const IssueCoverCarousel({
    super.key,
    required this.currentIssueId,
    required this.currentImageUrl,
    required this.slideDirection,
    this.previousIssueId,
    this.nextIssueId,
    this.onPrevious,
    this.onNext,
    this.onTapCover,
    this.width = 180,
    this.height = 270,
  });

  final int currentIssueId;
  final String? currentImageUrl;
  final int
  slideDirection; // 1 for next/right-to-left, -1 for previous/left-to-right, 0 for initial
  final int? previousIssueId;
  final int? nextIssueId;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onTapCover;
  final double width;
  final double height;

  @override
  State<IssueCoverCarousel> createState() => _IssueCoverCarouselState();
}

class _IssueCoverCarouselState extends State<IssueCoverCarousel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _exitSlideAnimation;
  late Animation<double> _exitFadeAnimation;
  late Animation<double> _exitScaleAnimation;
  late Animation<Offset> _enterSlideAnimation;
  late Animation<double> _enterFadeAnimation;
  late Animation<double> _enterScaleAnimation;

  late int _displayedIssueId;
  String? _displayedImageUrl;
  int? _outgoingIssueId;
  String? _outgoingImageUrl;
  int _activeDirection = 1;

  @override
  void initState() {
    super.initState();
    _displayedIssueId = widget.currentIssueId;
    _displayedImageUrl = widget.currentImageUrl;
    _activeDirection = widget.slideDirection == 0 ? 1 : widget.slideDirection;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _buildAnimations();
    _controller.value = 1.0;

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _outgoingIssueId = null;
          _outgoingImageUrl = null;
        });
      }
    });
  }

  void _buildAnimations() {
    final dir = _activeDirection == 0 ? 1 : _activeDirection;

    // Phase 1 (0.0 -> 0.48): Outgoing cover slides off and fades out first
    _exitSlideAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: Offset(-dir * 1.15, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.48, curve: Curves.easeInCubic),
          ),
        );

    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.48, curve: Curves.easeIn),
      ),
    );

    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.48, curve: Curves.easeInCubic),
      ),
    );

    // Phase 2 (0.42 -> 1.0): Incoming cover slides in smoothly right behind the old one
    _enterSlideAnimation =
        Tween<Offset>(begin: Offset(dir * 1.15, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.42, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _enterFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.42, 0.88, curve: Curves.easeOut),
      ),
    );

    _enterScaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.42, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(IssueCoverCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIssueId != oldWidget.currentIssueId) {
      _outgoingIssueId = _displayedIssueId;
      _outgoingImageUrl = _displayedImageUrl;
      _displayedIssueId = widget.currentIssueId;
      _displayedImageUrl = widget.currentImageUrl;
      _activeDirection = widget.slideDirection == 0 ? 1 : widget.slideDirection;
      _buildAnimations();
      _controller.forward(from: 0.0);
    } else if (widget.currentImageUrl != oldWidget.currentImageUrl) {
      setState(() {
        _displayedImageUrl = widget.currentImageUrl;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -200 && widget.nextIssueId != null) {
      HapticFeedback.lightImpact();
      widget.onNext?.call();
    } else if (velocity > 200 && widget.previousIssueId != null) {
      HapticFeedback.lightImpact();
      widget.onPrevious?.call();
    }
  }

  Widget _buildCoverCard({
    required BuildContext context,
    required int issueId,
    required String? imageUrl,
    required bool isInteractive,
  }) {
    final theme = Theme.of(context);
    final card = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.trim().isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 720,
              placeholder: (context, url) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image, size: 48),
              ),
            )
          : Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image, size: 48),
            ),
    );

    if (!isInteractive) {
      return card;
    }

    return GestureDetector(
      onTap: widget.onTapCover,
      child: Hero(tag: "issue-cover-$issueId", child: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget centerContent;
    if (_outgoingIssueId != null) {
      centerContent = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Phase 1: Old cover slides off in exit direction first
                SlideTransition(
                  position: _exitSlideAnimation,
                  child: ScaleTransition(
                    scale: _exitScaleAnimation,
                    child: FadeTransition(
                      opacity: _exitFadeAnimation,
                      child: _buildCoverCard(
                        context: context,
                        issueId: _outgoingIssueId!,
                        imageUrl: _outgoingImageUrl,
                        isInteractive: false,
                      ),
                    ),
                  ),
                ),
                // Phase 2: New cover slides in continuously behind it
                SlideTransition(
                  position: _enterSlideAnimation,
                  child: ScaleTransition(
                    scale: _enterScaleAnimation,
                    child: FadeTransition(
                      opacity: _enterFadeAnimation,
                      child: _buildCoverCard(
                        context: context,
                        issueId: _displayedIssueId,
                        imageUrl: _displayedImageUrl,
                        isInteractive: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      centerContent = SizedBox(
        width: widget.width,
        height: widget.height,
        child: _buildCoverCard(
          context: context,
          issueId: _displayedIssueId,
          imageUrl: _displayedImageUrl,
          isInteractive: true,
        ),
      );
    }

    return GestureDetector(
      onHorizontalDragEnd: _handleSwipe,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: "Previous Issue",
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.85),
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                disabledBackgroundColor: theme
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.35),
                disabledForegroundColor: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.35),
                shape: const CircleBorder(),
                fixedSize: const Size(38, 38),
                padding: EdgeInsets.zero,
              ),
              onPressed: widget.previousIssueId == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      widget.onPrevious?.call();
                    },
            ),
            const SizedBox(width: 10),
            centerContent,
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: "Next Issue",
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.85),
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                disabledBackgroundColor: theme
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.35),
                disabledForegroundColor: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.35),
                shape: const CircleBorder(),
                fixedSize: const Size(38, 38),
                padding: EdgeInsets.zero,
              ),
              onPressed: widget.nextIssueId == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      widget.onNext?.call();
                    },
            ),
          ],
        ),
      ),
    );
  }
}
