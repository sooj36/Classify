import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'utils/top_level_setting.dart';
import 'global/global.dart';
import 'routing/router.dart';
import 'package:provider/provider.dart';
import 'data/repositories/auth/auth_repository_remote.dart';
import 'data/services/firebase_auth_service.dart';
import 'data/services/firestore_service.dart';
import 'data/services/gemini_service.dart';
import 'data/repositories/cloth_analyze/cloth_repository_remote.dart';
import 'data/repositories/weather/weather_repository_remote.dart';
import 'data/services/weatherapi_service.dart';
import 'data/services/geolocator_service.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'data/services/hive_service.dart';
import 'domain/models/cloth/cloth_model.dart';
import 'data/services/runware_service.dart';
import 'data/services/klingai_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //flutter engine과 app 연결
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase 초기화 성공!');
    await initSharedPreferences();
    debugPrint('✅ SharedPreferences 초기화 성공!');
    initGemini();
    debugPrint('✅ Gemini 초기화 성공!');
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(ClothModelAdapter());
    await Hive.openBox<ClothModel>("clothes");

    debugPrint("✅ Hive 초기화 성공!");

  } catch (e) {
    debugPrint('❌ 앱 초기화 실패: $e');
  }
  runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<GeminiService>(
          create: (_) => GeminiService(),
        ),
        Provider<WeatherApiService>(
          create: (_) => WeatherApiService(),
        ),
        Provider<GeolocatorService>(
          create: (_) => GeolocatorService(),
        ),
        Provider<HiveService>(
          create: (_) => HiveService(),
        ),
        Provider<RunwareService>(
          create: (_) => RunwareService(),
        ),
        Provider<KlingService>(
          create: (_) => KlingService(),
        ),
        ChangeNotifierProvider<AuthRepositoryRemote>(
          create: (context) => AuthRepositoryRemote(
            firebaseAuthService: context.read<FirebaseAuthService>(),
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProvider<ClothRepositoryRemote>(
          create: (context) => ClothRepositoryRemote(
            geminiService: context.read<GeminiService>(),
            firestoreService: context.read<FirestoreService>(),
            hiveService: context.read<HiveService>(),
            runwareService: context.read<RunwareService>(),
            klingService: context.read<KlingService>(),
          ),
        ),
        ChangeNotifierProvider<WeatherRepositoryRemote>(
          create: (context) => WeatherRepositoryRemote(
            weatherApiService: context.read<WeatherApiService>(),
            geolocatorService: context.read<GeolocatorService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
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
        routerConfig: router,
      ),
    );
  }
}