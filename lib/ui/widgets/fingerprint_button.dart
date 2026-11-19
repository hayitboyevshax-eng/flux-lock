import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ekran ichidagi barmoq izi: nafas oluvchi halqa + skanerlash chizig'i.
class FingerprintButton extends StatefulWidget {
  const FingerprintButton({super.key, required this.onAuth, required this.onSuccess});
  final Future<bool> Function() onAuth;
  final VoidCallback onSuccess;

  @override
  State<FingerprintButton> createState() => _FingerprintButtonState();
}

class _FingerprintButtonState extends State<FingerprintButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  bool _scan = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    if (_scan) return;
    setState(() => _scan = true);
    HapticFeedback.lightImpact();
    final ok = await widget.onAuth();
    if (!mounted) return;
    setState(() => _scan = false);
    if (ok) {
      HapticFeedback.mediumImpact();
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _go,
      child: SizedBox(
        width: 84,
        height: 84,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(
            painter: _FpPainter(_c.value, _scan),
            child: Center(
              child: Icon(Icons.fingerprint,
                  size: 46, color: Colors.white.withAlpha(_scan ? 255 : 210)),
            ),
          ),
        ),
      ),
    );
  }
}

class _FpPainter extends CustomPainter {
  _FpPainter(this.t, this.scan);
  final double t;
  final bool scan;

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final pulse = (sin(t * 2 * pi) + 1) / 2;
    canvas.drawCircle(
      c,
      32 + pulse * 6,
      Paint()
        ..color = Colors.white.withAlpha((40 + pulse * 40).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(c, 30, Paint()..color = Colors.white.withAlpha(scan ? 55 : 22));
    if (scan) {
      final y = c.dy - 24 + 48 * ((sin(t * 4 * pi) + 1) / 2);
      canvas.drawLine(
        Offset(c.dx - 22, y),
        Offset(c.dx + 22, y),
        Paint()
          ..color = const Color(0xFF8FD3FF)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_FpPainter o) => true;
}
