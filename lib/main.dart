import 'dart:io';

import 'package:classify/data/repositories/todo/todo_repository_remote.dart';
import 'package:classify/data/services/todo_services/todo_firebase_service.dart';
import 'package:classify/data/services/todo_services/todo_hive_service.dart';
import 'package:classify/ui/todo/view_models/todo_view_model.dart';
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
import 'package:classify/data/repositories/sync/sync_monitor_repository_remote.dart';
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
    debugPrint("✅ 1. 앱 디렉토리 가져오기 성공: ${dir.path}");

    // // 하이브 파일 삭제
    // >> box not found. did you forget to call hive.openbox() 경우 해결코드
    try {
      final memoBoxFile = File('${dir.path}/memo.hive');
      if (await memoBoxFile.exists()) {
        await memoBoxFile.delete();
        debugPrint('🔧🧰 memo.hive 파일 삭제 완료 ✅');
      }

      final todoBoxFile = File('${dir.path}/todo.hive');
      if (await todoBoxFile.exists()) {
        await todoBoxFile.delete();
        debugPrint('🔧🧰 todo.hive 파일 삭제 완료 ✅');
      }

      final todoLockFile = File('${dir.path}/todo.lock');
      if (await todoLockFile.exists()) {
        await todoLockFile.delete();
        debugPrint('🔧🧰 todo.lock 파일 삭제 완료 ✅');
      }
    } catch (e) {
      debugPrint('🔧🧰 Hive 파일 삭제 실패: $e ❌');
    }

    // Hive 초기화
    Hive.init(dir.path);
    debugPrint("✅ 2. Hive 초기화 성공");

    // MemoModel 관련 초기화
    debugPrint("⏳ 3. MemoModelAdapter 등록 시작");
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MemoModelAdapter());
    }
    debugPrint("✅ 3. MemoModelAdapter 등록 성공");

    await Hive.openBox<MemoModel>('memo');

    // 카테고리 관련 초기화
    await Hive.openBox<List<String>>("category");

    // TodoModel 관련 초기화
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TodoModelAdapter());
    }
    debugPrint("✅ 6. TodoModelAdapter 등록 성공");

    try {
      await Hive.openBox<TodoModel>('todo');
      debugPrint("✅ 7. todo 박스 열기 성공");
    } catch (e) {
      debugPrint("❌ 7. todo 박스 열기 실패: $e");
      // 박스 다시 생성 시도
      try {
        await Hive.deleteBoxFromDisk('todo');
        debugPrint("🔄 todo 박스 삭제 후 다시 생성 시도");
        await Hive.openBox<TodoModel>('todo');
        debugPrint("✅ todo 박스 재생성 성공");
      } catch (e2) {
        debugPrint("❌ todo 박스 재생성 실패: $e2");
        throw Exception("Todo 박스 생성 실패: $e2");
      }
    }

    debugPrint("✅ 8. Hive 전체 초기화 완료!");
  } catch (e) {
    debugPrint('❌ 앱 초기화 실패: $e');
    // 어떤 단계에서 실패했는지 스택 트레이스 출력
    debugPrint('❌ 스택 트레이스: ${StackTrace.current}');
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
        Provider<TodoFirebaseService>(
          create: (_) => TodoFirebaseService(),
        ),
        Provider<TodoHiveService>(
          create: (_) => TodoHiveService(),
        ),
        Provider<GoogleLoginService>(
          create: (_) => GoogleLoginService(),
        ),
        ChangeNotifierProvider<SyncMonitorRepositoryRemote>(
          create: (context) => SyncMonitorRepositoryRemote(
            firestoreService: context.read<FirestoreService>(),
            hiveService: context.read<HiveService>(),
          ),
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
              todoFirestoreService: context.read<TodoFirebaseService>(),
              todoHiveService: context.read<TodoHiveService>()),
        ),

        // todoViewModel 최상위 MultiProvider에 추가
        ChangeNotifierProvider<TodoViewModel>(
          create: (context) => TodoViewModel(
            todoRepository: context.read<TodoRepositoryRemote>(),
          ),
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
