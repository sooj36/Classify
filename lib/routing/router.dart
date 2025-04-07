import 'package:go_router/go_router.dart';
import './routes.dart';
import '../ui/basics/root_screen.dart';
import '../ui/auth/login/widgets/login_screen.dart';
import '../ui/auth/signup/widgets/signup_screen.dart';
import '../ui/setting/widgets/setting_screen.dart';
import '../ui/auth/login/view_models/login_viewmodel.dart';
import '../ui/auth/signup/view_models/signup_viewmodel.dart';
import '../data/repositories/auth/auth_repository_remote.dart';
import 'package:provider/provider.dart';
import '../ui/archive/archive_add/widget/archive_add_screen.dart';
import '../ui/archive/archive_add/view_models/archive_add_viewmodel.dart';
import '../data/repositories/memo_analyze/memo_analyze_repository_remote.dart';
import '../ui/archive/archive_view/view_models/archive_view_model.dart';
import '../ui/archive/archive_view/widgets/archive_view_screen.dart';
import '../ui/send_memo_to_ai/widgets/send_memo_to_ai_screen.dart';
import '../ui/basics/profile_screen.dart';
import '../global/global.dart';
import '../ui/send_memo_to_ai/view_models/send_memo_to_ai_viewmodel.dart';

final router = GoRouter(
  initialLocation: firebaseAuth.currentUser != null ? Routes.sendMemo : Routes.login,
  routes: [
    ShellRoute(
        builder: (context, state, child) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => SendMemoToAiViewModel(
          memoAnalyzeRepositoryRemote: context.read<MemoAnalyzeRepositoryRemote>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => ArchiveViewModel(
          memoAnalyzeRepositoryRemote: context.read<MemoAnalyzeRepositoryRemote>(),
        ),
      ),
    ],
    child: RootScreen(child: child),
  ),
      routes: [
                GoRoute(
          path: Routes.archive,
          builder: (context, state) => ArchiveScreen(
            viewModel: context.read<ArchiveViewModel>(),
          ),
        ),
        GoRoute(
          path: Routes.sendMemo,
          builder: (context, state) => SendMemoToAiScreen(
            sendMemoToAiViewModel: context.read<SendMemoToAiViewModel>(),
          ),
        ),
        GoRoute(
          path: Routes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    // 독립적인 전체 화면 라우트들
    GoRoute(
      path: Routes.setting,
      builder: (context, state) => const SettingScreen(),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => LoginScreen(
        viewModel: LoginViewModel(
          authRepositoryRemote: context.read<AuthRepositoryRemote>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) => SignupScreen(
        viewModel: SignUpViewModel(
          authRepositoryRemote: context.read<AuthRepositoryRemote>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.archiveAdd,
      builder: (context, state) => ArchiveAddScreen(
        viewModel: ArchiveAddViewModel(
          memoAnalyzeRepositoryRemote: context.read<MemoAnalyzeRepositoryRemote>(),
        ),
      ),
    ),
  ],
);