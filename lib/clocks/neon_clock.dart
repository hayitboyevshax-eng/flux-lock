import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clock_data.dart';

/// Neon Cyberpunk: yarqirash, glitch, skanlayn va harakatlanuvchi to'r
class NeonClock extends StatefulWidget {
  const NeonClock({super.key, required this.data});
  final ClockData data;
  @override
  State<NeonClock> createState() => _NeonClockState();
}

class _NeonClockState extends State<NeonClock> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 10));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant NeonClock old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.data.animate) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = 0.3;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static const _cyan = Color(0xFF00F0FF);
  static const _pink = Color(0xFFFF2BD6);

  Widget _txt(String s, Color c, double size, {double blur = 1}) => Text(
        s,
        style: GoogleFonts.orbitron(
          fontSize: size,
          fontWeight: FontWeight.w800,
          color: c,
          fontFeatures: kTabular,
          shadows: [
            Shadow(color: c, blurRadius: 6 * blur),
            Shadow(color: c.withAlpha(200), blurRadius: 18 * blur),
            Shadow(color: c.withAlpha(140), blurRadius: 40 * blur),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        final flick = sin(t * 2 * pi * 37) * sin(t * 2 * pi * 11);
        final op = flick > .93 ? .55 : 1.0;
        final glitch = (t * 10) % 1 > .96;
        final off = glitch ? 4.0 : 0.0;
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 240,
              child: CustomPaint(painter: _GridPainter(t)),
            ),
            Center(
              child: Opacity(
                opacity: op,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _txt(d.weekday.toUpperCase(), _pink, 14, blur: .6),
                      const SizedBox(height: 14),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Stack(
                          children: [
                            if (glitch)
                              Transform.translate(
                                  offset: Offset(-off, 0), child: _txt('${d.hh}:${d.mm}', _pink, 84, blur: .3)),
                            Transform.translate(
                                offset: Offset(off, 0), child: _txt('${d.hh}:${d.mm}', _cyan, 84)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _txt(d.ss, _pink, 34, blur: .8),
                      const SizedBox(height: 18),
                      _txt('${d.date} ${d.period}'.trim(), _cyan, 12, blur: .4),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _ScanPainter(t, d.animate)))),
          ],
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.t);
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFFF2BD6).withAlpha(80)
      ..strokeWidth = 1;
    for (var i = 0; i < 12; i++) {
      final f = ((i + t * 12) % 12) / 12;
      final y = size.height * f * f;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    for (var i = -8; i <= 8; i++) {
      canvas.drawLine(Offset(size.width / 2 + i * 6, 0), Offset(size.width / 2 + i * size.width / 8, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter o) => true;
}

class _ScanPainter extends CustomPainter {
  _ScanPainter(this.t, this.sweep);
  final double t;
  final bool sweep;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black.withAlpha(35);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.5), p);
    }
    if (!sweep) return;
    final y = size.height * ((t * 4) % 1);
    final r = Rect.fromLTWH(0, y, size.width, 60);
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, const Color(0xFF00F0FF).withAlpha(22), Colors.transparent],
        ).createShader(r),
    );
  }

  @override
  bool shouldRepaint(covariant _ScanPainter o) => true;
}
