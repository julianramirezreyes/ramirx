import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/account_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/cart/cart_page.dart';
import '../../features/courses/courses_page.dart';
import '../../features/courses/course_detail_page.dart';
import '../../features/home/home_page.dart';
import '../../features/products/products_page.dart';
import '../../features/products/product_detail_page.dart';
import '../../features/services/services_page.dart';
import '../../features/services/service_detail_page.dart';
import '../../features/static/about_page.dart';
import '../../features/static/contact_page.dart';
import '../../features/admin/admin_home_page.dart';
import '../../features/admin/admin_services_page.dart';
import '../../features/admin/admin_products_page.dart';
import '../../features/admin/admin_courses_page.dart';
import '../../features/admin/admin_orders_page.dart';
import '../../shell/app_shell.dart';
import '../auth/auth_controller.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(path: '/home', redirect: (_, __) => '/'),
          GoRoute(
            path: '/servicios',
            builder: (context, state) => const ServicesPage(),
          ),
          GoRoute(
            path: '/servicios/:id',
            builder: (context, state) =>
                ServiceDetailPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/productos',
            builder: (context, state) => const ProductsPage(),
          ),
          GoRoute(
            path: '/productos/:id',
            builder: (context, state) =>
                ProductDetailPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/capacitaciones',
            builder: (context, state) => const CoursesPage(),
          ),
          GoRoute(
            path: '/capacitaciones/:id',
            builder: (context, state) =>
                CourseDetailPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/nosotros',
            builder: (context, state) => const AboutPage(),
          ),
          GoRoute(
            path: '/contacto',
            builder: (context, state) => const ContactPage(),
          ),
          GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
          GoRoute(
            path: '/account',
            builder: (context, state) => const AccountPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) {
              final next = state.uri.queryParameters['next'];
              return LoginPage(next: next);
            },
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) {
              final next = state.uri.queryParameters['next'];
              return RegisterPage(next: next);
            },
          ),

          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminHomePage(),
          ),
          GoRoute(
            path: '/admin/services',
            builder: (context, state) => const AdminServicesPage(),
          ),
          GoRoute(
            path: '/admin/products',
            builder: (context, state) => const AdminProductsPage(),
          ),
          GoRoute(
            path: '/admin/courses',
            builder: (context, state) => const AdminCoursesPage(),
          ),
          GoRoute(
            path: '/admin/orders',
            builder: (context, state) => const AdminOrdersPage(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final path = state.uri.path;
      final loggedIn = auth.isAuthenticated;
      final isAdmin = auth.isAdmin;

      if (auth.isLoading) {
        return null;
      }

      final isAuthPage = path == '/login' || path == '/register';
      final needsAuth = path == '/account' || path == '/cart';
      final isAdminRoute = path == '/admin' || path.startsWith('/admin/');

      if (!loggedIn && needsAuth) {
        return '/login?next=$path';
      }

      if (isAdminRoute) {
        if (!loggedIn) return '/login?next=$path';
        if (!isAdmin) return '/';
      }

      if (loggedIn && isAuthPage) {
        final next = state.uri.queryParameters['next'];
        return (next != null && next.isNotEmpty) ? next : '/account';
      }

      return null;
    },
  );
});
