import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'utils/top_level_setting.dart';
import 'package:weathercloset/ui/basics/initial_loading_screen.dart';
// import 'package:weathercloset/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //flutter engine과 app 연결
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase 초기화 성공!');
  } catch (e) {
    debugPrint('Firebase 초기화 실패: $e');
  }
  runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
      home: const InitialLoadingScreen(),
      // home: const ClothAddScreen(),
    );
  }
}