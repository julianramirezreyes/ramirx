import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Text(
          'Contacto',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Si desea desarrollar un proyecto tecnológico, implementar un sistema personalizado o recibir más información sobre nuestros servicios, puede comunicarse directamente.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.4,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => _openExternal(context, Uri.parse(AppConfig.whatsappUrl)),
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('WhatsApp'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _openExternal(
            context,
            Uri.parse('mailto:ramirexdev@gmail.com'),
          ),
          icon: const Icon(Icons.email_outlined),
          label: const Text('Enviar correo'),
        ),
        const SizedBox(height: 18),
        Text(
          'RAMIRX\nItagüí – Antioquia\nColombia',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.55,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
