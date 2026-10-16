import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/details/presentation/screens/product_details_screen.dart';
import '../../features/home/domain/entities/product.dart';
import '../../features/main_navigation/screens/main_navigation_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final router = createRouter();

  static GoRouter createRouter({String initialLocation = AppRoutes.splash}) =>
      GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: AppRoutes.splash,
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: AppRoutes.login,
            pageBuilder: (context, state) =>
                _fadePage(state, const LoginScreen()),
          ),
          GoRoute(
            path: AppRoutes.signUp,
            pageBuilder: (context, state) =>
                _fadePage(state, const SignUpScreen()),
          ),
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                _fadePage(state, const MainNavigationScreen()),
          ),
          // Deep link target: humavolve://app/products/:id
          GoRoute(
            path: AppRoutes.productDetails,
            pageBuilder: (context, state) => _fadePage(
              state,
              ProductDetailsScreen(
                productId: state.pathParameters['id']!,
                // only set when opened from inside the app
                product: state.extra is Product ? state.extra as Product : null,
              ),
              duration: const Duration(milliseconds: 500),
            ),
          ),
        ],
        errorBuilder: (context, state) => _NotFoundScreen(uri: state.uri),
      );

  static CustomTransitionPage<void> _fadePage(
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 300),
  }) => CustomTransitionPage(
    key: state.pageKey,
    transitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class _NotFoundScreen extends StatelessWidget {
  final Uri uri;

  const _NotFoundScreen({required this.uri});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Page not found: $uri', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(AppRoutes.splash),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
