import 'dart:async';
import 'package:flutter/material.dart';

import '../clocks/clock_data.dart';
import '../clocks/dotmatrix_clock.dart';
import '../clocks/glass_clock.dart';
import '../clocks/gold_clock.dart';
import '../clocks/hyperos_clock.dart';
import '../clocks/neon_clock.dart';
import '../models/clock_style.dart';
import '../models/settings_controller.dart';
import '../widgets/clock_background.dart';
import '../widgets/settings_sheet.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key, required this.settings});
  final SettingsController settings;
  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  // Har soniya boshida aniq yangilanadi
  void _tick() {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: 1000 - DateTime.now().millisecond), () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _tick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _clock(ClockStyle s, ClockData d) => switch (s) {
        ClockStyle.hyperOs => HyperOsClock(data: d),
        ClockStyle.liquidGlass => GlassClock(data: d),
        ClockStyle.dotMatrix => DotMatrixClock(data: d),
        ClockStyle.neon => NeonClock(data: d),
        ClockStyle.gold => GoldClock(data: d),
      };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (ctx, _) {
        final s = widget.settings;
        final data = ClockData(
          now: _now,
          use24h: s.use24h,
          locale: Localizations.localeOf(ctx).toString(),
          animate: s.animations,
        );
        return ClockBackground(
          type: s.bg,
          animate: s.animations,
          palette: s.style.palette,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: s.animations ? 600 : 0),
                      child: KeyedSubtree(key: ValueKey(s.style), child: _clock(s.style, data)),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded, color: Colors.white70),
                      onPressed: () => showSettingsSheet(ctx, s),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
