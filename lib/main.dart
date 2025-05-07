import 'dart:io';

import 'package:classify/data/repositories/todo/todo_repository_remote.dart';
import 'package:classify/data/services/todo_services/todo_firebase_service.dart';
import 'package:classify/data/services/todo_services/todo_hive_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'utils/top_level_setting.dart';
import 'global/global.dart';
import 'routing/router.dart';
import 'package:provider/provider.dart';
import 'package:classify/data/repositories/auth/auth_repository_remote.dart';
import 'package:classify/data/services/firebase_auth_service.dart';
import 'package:classify/data/services/firestore_service.dart';
import 'package:classify/data/services/gemini_service.dart';
import 'package:classify/data/repositories/memo/memo_repository_remote.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:classify/data/services/hive_service.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:classify/data/services/google_login_service.dart';

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

    // // fix/HiveError
    // // 기존 Hive 파일 삭제 시도
    // try {
    //   final memoBixFile = File('${dir.path}/memo.hive');
    //   if (await memoBixFile.exists()) {
    //     await memoBixFile.delete();
    //     debugPrint('🔧🧰✅ memo.hive 파일 삭제 완료');
    //   }

    //   final todoBoxFile = File('${dir.path}/todo.hive');
    //   if (await todoBoxFile.exists()) {
    //     await todoBoxFile.delete();
    //     debugPrint('🔧🧰✅ 손상된 todo.hive 파일 삭제 완료');
    //   }
    // } catch (e) {
    //   debugPrint('🔧🧰❌ Hive 파일 삭제 실패: $e');

    // Hive 초기화
    Hive.init(dir.path);
    Hive.registerAdapter(MemoModelAdapter());
    await Hive.openBox<MemoModel>('memo');
    await Hive.openBox<List<String>>("category");
    Hive.registerAdapter(TodoModelAdapter());
    await Hive.openBox<TodoModel>('todo');
    debugPrint("✅ Hive 초기화 성공!");
  } catch (e) {
    debugPrint('❌ 앱 초기화 실패: $e');
  }
  runApp(const MainApp());
  // } catch (e) {}
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
        Provider<TodoFirebaseService>(
          create: (_) => TodoFirebaseService(),
        ),
        Provider<TodoHiveService>(
          create: (_) => TodoHiveService(),
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
        // todoMode
        ChangeNotifierProvider<TodoRepositoryRemote>(
          create: (context) => TodoRepositoryRemote(
              firestoreService: context.read<TodoFirebaseService>(),
              hiveService: context.read<TodoHiveService>()),
        ),
      ],
      child: MaterialApp.router(
        scrollBehavior: ScrollConfiguration.of(context).copyWith(
          physics: const ClampingScrollPhysics(),
        ),
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
