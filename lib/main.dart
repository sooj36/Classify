import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'utils/top_level_setting.dart';
import 'global/global.dart';
import 'routing/router.dart';
import 'package:provider/provider.dart';
import 'package:weathercloset/data/repositories/auth/auth_repository_remote.dart';
import 'package:weathercloset/data/services/firebase_auth_service.dart';
import 'package:weathercloset/data/services/firestore_service.dart';
import 'package:weathercloset/data/services/gemini_service.dart';
import 'package:weathercloset/data/repositories/memo/memo_repository_remote.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weathercloset/data/services/hive_service.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';
import 'package:weathercloset/data/services/google_login_service.dart';

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
    await getIdToken();
    debugPrint('✅ Firebase Auth Token 초기화 성공!: $idToken');
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(MemoModelAdapter());
    await Hive.openBox<MemoModel>('memo');
    await Hive.openBox<List<String>>("category");
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
        Provider<HiveService>(
          create: (_) => HiveService(),
        ),
        Provider<GoogleLoginService>(
          create: (_) => GoogleLoginService(),
        ),
        ChangeNotifierProvider<AuthRepositoryRemote>(
          create: (context) => AuthRepositoryRemote(
            firebaseAuthService: context.read<FirebaseAuthService>(),
            firestoreService: context.read<FirestoreService>(),
            hiveService: context.read<HiveService>(),
            googleLoginService: context.read<GoogleLoginService>(),
          ),
        ),
        ChangeNotifierProvider<MemoRepositoryRemote>(
          create: (context) => MemoRepositoryRemote(
            geminiService: context.read<GeminiService>(),
            firestoreService: context.read<FirestoreService>(),
            hiveService: context.read<HiveService>(),
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