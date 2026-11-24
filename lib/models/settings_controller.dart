import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'clock_style.dart';

class SettingsController extends ChangeNotifier {
  SettingsController._(this._p) {
    style = ClockStyle.values[(_p.getInt('style') ?? 0).clamp(0, ClockStyle.values.length - 1)];
    bg = BgType.values[(_p.getInt('bg') ?? 1).clamp(0, BgType.values.length - 1)];
    use24h = _p.getBool('use24h') ?? true;
    animations = _p.getBool('animations') ?? true;
  }

  final SharedPreferences _p;
  late ClockStyle style;
  late BgType bg;
  late bool use24h;
  late bool animations;

  static Future<SettingsController> load() async =>
      SettingsController._(await SharedPreferences.getInstance());

  void setStyle(ClockStyle s) {
    style = s;
    _p.setInt('style', s.index);
    notifyListeners();
  }

  void setBg(BgType b) {
    bg = b;
    _p.setInt('bg', b.index);
    notifyListeners();
  }

  void setAnimations(bool v) {
    animations = v;
    _p.setBool('animations', v);
    notifyListeners();
  }

  void setUse24h(bool v) {
    use24h = v;
    _p.setBool('use24h', v);
    notifyListeners();
  }
}
