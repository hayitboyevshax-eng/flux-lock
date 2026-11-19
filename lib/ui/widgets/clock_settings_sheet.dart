import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/clock_settings.dart';
import '../../core/strings.dart';

/// Soat o'lchamlarini sozlash paneli (faqat autentifikatsiyadan keyin ochiladi).
class ClockSettingsSheet extends StatelessWidget {
  const ClockSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final s = context.watch<ClockSettings>();
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xE6101722),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.t('settings'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ClockSettings.wallpaperCount,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final n = i + 1;
                  final on = s.wallpaper == n;
                  return GestureDetector(
                    onTap: () => s.update(wallpaper: n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: on ? Colors.white : Colors.transparent, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/wallpapers/w$n.jpg',
                            fit: BoxFit.cover, cacheWidth: 180),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _Slider(t.t('width'), s.width, .3, 1, (v) => s.update(width: v)),
            _Slider(t.t('height'), s.height, .1, .5, (v) => s.update(height: v)),
            _Slider(t.t('top'), s.top, 0, .5, (v) => s.update(top: v)),
            _Slider(t.t('weight'), s.weight.toDouble(), 0, 8, (v) => s.update(weight: v.round()),
                divisions: 8),
            _Slider(t.t('opacity'), s.opacity, .2, 1, (v) => s.update(opacity: v)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.t('depth')),
              value: s.depth,
              onChanged: (v) => s.update(depth: v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.t('face')),
              value: s.face,
              onChanged: (v) => s.update(face: v),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: s.reset, child: Text(t.t('reset'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider(this.label, this.value, this.min, this.max, this.onChanged, {this.divisions});
  final String label;
  final double value, min, max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged),
        ),
      ],
    );
  }
}
