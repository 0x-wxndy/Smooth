import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_providers.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/home/presentation/role_home_screen.dart';
import '../../features/courses/presentation/courses_screen.dart';
import '../../features/marketplace/presentation/marketplace_screen.dart';
import '../../features/jobs/presentation/jobs_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/games/presentation/games_screen.dart';
import '../../features/games/presentation/game_play_screen.dart';
import '../../features/courses/presentation/course_detail_screen.dart';
import '../../features/marketplace/presentation/service_detail_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/ai_assistant/presentation/ai_chat_screen.dart';
import '../../features/teacher/presentation/teacher_studio_screens.dart';
import '../../features/teacher/presentation/post_listing_screens.dart';
import '../../features/payments/presentation/checkout_screen.dart';
import '../../features/payments/presentation/edahabia_gateway_screen.dart';
import '../../features/payments/presentation/cib_gateway_screen.dart';
import '../../features/payments/presentation/payment_result_screen.dart';
import '../../features/payments/payment_models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.unknown) {
        return null;
      }

      final isAuth = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/welcome') ||
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/role');

      if (!isAuth && !isAuthRoute) return '/welcome';
      if (isAuth && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/role', builder: (_, __) => const RoleSelectionScreen()),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) => const NoTransitionPage(child: RoleHomeTab()),
          ),
          GoRoute(
            path: '/learn',
            pageBuilder: (_, __) => const NoTransitionPage(child: LearnTab()),
          ),
          GoRoute(
            path: '/market',
            pageBuilder: (_, __) => const NoTransitionPage(child: MarketTab()),
          ),
          GoRoute(
            path: '/jobs',
            pageBuilder: (_, __) => const NoTransitionPage(child: JobsTab()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) => const NoTransitionPage(child: ProfileTab()),
          ),
          GoRoute(
            path: '/teacher/courses',
            pageBuilder: (_, __) => const NoTransitionPage(child: TeacherCoursesScreen()),
          ),
          GoRoute(
            path: '/teacher/services',
            pageBuilder: (_, __) => const NoTransitionPage(child: TeacherServicesScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/teacher/post-course',
        builder: (_, __) => const PostCourseScreen(),
      ),
      GoRoute(
        path: '/teacher/post-service',
        builder: (_, __) => const PostServiceScreen(),
      ),
      GoRoute(
        path: '/courses/:id',
        builder: (_, state) => CourseDetailScreen(courseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/services/:id',
        builder: (_, state) => ServiceDetailScreen(serviceId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/ai', builder: (_, __) => const AiChatScreen()),
      GoRoute(path: '/games', builder: (_, __) => const GamesTab()),
      GoRoute(
        path: '/games/:id',
        builder: (_, state) => GamePlayScreen(gameId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, state) {
          final args = state.extra as PaymentCheckoutArgs?;
          if (args == null) {
            return const Scaffold(body: Center(child: Text('Missing checkout data')));
          }
          return CheckoutScreen(args: args);
        },
      ),
      GoRoute(
        path: '/pay/edahabia',
        builder: (_, state) {
          final args = state.extra as PaymentCheckoutArgs?;
          if (args == null) {
            return const Scaffold(body: Center(child: Text('Missing payment data')));
          }
          return EdahabiaGatewayScreen(args: args);
        },
      ),
      GoRoute(
        path: '/pay/cib',
        builder: (_, state) {
          final args = state.extra as PaymentCheckoutArgs?;
          if (args == null) {
            return const Scaffold(body: Center(child: Text('Missing payment data')));
          }
          return CibGatewayScreen(args: args);
        },
      ),
      GoRoute(
        path: '/pay/card',
        builder: (_, state) {
          final args = state.extra as PaymentCheckoutArgs?;
          if (args == null) {
            return const Scaffold(body: Center(child: Text('Missing payment data')));
          }
          return CardGatewayScreen(args: args);
        },
      ),
      GoRoute(
        path: '/pay/result',
        builder: (_, state) {
          final args = state.extra as PaymentResultArgs?;
          if (args == null) {
            return const Scaffold(body: Center(child: Text('Missing result data')));
          }
          return PaymentResultScreen(args: args);
        },
      ),
    ],
  );

  ref.listen(authProvider, (_, __) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
