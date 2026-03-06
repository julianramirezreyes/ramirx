import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/auth/auth_controller.dart';
import '../features/cart/cart_controller.dart';
import '../core/theme/theme_controller.dart';
import '../core/config.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  double _homeScrollT = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width < 720;
    final showCta = !isSmall && width >= 1080;
    final auth = ref.watch(authControllerProvider);
    final cart = ref.watch(cartControllerProvider);
    final theme = Theme.of(context);

    final uriPath = GoRouterState.of(context).uri.path;
    final isHome = uriPath == '/';
    final effectiveT = isHome ? _homeScrollT : 1.0;
    final appBarBg = Color.lerp(
      Colors.transparent,
      theme.colorScheme.surface,
      effectiveT,
    )!;

    Future<void> openExternal(Uri uri) async {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: isHome,
      drawer: isSmall
          ? Drawer(
              child: SafeArea(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      title: const Text('Inicio'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/');
                      },
                    ),
                    ListTile(
                      title: const Text('Servicios'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/servicios');
                      },
                    ),
                    ListTile(
                      title: const Text('Productos'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/productos');
                      },
                    ),
                    ListTile(
                      title: const Text('Capacitaciones'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/capacitaciones');
                      },
                    ),
                    ListTile(
                      title: const Text('Nosotros'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/nosotros');
                      },
                    ),
                    ListTile(
                      title: const Text('Contacto'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/contacto');
                      },
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: FilledButton.icon(
                        onPressed: () =>
                            openExternal(Uri.parse(AppConfig.whatsappUrl)),
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Agendar diagnóstico'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ListTile(
                      title: const Text('Carrito'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/cart');
                      },
                    ),
                    ListTile(
                      title: Text(
                        auth.isAuthenticated ? 'Mi cuenta' : 'Ingresar',
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(
                          auth.isAuthenticated ? '/account' : '/login',
                        );
                      },
                    ),
                    if (auth.isAdmin)
                      ListTile(
                        title: const Text('Admin'),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go('/admin');
                        },
                      ),
                  ],
                ),
              ),
            )
          : null,
      appBar: AppBar(
        titleSpacing: 16,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: appBarBg,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            InkWell(
              onTap: () => context.go('/'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Image.asset(
                  'assets/brand/logo.png',
                  height: 22,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            if (!isSmall) ...[
              const SizedBox(width: 16),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TopLink(
                        onPressed: () => context.go('/servicios'),
                        label: 'Servicios',
                      ),
                      _TopLink(
                        onPressed: () => context.go('/productos'),
                        label: 'Productos',
                      ),
                      _TopLink(
                        onPressed: () => context.go('/capacitaciones'),
                        label: 'Capacitaciones',
                      ),
                      _TopLink(
                        onPressed: () => context.go('/nosotros'),
                        label: 'Nosotros',
                      ),
                      _TopLink(
                        onPressed: () => context.go('/contacto'),
                        label: 'Contacto',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (showCta)
            FilledButton.icon(
              onPressed: () => openExternal(Uri.parse(AppConfig.whatsappUrl)),
              icon: const Icon(Icons.calendar_month),
              label: const Text('Agendar diagnóstico'),
            ),
          if (!isSmall && auth.isAdmin)
            TextButton(
              onPressed: () => context.go('/admin'),
              child: const Text('Admin'),
            ),
          _CartActionButton(
            qty: cart.totalQty,
            onPressed: () => context.go('/cart'),
          ),
          if (!isSmall)
            TextButton(
              onPressed: () =>
                  context.go(auth.isAuthenticated ? '/account' : '/login'),
              child: Text(auth.isAuthenticated ? 'Mi cuenta' : 'Ingresar'),
            ),
          IconButton(
            onPressed: () =>
                ref.read(themeControllerProvider.notifier).toggle(),
            icon: const Icon(Icons.brightness_6),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!isHome) return false;
          if (notification.metrics.axis != Axis.vertical) return false;

          final t = (notification.metrics.pixels / 72).clamp(0.0, 1.0);
          if (t == _homeScrollT) return false;

          setState(() {
            _homeScrollT = t;
          });
          return false;
        },
        child: widget.child,
      ),
    );
  }
}

class _CartActionButton extends StatelessWidget {
  const _CartActionButton({required this.qty, required this.onPressed});

  final int qty;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: onPressed,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.shopping_cart_outlined),
            if (qty > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    qty > 99 ? '99+' : '$qty',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopLink extends StatelessWidget {
  const _TopLink({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
