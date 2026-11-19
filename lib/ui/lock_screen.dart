import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/clock_settings.dart';
import '../core/face_unlock_service.dart';
import '../core/security_service.dart';
import '../core/strings.dart';
import 'widgets/clock_settings_sheet.dart';
import 'widgets/depth_clock.dart';
import 'widgets/fingerprint_button.dart';
import 'widgets/unlock_panel.dart';
import 'widgets/wallpaper_layer.dart';

/// Qatlamlar (pastdan yuqoriga):
///  1. orqa fon  2. SOAT  3. old qatlam (cutout)  4. sana  5. barmoq izi  6. PIN paneli
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver {
  final _face = FaceUnlockService();
  bool _panel = false, _toSettings = false;
  int _openCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startFace());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _startFace();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _face.dispose();
    super.dispose();
  }

  Future<void> _startFace() async {
    if (!context.read<ClockSettings>().face) return;
    final ok = await _face.authenticate(); // kamera ko'rinmaydi, ramka yo'q
    if (ok && mounted && !_panel) _unlock();
  }

  void _unlock() => SystemNavigator.pop();

  void _open({bool settings = false}) => setState(() {
        _panel = true;
        _toSettings = settings;
        _openCount++;
      });

  void _onUnlocked() {
    if (_toSettings) {
      setState(() => _panel = false);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const ClockSettingsSheet(),
      );
    } else {
      _unlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final size = MediaQuery.sizeOf(context);
    final depth = context.select<ClockSettings, bool>((s) => s.depth);
    final panelH = size.height * .78;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onVerticalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -300 && !_panel) _open();
            if (v > 300 && _panel) setState(() => _panel = false);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              const WallpaperLayer(),
              // soat: uzoq bosilsa sozlamalar (avval autentifikatsiya)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onLongPress: () => _open(settings: true),
                  child: Stack(children: const [DepthClock()]),
                ),
              ),
              if (depth) const WallpaperLayer(foreground: true),
              // sana
              Positioned(
                top: MediaQuery.paddingOf(context).top + 18,
                left: 0,
                right: 0,
                child: ClockTicker(
                  builder: (_, now) => Text(
                    t.date(now),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              // pastki qism
              Positioned(
                bottom: 34,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.t('swipe'),
                        style: const TextStyle(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 14),
                    FingerprintButton(
                      onAuth: () => context.read<SecurityService>().biometric(t.t('bio')),
                      onSuccess: _unlock,
                    ),
                  ],
                ),
              ),
              // qorong'ilashtirish
              IgnorePointer(
                ignoring: !_panel,
                child: GestureDetector(
                  onTap: () => setState(() => _panel = false),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _panel ? 1 : 0,
                    child: Container(color: Colors.black38),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                left: 0,
                right: 0,
                bottom: _panel ? 0 : -panelH,
                height: panelH,
                child: UnlockPanel(key: ValueKey(_openCount), onUnlocked: _onUnlocked),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
