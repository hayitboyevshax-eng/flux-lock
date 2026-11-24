import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/clock_style.dart';

/// Oddiy, kodgeneratsiyasiz lokalizatsiya. Yangi til qo'shish uchun _v ga
/// yangi xarita qo'shing va supported ro'yxatiga Locale kiriting.
class AppL10n {
  AppL10n(this.locale);
  final Locale locale;

  static const supported = [Locale('en'), Locale('uz'), Locale('ru')];
  static const LocalizationsDelegate<AppL10n> delegate = _Delegate();

  static AppL10n of(BuildContext c) =>
      Localizations.of<AppL10n>(c, AppL10n) ?? AppL10n(const Locale('en'));

  static const Map<String, Map<String, String>> _v = {
    'en': {
      'appName': 'Lux Clock',
      'settings': 'Settings',
      'clockStyle': 'Clock style',
      'background': 'Background',
      'bg_transparent': 'Transparent',
      'bg_gradient': 'Gradient',
      'bg_glass': 'Glass',
      'style_hyperOs': 'HyperOS Depth',
      'style_liquidGlass': 'Liquid Glass',
      'style_dotMatrix': 'Dot-Matrix',
      'style_neon': 'Neon Cyberpunk',
      'style_gold': 'Minimalist Gold',
      'format24': '24-hour format',
      'animations': 'Animations',
    },
    'uz': {
      'appName': 'Lux Soat',
      'settings': 'Sozlamalar',
      'clockStyle': 'Soat uslubi',
      'background': 'Orqa fon',
      'bg_transparent': 'Shaffof',
      'bg_gradient': 'Gradient',
      'bg_glass': 'Shisha',
      'style_hyperOs': 'HyperOS Chuqurlik',
      'style_liquidGlass': 'Suyuq shisha',
      'style_dotMatrix': 'Nuqtali matritsa',
      'style_neon': 'Neon Kiberpank',
      'style_gold': 'Minimalist Oltin',
      'format24': '24 soatlik format',
      'animations': 'Animatsiyalar',
    },
    'ru': {
      'appName': 'Lux Часы',
      'settings': 'Настройки',
      'clockStyle': 'Стиль часов',
      'background': 'Фон',
      'bg_transparent': 'Прозрачный',
      'bg_gradient': 'Градиент',
      'bg_glass': 'Стекло',
      'style_hyperOs': 'HyperOS Глубина',
      'style_liquidGlass': 'Жидкое стекло',
      'style_dotMatrix': 'Точечная матрица',
      'style_neon': 'Неон Киберпанк',
      'style_gold': 'Минимализм Золото',
      'format24': '24-часовой формат',
      'animations': 'Анимации',
    },
  };

  String t(String key) =>
      (_v[locale.languageCode] ?? _v['en']!)[key] ?? _v['en']![key] ?? key;

  String get appName => t('appName');
  String get settings => t('settings');
  String get clockStyle => t('clockStyle');
  String get background => t('background');
  String get format24 => t('format24');
  String get animations => t('animations');
  String styleName(ClockStyle s) => t('style_${s.name}');
  String bgName(BgType b) => t('bg_${b.name}');
}

class _Delegate extends LocalizationsDelegate<AppL10n> {
  const _Delegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<AppL10n> load(Locale locale) => SynchronousFuture(AppL10n(locale));
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppL10n> old) => false;
}
