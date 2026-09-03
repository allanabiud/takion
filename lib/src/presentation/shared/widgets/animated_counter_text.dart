import "package:flutter/material.dart";

/// Smoothly animates numeric changes over a configurable duration and curve.
class AnimatedCounterText extends StatefulWidget {
  const AnimatedCounterText({
    super.key,
    this.value,
    this.text,
    this.style,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.formatter,
    this.prefix,
    this.suffix,
    this.fractionDigits,
  });

  final num? value;
  final String? text;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String Function(num count)? formatter;
  final String? prefix;
  final String? suffix;
  final int? fractionDigits;

  @override
  State<AnimatedCounterText> createState() => _AnimatedCounterTextState();
}

class _AnimatedCounterTextState extends State<AnimatedCounterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0.0;
  double _targetValue = 0.0;
  String _prefix = "";
  String _suffix = "";
  int _decimals = 0;

  @override
  void initState() {
    super.initState();
    _parseInput(initial: true);
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: _oldValue,
      end: _targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCounterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    final previousTarget = _targetValue;
    _parseInput(initial: false);
    if (_targetValue != previousTarget) {
      _oldValue = _animation.value;
      _animation = Tween<double>(
        begin: _oldValue,
        end: _targetValue,
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _controller.forward(from: 0.0);
    }
  }

  void _parseInput({required bool initial}) {
    if (widget.value != null) {
      _targetValue = widget.value!.toDouble();
      _prefix = widget.prefix ?? "";
      _suffix = widget.suffix ?? "";
      _decimals =
          widget.fractionDigits ??
          (widget.value is double && widget.value! % 1 != 0 ? 1 : 0);
    } else if (widget.text != null) {
      final raw = widget.text!;
      final match = RegExp(
        r"^([^\d.-]*)([-+]?\d+(?:,\d{3})*(?:\.\d+)?)(.*)$",
      ).firstMatch(raw.trim());
      if (match != null) {
        _prefix = widget.prefix ?? match.group(1) ?? "";
        final numStr = (match.group(2) ?? "0").replaceAll(",", "");
        _targetValue = double.tryParse(numStr) ?? 0.0;
        _suffix = widget.suffix ?? match.group(3) ?? "";
        if (widget.fractionDigits != null) {
          _decimals = widget.fractionDigits!;
        } else if (numStr.contains(".")) {
          _decimals = numStr.split(".").last.length;
        } else {
          _decimals = 0;
        }
      } else {
        _prefix = widget.prefix ?? "";
        _suffix = widget.suffix ?? "";
        _targetValue = double.tryParse(raw) ?? 0.0;
        _decimals = widget.fractionDigits ?? 0;
      }
    } else {
      _targetValue = 0.0;
      _prefix = widget.prefix ?? "";
      _suffix = widget.suffix ?? "";
      _decimals = widget.fractionDigits ?? 0;
    }

    if (initial) {
      _oldValue = _targetValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double val) {
    if (widget.formatter != null) {
      return widget.formatter!(val);
    }
    String numPart;
    if (_decimals == 0) {
      numPart = val.round().toString();
    } else {
      numPart = val.toStringAsFixed(_decimals);
    }
    return "$_prefix$numPart$_suffix";
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      return Text(
        _formatNumber(_targetValue),
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          _formatNumber(_animation.value),
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
