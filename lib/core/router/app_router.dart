import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_page.dart';
import '../../shell/app_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/services',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: '/courses',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) => const Placeholder(),
          ),
        ],
      ),
    ],
  );
}
