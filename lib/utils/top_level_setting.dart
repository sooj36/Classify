import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//android or ios 인식해서 그에 맞게 UI를 그려줌
class PlatformWidget extends StatelessWidget {
  final WidgetBuilder androidBuilder;
  final WidgetBuilder iosBuilder;

  const PlatformWidget({
    super.key,
    required this.androidBuilder,
    required this.iosBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? iosBuilder(context)
        : androidBuilder(context);
  }
}

//최상위 앱 테마를 설정
class AppTheme {
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.white;
  
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    textTheme: GoogleFonts.nanumGothicTextTheme(ThemeData.light().textTheme),
  );
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'My App',
      'hello': 'Hello World!',
    },
    'ko': {
      'appTitle': '내 앱',
      'hello': '안녕하세요!',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get hello => _localizedValues[locale.languageCode]!['hello']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ko'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}