import 'dart:ui' show FontFeature;
import 'package:intl/intl.dart';

/// Raqamlar o'zgarganda "sakrab ketmasligi" uchun
const List<FontFeature> kTabular = [FontFeature.tabularFigures()];

class ClockData {
  const ClockData({required this.now, required this.use24h, required this.locale, this.animate = true});
  final DateTime now;
  final bool use24h;
  final String locale;

  /// false bo'lsa — barcha uzluksiz animatsiyalar o'chiriladi (statik ko'rinish)
  final bool animate;

  String _p(int v) => v.toString().padLeft(2, '0');

  String get hh {
    final h = use24h ? now.hour : (now.hour % 12 == 0 ? 12 : now.hour % 12);
    return _p(h);
  }

  String get mm => _p(now.minute);
  String get ss => _p(now.second);

  // intl orqali tizim tiliga mos hafta kuni va sana
  String get weekday => DateFormat.EEEE(locale).format(now);
  String get date => DateFormat.yMMMMd(locale).format(now);
  String get period => use24h ? '' : DateFormat.a(locale).format(now);
  double get secondProgress => (now.second + now.millisecond / 1000) / 60;
}
