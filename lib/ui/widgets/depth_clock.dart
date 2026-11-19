import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/clock_settings.dart';

/// Har soniyada qayta quriladigan vaqt manbai.
class ClockTicker extends StatefulWidget {
  const ClockTicker({super.key, required this.builder});
  final Widget Function(BuildContext, DateTime) builder;

  @override
  State<ClockTicker> createState() => _ClockTickerState();
}

class _ClockTickerState extends State<ClockTicker> {
  late DateTime _now = DateTime.now();
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      final n = DateTime.now();
      if (n.minute != _now.minute || n.hour != _now.hour) setState(() => _now = n);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now);
}

/// Cho'zilgan, minimalist raqamli soat. Eni/balandligi/qalinligi sozlanadi.
/// FittedBox(BoxFit.fill) matnni berilgan quti o'lchamiga cho'zadi.
class DepthClock extends StatelessWidget {
  const DepthClock({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<ClockSettings>();
    final size = MediaQuery.sizeOf(context);
    final w = size.width * s.width;
    final h = size.height * s.height;

    final style = TextStyle(
      fontSize: 300,
      height: 1,
      letterSpacing: -6,
      fontWeight: s.fontWeight,
      color: Colors.white,
    );

    return Positioned(
      top: size.height * s.top,
      left: 0,
      right: 0,
      child: Center(
        child: ClockTicker(
          builder: (_, now) {
            final hh = now.hour.toString().padLeft(2, '0');
            final mm = now.minute.toString().padLeft(2, '0');
            return Opacity(
              opacity: s.opacity,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (r) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white.withAlpha(215), const Color(0xFFBFE0FF)],
                ).createShader(r),
                child: SizedBox(
                  width: w,
                  height: h,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(hh, style: style),
                        Text(':', style: style.copyWith(letterSpacing: 0)),
                        Text(mm, style: style),
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
