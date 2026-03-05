import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Text(
          'Admin',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text('Rol: ${auth.role ?? '-'}'),
        const SizedBox(height: 16),
        _LinkCard(
          title: 'Servicios',
          subtitle: 'Crear/editar/eliminar servicios',
          onTap: () => context.go('/admin/services'),
        ),
        const SizedBox(height: 12),
        _LinkCard(
          title: 'Productos',
          subtitle: 'Crear/editar/eliminar productos',
          onTap: () => context.go('/admin/products'),
        ),
        const SizedBox(height: 12),
        _LinkCard(
          title: 'Capacitaciones',
          subtitle: 'Crear/editar/eliminar capacitaciones',
          onTap: () => context.go('/admin/courses'),
        ),
        const SizedBox(height: 12),
        _LinkCard(
          title: 'Pedidos',
          subtitle: 'Ver pedidos y comprobantes',
          onTap: () => context.go('/admin/orders'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
