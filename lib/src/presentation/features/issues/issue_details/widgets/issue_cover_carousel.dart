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
    this.previousImageUrl,
    this.nextImageUrl,
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
  final String? previousImageUrl;
  final String? nextImageUrl;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onTapCover;
  final double width;
  final double height;

  @override
  State<IssueCoverCarousel> createState() => _IssueCoverCarouselState();
}

class _IssueCoverCarouselState extends State<IssueCoverCarousel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _exitSlideAnimation;
  late Animation<double> _exitFadeAnimation;
  late Animation<double> _exitScaleAnimation;
  late Animation<Offset> _enterSlideAnimation;
  late Animation<double> _enterFadeAnimation;
  late Animation<double> _enterScaleAnimation;

  late AnimationController _dragSettleController;
  late Animation<double> _dragSettleAnimation;

  late int _displayedIssueId;
  String? _displayedImageUrl;
  int? _outgoingIssueId;
  String? _outgoingImageUrl;
  int _activeDirection = 1;

  double _dragOffset = 0.0;
  bool _isDragging = false;
  bool _navigatedViaDrag = false;

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

    _dragSettleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _dragSettleAnimation = const AlwaysStoppedAnimation(0.0);

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
      if (_navigatedViaDrag) {
        _navigatedViaDrag = false;
        _displayedIssueId = widget.currentIssueId;
        _displayedImageUrl = widget.currentImageUrl;
        _outgoingIssueId = null;
        _outgoingImageUrl = null;
        return;
      }

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
    _dragSettleController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_controller.isAnimating || _dragSettleController.isAnimating) return;
    _isDragging = true;
    _dragOffset = 0.0;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final delta = details.primaryDelta ?? 0.0;
    final nextAllowed = widget.nextIssueId != null;
    final prevAllowed = widget.previousIssueId != null;

    setState(() {
      final newOffset = _dragOffset + delta;
      if (newOffset < 0 && !nextAllowed) {
        // Friction resistance when no next issue
        _dragOffset += delta * 0.25;
      } else if (newOffset > 0 && !prevAllowed) {
        // Friction resistance when no previous issue
        _dragOffset += delta * 0.25;
      } else {
        _dragOffset = newOffset;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0.0;
    final nextAllowed = widget.nextIssueId != null;
    final prevAllowed = widget.previousIssueId != null;

    final threshold = widget.width * 0.35;
    final shouldAdvanceNext =
        nextAllowed &&
        (_dragOffset < -threshold || (velocity < -300 && _dragOffset < -20));
    final shouldAdvancePrev =
        prevAllowed &&
        (_dragOffset > threshold || (velocity > 300 && _dragOffset > 20));

    if (shouldAdvanceNext) {
      _animateSettle(
        targetOffset: -widget.width,
        onComplete: () {
          _navigatedViaDrag = true;
          HapticFeedback.lightImpact();
          widget.onNext?.call();
        },
      );
    } else if (shouldAdvancePrev) {
      _animateSettle(
        targetOffset: widget.width,
        onComplete: () {
          _navigatedViaDrag = true;
          HapticFeedback.lightImpact();
          widget.onPrevious?.call();
        },
      );
    } else {
      _animateSettle(targetOffset: 0.0);
    }
  }

  void _onHorizontalDragCancel() {
    if (!_isDragging) return;
    _isDragging = false;
    _animateSettle(targetOffset: 0.0);
  }

  void _animateSettle({
    required double targetOffset,
    VoidCallback? onComplete,
  }) {
    _dragSettleAnimation = Tween<double>(begin: _dragOffset, end: targetOffset)
        .animate(
          CurvedAnimation(
            parent: _dragSettleController,
            curve: Curves.easeOutCubic,
          ),
        );

    _dragSettleController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _dragOffset = 0.0;
      });
      onComplete?.call();
    });
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

  Widget _buildInteractiveCarouselContent(BuildContext context, double offset) {
    final progress = (offset / widget.width).clamp(-1.0, 1.0);
    final currentScale = (1.0 - 0.08 * progress.abs()).clamp(0.92, 1.0);
    final currentOpacity = (1.0 - 0.3 * progress.abs()).clamp(0.0, 1.0);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Next issue peek/slide (when dragging left, offset < 0)
          if (offset < 0 && widget.nextIssueId != null) ...[
            Builder(
              builder: (context) {
                final nextOffset = (widget.width + 12) + offset;
                final nextScale = (0.92 + 0.08 * (-progress)).clamp(0.92, 1.0);
                final nextOpacity = (0.35 + 0.65 * (-progress)).clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(nextOffset, 0),
                  child: Transform.scale(
                    scale: nextScale,
                    child: Opacity(
                      opacity: nextOpacity,
                      child: _buildCoverCard(
                        context: context,
                        issueId: widget.nextIssueId!,
                        imageUrl: widget.nextImageUrl,
                        isInteractive: false,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          // Previous issue peek/slide (when dragging right, offset > 0)
          if (offset > 0 && widget.previousIssueId != null) ...[
            Builder(
              builder: (context) {
                final prevOffset = (-widget.width - 12) + offset;
                final prevScale = (0.92 + 0.08 * progress).clamp(0.92, 1.0);
                final prevOpacity = (0.35 + 0.65 * progress).clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(prevOffset, 0),
                  child: Transform.scale(
                    scale: prevScale,
                    child: Opacity(
                      opacity: prevOpacity,
                      child: _buildCoverCard(
                        context: context,
                        issueId: widget.previousIssueId!,
                        imageUrl: widget.previousImageUrl,
                        isInteractive: false,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          // Active current cover tracking finger
          Transform.translate(
            offset: Offset(offset, 0),
            child: Transform.scale(
              scale: currentScale,
              child: Opacity(
                opacity: currentOpacity,
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget centerContent;
    if (_isDragging ||
        _dragSettleController.isAnimating ||
        _dragOffset != 0.0) {
      if (_dragSettleController.isAnimating) {
        centerContent = AnimatedBuilder(
          animation: _dragSettleAnimation,
          builder: (context, _) => _buildInteractiveCarouselContent(
            context,
            _dragSettleAnimation.value,
          ),
        );
      } else {
        centerContent = _buildInteractiveCarouselContent(context, _dragOffset);
      }
    } else if (_outgoingIssueId != null) {
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
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onHorizontalDragCancel: _onHorizontalDragCancel,
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
