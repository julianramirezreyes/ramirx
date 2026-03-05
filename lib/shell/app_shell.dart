import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_controller.dart';
import '../features/cart/cart_controller.dart';
import '../core/theme/theme_controller.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmall = MediaQuery.sizeOf(context).width < 720;
    final auth = ref.watch(authControllerProvider);
    final cart = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        elevation: 0,
        title: Row(
          children: [
            InkWell(
              onTap: () => context.go('/home'),
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
              _TopLink(
                onPressed: () => context.go('/services'),
                label: 'Servicios',
              ),
              _TopLink(
                onPressed: () => context.go('/products'),
                label: 'Productos',
              ),
              _TopLink(
                onPressed: () => context.go('/courses'),
                label: 'Capacitaciones',
              ),
            ],
          ],
        ),
        actions: [
          if (auth.isAdmin)
            TextButton(
              onPressed: () => context.go('/admin'),
              child: const Text('Admin'),
            ),
          _CartActionButton(
            qty: cart.totalQty,
            onPressed: () => context.go('/cart'),
          ),
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
      body: child,
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
