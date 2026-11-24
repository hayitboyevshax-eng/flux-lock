import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clock_data.dart';

/// HyperOS Depth: qatlamli soya + parallaks, suzib yuruvchi chuqurlik
class HyperOsClock extends StatefulWidget {
  const HyperOsClock({super.key, required this.data});
  final ClockData data;
  @override
  State<HyperOsClock> createState() => _HyperOsClockState();
}

class _HyperOsClockState extends State<HyperOsClock> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 8));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant HyperOsClock old) {
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

  TextStyle _style(Color c) => GoogleFonts.syne(
        fontSize: 110,
        fontWeight: FontWeight.w800,
        color: c,
        height: 1,
        letterSpacing: -3,
        fontFeatures: kTabular,
      );

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final txt = '${d.hh}:${d.mm}';
    return Center(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final a = _c.value * 2 * pi;
          final dx = sin(a) * 5, dy = cos(a) * 5;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  d.weekday.toUpperCase(),
                  style: GoogleFonts.syne(
                      fontSize: 14, letterSpacing: 6, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      for (var i = 3; i >= 1; i--)
                        Transform.translate(
                          offset: Offset(dx * i * .6, dy * i * .6 + i * 5.0),
                          child: Text(txt, style: _style(const Color(0xFF6C8CFF).withAlpha(18 + (4 - i) * 14))),
                        ),
                      ShaderMask(
                        shaderCallback: (r) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Color(0xFFB8C4FF)],
                        ).createShader(r),
                        child: Transform.translate(
                          offset: Offset(-dx * .3, -dy * .3),
                          child: Text(txt, style: _style(Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: d.secondProgress,
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF8FA8FF)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '${d.date}  ${d.period}'.trim(),
                  style: GoogleFonts.syne(fontSize: 16, color: Colors.white60, fontFeatures: kTabular),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
