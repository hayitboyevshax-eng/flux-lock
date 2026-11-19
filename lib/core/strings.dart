import 'package:flutter/widgets.dart';

/// Yengil lokalizatsiya: uz / en / ru.
class S {
  S(this.lang);
  final String lang;
  static S of(BuildContext c) => S(Localizations.localeOf(c).languageCode);

  static const _m = <String, Map<String, String>>{
    'uz': {
      'swipe': 'Ochish uchun tepaga suring',
      'enterPin': 'PIN-kodni kiriting',
      'newPin': 'Yangi PIN o\'rnating',
      'confirmPin': 'PIN-kodni tasdiqlang',
      'drawPattern': 'Chizmali parolni chizing',
      'newPattern': 'Yangi chizma chizing (kamida 4 nuqta)',
      'confirmPattern': 'Chizmani qayta chizing',
      'wrong': 'Noto\'g\'ri. Qayta urinib ko\'ring',
      'mismatch': 'Mos kelmadi. Qaytadan boshlang',
      'locked': '30 soniya kuting',
      'pin': 'PIN',
      'pattern': 'Chizma',
      'width': 'Soat eni',
      'height': 'Soat balandligi',
      'top': 'Vertikal joylashuv',
      'weight': 'Shrift qalinligi',
      'opacity': 'Shaffoflik',
      'depth': 'Chuqurlik effekti',
      'face': 'Yuz bilan ochish',
      'reset': 'Asl holatga',
      'settings': 'Soat sozlamalari',
      'bio': 'Barmoq izi bilan oching',
    },
    'en': {
      'swipe': 'Swipe up to unlock',
      'enterPin': 'Enter PIN',
      'newPin': 'Set a new PIN',
      'confirmPin': 'Confirm PIN',
      'drawPattern': 'Draw your pattern',
      'newPattern': 'Draw a new pattern (min. 4 dots)',
      'confirmPattern': 'Draw the pattern again',
      'wrong': 'Wrong. Try again',
      'mismatch': 'Did not match. Start over',
      'locked': 'Wait 30 seconds',
      'pin': 'PIN',
      'pattern': 'Pattern',
      'width': 'Clock width',
      'height': 'Clock height',
      'top': 'Vertical position',
      'weight': 'Font weight',
      'opacity': 'Opacity',
      'depth': 'Depth effect',
      'face': 'Face unlock',
      'reset': 'Reset',
      'settings': 'Clock settings',
      'bio': 'Unlock with fingerprint',
    },
    'ru': {
      'swipe': 'Проведите вверх, чтобы разблокировать',
      'enterPin': 'Введите PIN-код',
      'newPin': 'Задайте новый PIN',
      'confirmPin': 'Подтвердите PIN',
      'drawPattern': 'Нарисуйте ключ',
      'newPattern': 'Нарисуйте ключ (мин. 4 точки)',
      'confirmPattern': 'Повторите ключ',
      'wrong': 'Неверно. Повторите',
      'mismatch': 'Не совпало. Начните заново',
      'locked': 'Подождите 30 секунд',
      'pin': 'PIN',
      'pattern': 'Ключ',
      'width': 'Ширина часов',
      'height': 'Высота часов',
      'top': 'Положение по вертикали',
      'weight': 'Толщина шрифта',
      'opacity': 'Прозрачность',
      'depth': 'Эффект глубины',
      'face': 'Разблокировка по лицу',
      'reset': 'Сбросить',
      'settings': 'Настройки часов',
      'bio': 'Разблокировка по отпечатку',
    },
  };

  static const _months = {
    'uz': ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyn', 'Iyl', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'],
    'en': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    'ru': ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'],
  };
  static const _days = {
    'uz': ['Dush', 'Sesh', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'],
    'en': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'ru': ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
  };

  String t(String k) => _m[lang]?[k] ?? _m['en']![k]!;
  String date(DateTime d) {
    final l = _months.containsKey(lang) ? lang : 'en';
    return '${d.day} ${_months[l]![d.month - 1]}, ${_days[l]![d.weekday - 1]}';
  }
}
