import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clock_data.dart';

/// Minimalist Gold: oltin gradient va uzluksiz yaltirash (shimmer)
class GoldClock extends StatefulWidget {
  const GoldClock({super.key, required this.data});
  final ClockData data;
  @override
  State<GoldClock> createState() => _GoldClockState();
}

class _Slide extends GradientTransform {
  const _Slide(this.p);
  final double p;
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * p, 0, 0);
}

class _GoldClockState extends State<GoldClock> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant GoldClock old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.data.animate) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = 0.5;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static const _g1 = Color(0xFF8A6A1F);
  static const _g2 = Color(0xFFD4AF37);
  static const _g3 = Color(0xFFFFF1B8);

  Widget _gold(Widget child, double p) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(
          colors: const [_g1, _g2, _g3, _g2, _g1],
          tileMode: TileMode.repeated,
          transform: _Slide(p),
        ).createShader(r),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Center(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final p = _c.value * 2 - 1;
          final line = Container(width: 48, height: 1, color: _g2.withAlpha(160));
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  line,
                  const SizedBox(width: 14),
                  Text(d.weekday.toUpperCase(),
                      style: GoogleFonts.bebasNeue(fontSize: 20, letterSpacing: 8, color: _g2)),
                  const SizedBox(width: 14),
                  line,
                ]),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _gold(
                    Text(
                      '${d.hh}:${d.mm}',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 170,
                        color: Colors.white,
                        height: 1,
                        letterSpacing: 4,
                        fontFeatures: kTabular,
                      ),
                    ),
                    p,
                  ),
                ),
                _gold(
                  Text(d.ss,
                      style: GoogleFonts.bebasNeue(
                          fontSize: 38, color: Colors.white, letterSpacing: 6, fontFeatures: kTabular)),
                  p,
                ),
                const SizedBox(height: 18),
                Text(
                  '${d.date} ${d.period}'.trim().toUpperCase(),
                  style: GoogleFonts.bebasNeue(fontSize: 18, letterSpacing: 4, color: _g2.withAlpha(210)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
