import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/explore/presentation/screens/explore_screen.dart';
import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/navigation/presentation/wen_shell.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/my_business_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/application/admin_providers.dart';
import '../features/auth/application/auth_providers.dart';
import '../features/businesses/data/models/business.dart';
import '../features/businesses/presentation/screens/business_details_screen.dart';
import 'routes/app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _exploreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'explore');
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _favoritesNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'favorites',
);
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutePath.explore,
    redirect: (context, state) {
      final isAdmin = ref.read(isAdminProvider);
      final target = state.uri.toString();
      if (target.startsWith(AppRoutePath.admin) && !isAdmin) {
        return AppRoutePath.profile;
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            WenShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _exploreNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutePath.explore,
                name: 'explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutePath.search,
                name: 'search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _favoritesNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutePath.favorites,
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutePath.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'my-business',
                    name: 'my-business',
                    builder: (context, state) => const MyBusinessScreen(),
                  ),
                  GoRoute(
                    path: 'admin',
                    name: 'admin',
                    builder: (context, state) => const AdminDashboardScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutePath.businessDetails,
        name: 'business-details',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          final business = extra is Business ? extra : null;
          return BusinessDetailsScreen(
            businessId: id,
            initialBusiness: business,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Route not found: ${state.uri}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  ref.listen(authStateChangesProvider, (_, __) => router.refresh());
  ref.listen(isAdminProvider, (_, __) => router.refresh());
  return router;
});
