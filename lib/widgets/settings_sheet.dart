import 'dart:ui';
import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';
import '../models/clock_style.dart';
import '../models/settings_controller.dart';

void showSettingsSheet(BuildContext context, SettingsController s) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _SettingsSheet(settings: s),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({required this.settings});
  final SettingsController settings;

  Widget _title(String s) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(s.toUpperCase(),
            style: const TextStyle(fontSize: 12, letterSpacing: 2.5, color: Colors.white54, fontWeight: FontWeight.w700)),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF14141C).withAlpha(215),
            border: Border(top: BorderSide(color: Colors.white.withAlpha(40))),
          ),
          child: SafeArea(
            child: ListenableBuilder(
              listenable: settings,
              builder: (_, __) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(height: 16),
                    Text(l.settings, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    _title(l.clockStyle),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final st in ClockStyle.values)
                        _Pill(
                          label: l.styleName(st),
                          selected: settings.style == st,
                          color: st.accent,
                          onTap: () => settings.setStyle(st),
                        ),
                    ]),
                    _title(l.background),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final b in BgType.values)
                        _Pill(
                          label: l.bgName(b),
                          selected: settings.bg == b,
                          color: settings.style.accent,
                          onTap: () => settings.setBg(b),
                        ),
                    ]),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.format24),
                      value: settings.use24h,
                      activeColor: settings.style.accent,
                      onChanged: settings.setUse24h,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.animations),
                      value: settings.animations,
                      activeColor: settings.style.accent,
                      onChanged: settings.setAnimations,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.color, required this.onTap});
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: selected ? color.withAlpha(50) : Colors.white.withAlpha(14),
          border: Border.all(color: selected ? color : Colors.white.withAlpha(30), width: 1.3),
          boxShadow: selected ? [BoxShadow(color: color.withAlpha(90), blurRadius: 16)] : null,
        ),
        child: Text(label,
            style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.white70)),
      ),
    );
  }
}
