import "package:flutter/material.dart";
import "package:flutter/services.dart";

/// A button that executes a quick scale-and-rotation wiggle animation when toggled.
class WiggleFavoriteButton extends StatefulWidget {
  const WiggleFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.iconSize = 24,
    this.activeColor,
    this.inactiveColor,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  State<WiggleFavoriteButton> createState() => _WiggleFavoriteButtonState();
}

class _WiggleFavoriteButtonState extends State<WiggleFavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.15), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward(from: 0.0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? theme.colorScheme.outline;

    final tooltip = widget.isFavorite ? "Remove from favorites" : "Add to favorites";

    return IconButton(
      iconSize: widget.iconSize,
      tooltip: tooltip,
      onPressed: _handleTap,
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final disableAnimations =
              MediaQuery.maybeOf(context)?.disableAnimations ?? false;
          if (disableAnimations) {
            return Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? activeColor : inactiveColor,
              size: widget.iconSize,
            );
          }
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: widget.isFavorite ? activeColor : inactiveColor,
                size: widget.iconSize,
              ),
            ),
          );
        },
      ),
    );
  }
}
