import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clock_data.dart';

/// Nothing OS uslubidagi nuqtali matritsa (5x7)
const Map<String, List<int>> _glyph = {
  '0': [0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E],
  '1': [0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E],
  '2': [0x0E, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1F],
  '3': [0x1F, 0x02, 0x04, 0x02, 0x01, 0x11, 0x0E],
  '4': [0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02],
  '5': [0x1F, 0x10, 0x1E, 0x01, 0x01, 0x11, 0x0E],
  '6': [0x06, 0x08, 0x10, 0x1E, 0x11, 0x11, 0x0E],
  '7': [0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08],
  '8': [0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E],
  '9': [0x0E, 0x11, 0x11, 0x0F, 0x01, 0x02, 0x0C],
  ':': [0x00, 0x02, 0x00, 0x00, 0x00, 0x02, 0x00], // 3 ustun
};

int _width(String ch) => ch == ':' ? 3 : 5;
int _cols(String s) => s.split('').fold<int>(0, (a, c) => a + _width(c)) + (s.length - 1);

class DotMatrixClock extends StatefulWidget {
  const DotMatrixClock({super.key, required this.data});
  final ClockData data;
  @override
  State<DotMatrixClock> createState() => _DotMatrixClockState();
}

class _DotMatrixClockState extends State<DotMatrixClock> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant DotMatrixClock old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.data.animate) {
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

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final main = '${d.hh}:${d.mm}';
    final w = MediaQuery.of(context).size.width - 56;
    final sw = w * .38;
    return Center(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final colon = !d.animate || d.now.second.isEven;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                d.weekday.toUpperCase(),
                style: GoogleFonts.spaceMono(fontSize: 13, letterSpacing: 5, color: const Color(0xFFFF2D2D)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: w,
                height: w * 7 / _cols(main),
                child: CustomPaint(painter: _DotPainter(main, _c.value, colon, d.animate)),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: sw,
                height: sw * 7 / _cols(d.ss),
                child: CustomPaint(painter: _DotPainter(d.ss, _c.value, true, d.animate)),
              ),
              const SizedBox(height: 26),
              Text(
                '${d.date} ${d.period}'.trim(),
                style: GoogleFonts.spaceMono(fontSize: 13, color: Colors.white54, fontFeatures: kTabular),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter(this.text, this.t, this.colonOn, this.animate);
  final String text;
  final double t;
  final bool colonOn;
  final bool animate;

  static const _on = Color(0xFFFF2D2D);

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / _cols(text);
    final r = unit * .38;
    final off = Paint()..color = const Color(0xFF2A2A2A);
    var x = 0;
    for (final ch in text.split('')) {
      final g = _glyph[ch]!;
      final w = _width(ch);
      for (var row = 0; row < 7; row++) {
        for (var c = 0; c < w; c++) {
          final bit = ((g[row] >> (w - 1 - c)) & 1) == 1;
          final lit = bit && (ch != ':' || colonOn);
          final cx = (x + c + .5) * unit, cy = (row + .5) * unit;
          if (!lit) {
            canvas.drawCircle(Offset(cx, cy), r * .85, off);
            continue;
          }
          // yugurib o'tuvchi to'lqin
          final wave = animate ? .78 + .22 * sin((x + c) * .6 - t * 2 * pi) : 1.0;
          canvas.drawCircle(
            Offset(cx, cy),
            r * 1.5,
            Paint()
              ..color = _on.withAlpha((110 * wave).round())
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, unit * .45),
          );
          canvas.drawCircle(
              Offset(cx, cy), r * (.96 + .06 * wave), Paint()..color = _on.withAlpha((255 * wave).round()));
        }
      }
      x += w + 1;
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter o) => true;
}
