import "package:flutter/material.dart";

/// App bar title that animates between values in a continuous conveyor motion.
///
/// When [title] changes, the outgoing title slides upward out of view while the
/// incoming title slides up into place from below. Unlike an `AnimatedSwitcher`
/// cross-fade, both titles move in the same direction and never linger fading,
/// so tab switches read as one smooth push.
///
/// The widget lays out to the wider of the outgoing/incoming titles and centers
/// each title horizontally inside it. Because the box itself is centered by the
/// [AppBar], the incoming title stays centered throughout the animation (no
/// horizontal drift), and titles keep their natural width (no ellipsis).
class AnimatedAppBarTitle extends StatefulWidget {
  const AnimatedAppBarTitle({
    super.key,
    required this.title,
    required this.style,
    this.duration = const Duration(milliseconds: 220),
  });

  final String title;
  final TextStyle style;
  final Duration duration;

  @override
  State<AnimatedAppBarTitle> createState() => _AnimatedAppBarTitleState();
}

class _AnimatedAppBarTitleState extends State<AnimatedAppBarTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  String? _previousTitle;
  Size? _newSize;
  Size? _previousSize;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _previousTitle = null);
      }
    });
    _newSize = _measure(widget.title, widget.style);
  }

  @override
  void didUpdateWidget(covariant AnimatedAppBarTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _previousSize = _newSize;
      _newSize = _measure(widget.title, widget.style);
      setState(() => _previousTitle = oldWidget.title);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  Size _measure(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return Size(painter.width, painter.height);
  }

  Text _title(String text, TextStyle style) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: style,
  );

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final previous = _previousTitle;
    final newSize = _newSize;

    if (newSize == null) return _title(widget.title, style);

    final oldWidth = _previousSize?.width ?? 0;
    final width = previous == null || newSize.width >= oldWidth
        ? newSize.width
        : oldWidth;
    final height = newSize.height;

    if (previous == null) {
      return SizedBox(
        width: width,
        height: height,
        child: Align(
          alignment: Alignment.topCenter,
          child: _title(widget.title, style),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) {
        final t = _curve.value;

        return SizedBox(
          width: width,
          height: height,
          child: ClipRect(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                FractionalTranslation(
                  translation: Offset(0, -t),
                  child: _title(previous, style),
                ),
                FractionalTranslation(
                  translation: Offset(0, 1 - t),
                  child: _title(widget.title, style),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}