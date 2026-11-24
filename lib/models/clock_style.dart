import 'package:flutter/material.dart';

enum ClockStyle { hyperOs, liquidGlass, dotMatrix, neon, gold }

enum BgType { transparent, gradient, glass }

extension ClockStylePalette on ClockStyle {
  /// Orqa fon gradienti / blob ranglari
  List<Color> get palette => switch (this) {
        ClockStyle.hyperOs => const [Color(0xFF0B1026), Color(0xFF1B2A6B), Color(0xFF6C3BFF)],
        ClockStyle.liquidGlass => const [Color(0xFF0F2027), Color(0xFF2C5364), Color(0xFF8E54E9)],
        ClockStyle.dotMatrix => const [Color(0xFF000000), Color(0xFF0C0C0C), Color(0xFF2A0707)],
        ClockStyle.neon => const [Color(0xFF05010F), Color(0xFF1A0033), Color(0xFF00394D)],
        ClockStyle.gold => const [Color(0xFF050505), Color(0xFF14110A), Color(0xFF2E2411)],
      };

  Color get accent => switch (this) {
        ClockStyle.hyperOs => const Color(0xFF8FA8FF),
        ClockStyle.liquidGlass => const Color(0xFFB69CFF),
        ClockStyle.dotMatrix => const Color(0xFFFF2D2D),
        ClockStyle.neon => const Color(0xFF00F0FF),
        ClockStyle.gold => const Color(0xFFD4AF37),
      };
}
