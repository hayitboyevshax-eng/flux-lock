import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clock_data.dart';

/// Liquid Glass: BackdropFilter + harakatlanuvchi yaltiroq nur
class GlassClock extends StatefulWidget {
  const GlassClock({super.key, required this.data});
  final ClockData data;
  @override
  State<GlassClock> createState() => _GlassClockState();
}

class _GlassClockState extends State<GlassClock> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 5));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant GlassClock old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.data.animate) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
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

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = Curves.easeInOut.transform(_c.value);
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(90), blurRadius: 50, offset: const Offset(0, 24)),
                  BoxShadow(color: const Color(0xFFB69CFF).withAlpha(40), blurRadius: 60, spreadRadius: -10),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(44),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 34),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      gradient: LinearGradient(
                        begin: Alignment(-1.6 + 3.2 * t, -1),
                        end: Alignment(-0.4 + 3.2 * t, 1),
                        colors: [
                          Colors.white.withAlpha(30),
                          Colors.white.withAlpha(105),
                          Colors.white.withAlpha(30),
                          Colors.white.withAlpha(55),
                        ],
                        stops: const [0, .35, .6, 1],
                      ),
                      border: Border.all(color: Colors.white.withAlpha(110), width: 1.3),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          d.weekday.toUpperCase(),
                          style: GoogleFonts.syne(
                              fontSize: 13, letterSpacing: 5, color: Colors.white.withAlpha(200), fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${d.hh}:${d.mm}',
                                style: GoogleFonts.syne(
                                  fontSize: 92,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  height: 1.05,
                                  fontFeatures: kTabular,
                                  shadows: [Shadow(color: Colors.white.withAlpha(120), blurRadius: 24)],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Text(
                                  d.ss,
                                  style: GoogleFonts.syne(
                                      fontSize: 28, color: Colors.white70, fontFeatures: kTabular),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${d.date}  ${d.period}'.trim(),
                          style: GoogleFonts.syne(fontSize: 15, color: Colors.white.withAlpha(210)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
