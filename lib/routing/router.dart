import 'package:classify/data/repositories/todo/todo_repository_remote.dart';
import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:classify/ui/todo/view_models/todo_view_model.dart'
    show TodoViewModel;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:classify/routing/routes.dart';
import 'package:classify/ui/basics/root_screen.dart';
import 'package:classify/ui/auth/login/widgets/login_screen.dart';
import 'package:classify/ui/setting/widgets/setting_screen.dart';
import 'package:classify/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:classify/data/repositories/auth/auth_repository_remote.dart';
import 'package:provider/provider.dart';
import 'package:classify/data/repositories/memo/memo_repository_remote.dart';
import 'package:classify/ui/archive/archive_view/view_models/archive_view_model.dart';
import 'package:classify/ui/archive/archive_view/widgets/archive_view_screen.dart';
import 'package:classify/ui/send_memo_to_ai/widgets/send_memo_to_ai_screen.dart';
import 'package:classify/global/global.dart';
import 'package:classify/ui/send_memo_to_ai/view_models/send_memo_to_ai_viewmodel.dart';
import 'package:classify/ui/search/view/search_screen.dart';
import 'package:classify/ui/search/view_model/search_view_model.dart';
import 'package:classify/ui/setting/view_models/setting_viewmodel.dart';
import 'package:classify/ui/today_act/view/today_act_screen.dart';
import 'package:classify/ui/today_act/view_models/today_act_view_model.dart';
import 'package:classify/ui/setting/widgets/privacy_policy_screen.dart';
import 'package:classify/ui/study/view_models/study_view_model.dart';
import 'package:classify/ui/study/view/study_screen.dart';
import 'package:classify/ui/basics/profile_screen.dart';
import 'package:classify/ui/todo/view/todo_screen.dart';

// todo 페이지 진입 시, appbar 안보이게 설정
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final router = GoRouter(
  // 루트 네비게이터 키 추가
  navigatorKey: _rootNavigatorKey,
  initialLocation:
      firebaseAuth.currentUser != null ? Routes.today : Routes.login,
  routes: [
    // todo 라우트를 shellRoute 밖으로 이동
    GoRoute(
      path: Routes.todo,
      builder: (context, state) => TodoScreen(
        todoViewModel: Provider.of<TodoViewModel>(context, listen: false),
      ),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => SendMemoToAiViewModel(
              memoRepository: context.read<MemoRepositoryRemote>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => ArchiveViewModel(
              memoRepository: context.read<MemoRepositoryRemote>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => TodayActViewModel(
              memoRepository: context.read<MemoRepositoryRemote>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => StudyViewModel(
              memoRepository: context.read<MemoRepositoryRemote>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => ProfileViewModel(
              syncMonitorRepository: context.read<SyncMonitorRepositoryRemote>(),
            ),
          ),
        ],
        child: RootScreen(child: child),
      ),
      routes: [
        GoRoute(
          path: Routes.today,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: TodayActScreen(
              viewModel: context.read<TodayActViewModel>(),
            ),
          ),
        ),
        GoRoute(
          path: Routes.archive,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: ArchiveScreen(
              viewModel: context.read<ArchiveViewModel>(),
            ),
          ),
        ),
        GoRoute(
          path: Routes.study,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: StudyScreen(
              viewModel: context.read<StudyViewModel>(),
            ),
          ),
        ),
        GoRoute(
          path: Routes.profile,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: ProfileScreen(
              viewmodel: context.read<ProfileViewModel>(),
            ),
          ),
        ),
        // GoRoute(
        //   path: Routes.todo,
        //   pageBuilder: (context, state) => NoTransitionPage<void>(
        //     key: state.pageKey,
        //     child: TodoScreen(
        //       todoViewModel: context.read<TodoViewModel>(),
        //     ),
        //   ),
        // ),
      ],
    ),
    // 독립적인 전체 화면 라우트들
    GoRoute(
      path: Routes.sendMemo,
      builder: (context, state) => SendMemoToAiScreen(
        sendMemoToAiViewModel: SendMemoToAiViewModel(
          memoRepository: context.read<MemoRepositoryRemote>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.setting,
      builder: (context, state) => SettingScreen(
        viewModel: SettingViewModel(
          authRepository: context.read<AuthRepositoryRemote>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.search,
      builder: (context, state) => SearchScreen(
        viewModel: SearchViewModel(
          memoRepository: context.read<MemoRepositoryRemote>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => LoginScreen(
        viewModel: LoginViewModel(
          authRepository: context.read<AuthRepositoryRemote>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],
);
