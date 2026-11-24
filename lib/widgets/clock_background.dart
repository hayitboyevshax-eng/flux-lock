import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/clock_style.dart';

/// Orqa fon: Shaffof (sof qora, fon yo'q) / Gradient / Shisha
class ClockBackground extends StatefulWidget {
  const ClockBackground(
      {super.key, required this.type, required this.palette, required this.child, this.animate = true});
  final BgType type;
  final List<Color> palette;
  final Widget child;
  final bool animate;
  @override
  State<ClockBackground> createState() => _ClockBackgroundState();
}

class _ClockBackgroundState extends State<ClockBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 14));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant ClockBackground old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.animate) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _bg() {
    final p = widget.palette;
    switch (widget.type) {
      case BgType.transparent:
        return const ColoredBox(color: Colors.black);
      case BgType.gradient:
        return AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final a = _c.value * 2 * pi;
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(cos(a), sin(a)),
                  end: Alignment(-cos(a), -sin(a)),
                  colors: p,
                ),
              ),
            );
          },
        );
      case BgType.glass:
        return AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final a = _c.value * 2 * pi;
            Widget blob(Color c, double dx, double dy, double size) => Align(
                  alignment: Alignment(dx, dy),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: c.withAlpha(200)),
                  ),
                );
            return Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xFF07070B)),
                blob(p[2], .8 * cos(a), .7 * sin(a), 280),
                blob(p[1], -.8 * sin(a), .6 * cos(a), 320),
                blob(p[2], .5 * cos(a * 2), -.8 * sin(a), 220),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: ColoredBox(color: Colors.white.withAlpha(10)),
                ),
              ],
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: widget.animate ? 500 : 0),
          child: KeyedSubtree(key: ValueKey(widget.type), child: _bg()),
        ),
        widget.child,
      ],
    );
  }
}
