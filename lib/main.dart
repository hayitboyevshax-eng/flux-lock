import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'l10n/app_l10n.dart';
import 'models/settings_controller.dart';
import 'screens/clock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final settings = await SettingsController.load();
  runApp(LuxClockApp(settings: settings));
}

class LuxClockApp extends StatelessWidget {
  const LuxClockApp({super.key, required this.settings});
  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (c) => AppL10n.of(c).appName,
      theme: ThemeData.dark(useMaterial3: true),
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppL10n.supported,
      // Tizim tili uz/en/ru bo'lmasa — avtomatik Ingliz tili
      localeResolutionCallback: (locale, supported) {
        if (locale != null) {
          for (final s in supported) {
            if (s.languageCode == locale.languageCode) return s;
          }
        }
        return const Locale('en');
      },
      home: ClockScreen(settings: settings),
    );
  }
}
