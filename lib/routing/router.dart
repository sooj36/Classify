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
import '../ui/closet/cloth_add/widget/cloth_add_screen.dart';
import '../ui/closet/cloth_add/view_models/cloth_add_viewmodel.dart';
import '../data/repositories/cloth_analyze/cloth_repository_remote.dart';
import '../ui/closet/closet_view/view_models/closet_view_model.dart';
import '../ui/closet/closet_view/widgets/closet_screen.dart';
import '../ui/basics/home_screen.dart';
import '../ui/basics/profile_screen.dart';
final router = GoRouter(
  initialLocation: Routes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => RootScreen(child: child),
      routes: [
        GoRoute(
          path: Routes.closet,
          builder: (context, state) => ClosetScreen(
            viewModel: ClosetViewModel(
              clothRepositoryRemote: context.read<ClothRepositoryRemote>(),
            ),
          ),
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const CoordinatorScreen(),
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
      path: Routes.clothAdd,
      builder: (context, state) => ClothAddScreen(
        viewModel: ClothAddViewModel(
          clothRepositoryRemote: context.read<ClothRepositoryRemote>(),
        ),
      ),
    ),
  ],
);