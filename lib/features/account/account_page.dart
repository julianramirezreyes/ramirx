import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_repository.dart';
import 'change_password_page.dart';

final meProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(authRepositoryProvider).me();
});

final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(authRepositoryProvider).getUserProfile();
});

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Text(
          'Mi cuenta',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (!auth.isAuthenticated) ...[
          const Text('Inicia sesión para ver tu cuenta.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/login?next=/account'),
            child: const Text('Iniciar sesión'),
          ),
        ] else ...[
          Text('Rol: ${auth.role ?? '-'}'),
          Text('Tenant: ${auth.tenantId ?? '-'}'),
          const SizedBox(height: 12),
          ref
              .watch(meProvider)
              .when(
                data: (me) {
                  final email = me['email'];
                  final id = me['id'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (email is String) Text('Email: $email'),
                      if (id is String) Text('UserId: $id'),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (e, _) => Text('No se pudo cargar /auth/me: $e'),
              ),
          const SizedBox(height: 16),
          ref
              .watch(userProfileProvider)
              .when(
                data: (profile) {
                  final fullNameCtrl = TextEditingController(
                    text: profile['fullName'] as String?,
                  );
                  final whatsappCtrl = TextEditingController(
                    text: profile['whatsapp'] as String?,
                  );
                  final whatsappAltCtrl = TextEditingController(
                    text: profile['whatsappAlt'] as String?,
                  );
                  final addressCtrl = TextEditingController(
                    text: profile['shippingAddress'] as String?,
                  );

                  return Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Datos de contacto y envío',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: fullNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo',
                              hintText: 'Ej: Juan Pérez',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: whatsappCtrl,
                            decoration: const InputDecoration(
                              labelText: 'WhatsApp',
                              hintText: 'Ej: +57 300 000 0000',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: whatsappAltCtrl,
                            decoration: const InputDecoration(
                              labelText: 'WhatsApp de contacto (Opcional)',
                              hintText: 'Ej: +57 301 000 0000',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: addressCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Dirección completa de envío',
                              hintText:
                                  'Ciudad, dirección, casa/apto/conjunto, barrio y detalles adicionales',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(authRepositoryProvider)
                                      .updateUserProfile(
                                        fullName: fullNameCtrl.text.trim(),
                                        whatsapp: whatsappCtrl.text.trim(),
                                        whatsappAlt: whatsappAltCtrl.text
                                            .trim(),
                                        shippingAddress: addressCtrl.text
                                            .trim(),
                                      );
                                  ref.invalidate(userProfileProvider);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Datos guardados.'),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No se pudo guardar: $e'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Guardar datos'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (e, _) => Text('No se pudo cargar perfil: $e'),
              ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              );
            },
            child: const Text('Cambiar contraseña'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) return;
              context.go('/home');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ],
    );
  }
}
