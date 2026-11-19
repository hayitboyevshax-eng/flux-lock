import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/clock_settings.dart';

/// Qatlamli fon (tanlangan raqam: ClockSettings.wallpaper).
///  - foreground=false: orqa qatlam  assets/wallpapers/wN.jpg
///  - foreground=true : old qatlam   assets/wallpapers/wN_fg.webp (shaffof cutout)
/// Fayl topilmasa, protsedur manzara ishlatiladi. Soat ikki qatlam ORASIDA turadi.
class WallpaperLayer extends StatelessWidget {
  const WallpaperLayer({super.key, this.foreground = false});
  final bool foreground;

  @override
  Widget build(BuildContext context) {
    final n = context.select<ClockSettings, int>((s) => s.wallpaper);
    final procedural = CustomPaint(
      size: Size.infinite,
      painter: _ScenePainter(foreground: foreground),
    );
    if (foreground) {
      return IgnorePointer(
        child: Image.asset(
          'assets/wallpapers/w${n}_fg.webp',
          key: ValueKey('fg$n'),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => procedural,
        ),
      );
    }
    return Image.asset(
      'assets/wallpapers/w$n.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => procedural,
    );
  }
}

class _SceneRidge {
  static Path peak(Size s) {
    final w = s.width, h = s.height;
    return Path()
      ..moveTo(-w * .1, h)
      ..lineTo(-w * .1, h * .64)
      ..lineTo(w * .20, h * .53)
      ..lineTo(w * .36, h * .42)
      ..lineTo(w * .49, h * .31)
      ..lineTo(w * .55, h * .37)
      ..lineTo(w * .63, h * .36)
      ..lineTo(w * .80, h * .50)
      ..lineTo(w * 1.1, h * .62)
      ..lineTo(w * 1.1, h)
      ..close();
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({required this.foreground});
  final bool foreground;

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Offset.zero & s;
    if (!foreground) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A3FA8), Color(0xFF1C6FE0), Color(0xFF7DB8F5)],
          ).createShader(rect),
      );
      // uzoqdagi tizma
      final far = Path()
        ..moveTo(0, s.height * .6)
        ..lineTo(s.width * .25, s.height * .46)
        ..lineTo(s.width * .45, s.height * .55)
        ..lineTo(s.width * .75, s.height * .42)
        ..lineTo(s.width, s.height * .56)
        ..lineTo(s.width, s.height)
        ..lineTo(0, s.height)
        ..close();
      canvas.drawPath(far, Paint()..color = const Color(0xFF3F6FB8).withAlpha(150));
      return;
    }
    final peak = _SceneRidge.peak(s);
    canvas.drawPath(
      peak,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFD6E6FA), Color(0xFF4A5A78), Color(0xFF1B2638)],
          stops: [0, .35, .7, 1],
        ).createShader(rect),
    );
    // soya tomon
    final shade = Path()
      ..moveTo(s.width * .49, s.height * .31)
      ..lineTo(s.width * .55, s.height * .37)
      ..lineTo(s.width * .63, s.height * .36)
      ..lineTo(s.width * .80, s.height * .50)
      ..lineTo(s.width * .60, s.height * .58)
      ..lineTo(s.width * .52, s.height * .46)
      ..close();
    canvas.drawPath(shade, Paint()..color = const Color(0xFF2A3B5E).withAlpha(90));
    // pastdagi tuman
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * .72, s.width, s.height * .28),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withAlpha(0), Colors.white.withAlpha(70)],
        ).createShader(Rect.fromLTWH(0, s.height * .72, s.width, s.height * .28)),
    );
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.foreground != foreground;
}
