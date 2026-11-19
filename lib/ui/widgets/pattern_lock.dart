import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 3x3 chizmali parol. onSubmit true => tozalanadi, false => qizil rangda yonib tozalanadi.
class PatternLock extends StatefulWidget {
  const PatternLock({super.key, required this.onSubmit});
  final Future<bool> Function(List<int> nodes) onSubmit;

  @override
  State<PatternLock> createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock> {
  static const _side = 260.0;
  final List<int> _sel = [];
  Offset? _cur;
  bool _err = false;

  List<Offset> get _centers => [
        for (var i = 0; i < 9; i++)
          Offset((i % 3 + .5) * _side / 3, (i ~/ 3 + .5) * _side / 3),
      ];

  void _hit(Offset p) {
    final c = _centers;
    for (var i = 0; i < 9; i++) {
      if (!_sel.contains(i) && (c[i] - p).distance < _side / 3 * .3) {
        _sel.add(i);
        HapticFeedback.selectionClick();
        break;
      }
    }
    setState(() => _cur = p);
  }

  Future<void> _end() async {
    final ok = _sel.length >= 4 && await widget.onSubmit(List.of(_sel));
    if (!mounted) return;
    if (!ok) {
      HapticFeedback.heavyImpact();
      setState(() {
        _err = true;
        _cur = null;
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (!mounted) return;
    setState(() {
      _sel.clear();
      _cur = null;
      _err = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) => _hit(d.localPosition),
      onPanUpdate: (d) => _hit(d.localPosition),
      onPanEnd: (_) => _end(),
      child: CustomPaint(
        size: const Size(_side, _side),
        painter: _PatternPainter(_centers, List.of(_sel), _cur, _err),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter(this.c, this.sel, this.cur, this.err);
  final List<Offset> c;
  final List<int> sel;
  final Offset? cur;
  final bool err;

  @override
  void paint(Canvas canvas, Size size) {
    final col = err ? const Color(0xFFFF5A5A) : Colors.white;
    final line = Paint()
      ..color = col.withAlpha(190)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < sel.length - 1; i++) {
      canvas.drawLine(c[sel[i]], c[sel[i + 1]], line);
    }
    if (sel.isNotEmpty && cur != null) canvas.drawLine(c[sel.last], cur!, line);
    for (var i = 0; i < 9; i++) {
      final on = sel.contains(i);
      canvas.drawCircle(c[i], on ? 11 : 6, Paint()..color = on ? col : Colors.white70);
      if (on) {
        canvas.drawCircle(
            c[i],
            26,
            Paint()
              ..color = col.withAlpha(90)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter o) => true;
}
