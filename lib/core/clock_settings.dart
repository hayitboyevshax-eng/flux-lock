import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Soat o'lchamlari va effektlari. Qiymatlar ekran o'lchamiga nisbatan (0..1).
class ClockSettings extends ChangeNotifier {
  ClockSettings._(this._p);
  final SharedPreferences _p;

  static Future<ClockSettings> load() async {
    final s = ClockSettings._(await SharedPreferences.getInstance());
    s._read();
    return s;
  }

  static const _dw = .74, _dh = .30, _dtop = .08, _dweight = 1, _dop = .96;

  double width = _dw; // ekran eniga nisbatan
  double height = _dh; // ekran balandligiga nisbatan
  double top = _dtop; // yuqoridan masofa (ekran balandligiga nisbatan)
  int weight = _dweight; // 0..8 => w100..w900
  double opacity = _dop;
  bool depth = true; // old qatlam (chuqurlik effekti)
  bool face = false; // fon rejimida yuz bilan ochish
  int wallpaper = 1; // 1..wallpaperCount
  static const wallpaperCount = 5;

  FontWeight get fontWeight => FontWeight.values[weight.clamp(0, 8)];

  void _read() {
    width = _p.getDouble('w') ?? width;
    height = _p.getDouble('h') ?? height;
    top = _p.getDouble('top') ?? top;
    weight = _p.getInt('weight') ?? weight;
    opacity = _p.getDouble('op') ?? opacity;
    depth = _p.getBool('depth') ?? depth;
    face = _p.getBool('face') ?? face;
    wallpaper = _p.getInt('wp') ?? wallpaper;
  }

  void update({
    double? width,
    double? height,
    double? top,
    int? weight,
    double? opacity,
    bool? depth,
    bool? face,
    int? wallpaper,
  }) {
    this.width = width ?? this.width;
    this.height = height ?? this.height;
    this.top = top ?? this.top;
    this.weight = weight ?? this.weight;
    this.opacity = opacity ?? this.opacity;
    this.depth = depth ?? this.depth;
    this.face = face ?? this.face;
    this.wallpaper = wallpaper ?? this.wallpaper;
    notifyListeners();
    _p.setDouble('w', this.width);
    _p.setDouble('h', this.height);
    _p.setDouble('top', this.top);
    _p.setInt('weight', this.weight);
    _p.setDouble('op', this.opacity);
    _p.setBool('depth', this.depth);
    _p.setBool('face', this.face);
    _p.setInt('wp', this.wallpaper);
  }

  void reset() => update(
      width: _dw, height: _dh, top: _dtop, weight: _dweight, opacity: _dop, depth: true);
}
