import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'utils/top_level_setting.dart';
import 'routing/router.dart';
import 'package:provider/provider.dart';
import 'data/repositories/auth/auth_repository_remote.dart';
import 'data/services/firebase_auth_service.dart';
import 'data/services/firestore_service.dart';

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
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<AuthRepositoryRemote>(
          create: (context) => AuthRepositoryRemote(
            firebaseAuthService: context.read<FirebaseAuthService>(),
            firestoreService: context.read<FirestoreService>(),
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