# Lux Clock — Flutter

## Ishga tushirish
1. `flutter create lux_clock --org com.example` (yoki mavjud loyihangiz)
2. Ushbu arxivdagi `lib/` va `pubspec.yaml` ni loyihaga ko'chiring.
3. `flutter pub get && flutter run`
   (google_fonts shriftlari birinchi ishga tushishda internetdan yuklanadi.)

## Android — ilova nomi
- `AndroidManifest.xml` dagi `android:label="@string/app_name"` qatorini
  `android/app/src/main/AndroidManifest.xml` ga qo'ying.
- `res/values`, `res/values-uz`, `res/values-ru` papkalarini `android/app/src/main/res/` ga ko'chiring.

## iOS — ilova nomi
1. `ios/Runner/Info.plist` ga `ios_config/Info.plist.snippet.xml` dagi kalitlarni qo'shing.
2. Xcode → Runner (project) → Info → Localizations → `+` bilan Uzbek va Russian qo'shing.
3. Xcode: Runner papkasiga File → New → File → Strings File, nomi aniq `InfoPlist.strings`.
   File Inspector → Localize… → English, Uzbek, Russian ni belgilang.
4. Har bir til fayliga `ios_config/*.lproj/InfoPlist.strings` mazmunini yozing.

## Til qo'shish
`lib/l10n/app_l10n.dart` dagi `_v` xaritasiga yangi til qo'shing va `supported` ga `Locale` kiriting.

## GitHub Actions
`.github/workflows/build.yml` har bir push'da avtomatik:
- **android** job: `flutter create` bilan platforma papkalarini yaratadi, `android_config/` ni qo'llaydi, `app-release.apk` yig'adi.
- **ios** job (macOS): `Info.plist` kalitlari va 3 tilli `InfoPlist.strings` ni qo'shadi, imzosiz (`--no-codesign`) build qiladi.

Natija: Actions → ish ishga tushirilishi → **Artifacts** bo'limidan yuklab oling.
Qo'lda ishga tushirish: Actions → *Build Lux Clock* → **Run workflow**.

## Animatsiyalarni o'chirish
Sozlamalar → **Animatsiyalar** tugmasi. O'chirilsa, soat uslublaridagi barcha uzluksiz
effektlar (yaltirash, glitch, to'lqin, suzish) va fon harakati to'xtaydi, soat faqat
soniya almashganda yangilanadi — batareya ham tejaladi. Tanlov saqlanadi.
