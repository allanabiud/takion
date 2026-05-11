import 'dart:math' as math;
import 'package:flutter/material.dart';

class FloatingIconsBackground extends StatefulWidget {
  const FloatingIconsBackground({super.key});

  @override
  State<FloatingIconsBackground> createState() => _FloatingIconsBackgroundState();
}

class _FloatingIconsBackgroundState extends State<FloatingIconsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<_FloatingIcon> _icons = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );

    _initializeIcons();
  }

  void _initializeIcons() {
    // We use a grid to ensure even coverage, but add jitter and tilt 
    // to make it look less like a "perfect grid".
    const int columns = 5;
    const int rows = 8;
    const double cellWidth = 1.0 / columns;
    const double cellHeight = 1.0 / rows;

    const double iconSize = 22.0;

    for (int i = 0; i < columns; i++) {
      for (int j = 0; j < rows; j++) {
        // Center of the cell + random jitter (offset)
        // Jitter is limited to +/- 25% of the cell size to prevent overlaps
        final double jitterX = (_random.nextDouble() - 0.5) * 0.5 * cellWidth;
        final double jitterY = (_random.nextDouble() - 0.5) * 0.5 * cellHeight;
        
        final double centerX = (i + 0.5) * cellWidth + jitterX;
        final double centerY = (j + 0.5) * cellHeight + jitterY;

        _icons.add(_FloatingIcon(
          icon: _getAppSpecificIcon(),
          centerPosition: Offset(centerX, centerY),
          // Back and forth movement
          floatDirection: Offset(
            (_random.nextDouble() - 0.5) * 0.04,
            (_random.nextDouble() - 0.5) * 0.04,
          ),
          // Random tilt between -20 and +20 degrees
          rotation: (_random.nextDouble() - 0.5) * 0.7,
          size: iconSize,
          depth: _random.nextDouble(),
        ));
      }
    }
  }

  IconData _getAppSpecificIcon() {
    const icons = [
      Icons.collections_bookmark_outlined, // Library
      Icons.new_releases_outlined,        // New Releases
      Icons.shopping_bag_outlined,        // Pull List
      Icons.turned_in_not,                // Wishlist
      Icons.inventory_2_outlined,         // Collect/Inventory
      Icons.menu_book_outlined,           // Read/Reading
      Icons.bookmark_added_outlined,      // Read status
    ];
    return icons[_random.nextInt(icons.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _FloatingIconsPainter(
            icons: _icons,
            progress: _animation.value,
            baseColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _FloatingIcon {
  final IconData icon;
  final Offset centerPosition;
  final Offset floatDirection;
  final double rotation;
  final double size;
  final double depth;

  _FloatingIcon({
    required this.icon,
    required this.centerPosition,
    required this.floatDirection,
    required this.rotation,
    required this.size,
    required this.depth,
  });
}

class _FloatingIconsPainter extends CustomPainter {
  final List<_FloatingIcon> icons;
  final double progress;
  final Color baseColor;

  _FloatingIconsPainter({
    required this.icons,
    required this.progress,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final icon in icons) {
      final double dx = icon.centerPosition.dx + icon.floatDirection.dx * (progress - 0.5);
      final double dy = icon.centerPosition.dy + icon.floatDirection.dy * (progress - 0.5);

      final offset = Offset(dx * size.width, dy * size.height);
      
      final opacity = (1.0 - (icon.depth * 0.6)) * baseColor.opacity;
      
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: String.fromCharCode(icon.icon.codePoint),
          style: TextStyle(
            fontSize: icon.size,
            fontFamily: icon.icon.fontFamily,
            package: icon.icon.fontPackage,
            color: baseColor.withOpacity(opacity),
          ),
        ),
      );
      
      textPainter.layout();
      
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      // Apply the random tilt
      canvas.rotate(icon.rotation);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingIconsPainter oldDelegate) => 
      oldDelegate.progress != progress;
}
