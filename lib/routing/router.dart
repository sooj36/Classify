import 'package:go_router/go_router.dart';
import './routes.dart';
import '../ui/basics/root_screen.dart';
import '../ui/auth/login/widgets/login_screen.dart';
import '../ui/auth/signup/widgets/signup_screen.dart';

class Router {
  static final router = GoRouter(
    initialLocation: Routes.home,
    routes: <GoRoute>[
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const RootScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => SignupScreen(),
      ),
    ],
  );
}