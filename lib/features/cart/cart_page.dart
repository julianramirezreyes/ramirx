import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import 'cart_controller.dart';
import 'orders_repository.dart';
import '../uploads/uploads_repository.dart';
import '../../core/auth/auth_repository.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Text(
          'Carrito',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (cart.items.isEmpty) ...[
          const Text('Tu carrito está vacío.'),
        ] else ...[
          for (final item in cart.items) ...[
            _CartItemRow(item: item),
            const SizedBox(height: 10),
          ],
          const Divider(height: 28),
          Row(
            children: [
              Text(
                'Total',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                _formatMoney(cart.totalCents),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openExternal(
                context,
                Uri.parse('https://checkout.wompi.co/l/test_VPOS_X1tuPy'),
              ),
              icon: const Icon(Icons.lock),
              label: const Text('Pagar'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  final profile = await ref
                      .read(authRepositoryProvider)
                      .getUserProfile();
                  if (!context.mounted) return;
                  final fullName =
                      (profile['fullName'] as String?)?.trim() ?? '';
                  final whatsapp =
                      (profile['whatsapp'] as String?)?.trim() ?? '';
                  final address =
                      (profile['shippingAddress'] as String?)?.trim() ?? '';
                  if (fullName.isEmpty || whatsapp.isEmpty || address.isEmpty) {
                    final go = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Completa tus datos'),
                          content: const Text(
                            'Antes de adjuntar tu comprobante necesitamos tu nombre, WhatsApp y dirección de envío. Te llevaré a “Mi cuenta” para completarlos.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Ahora no'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Ir a Mi cuenta'),
                            ),
                          ],
                        );
                      },
                    );
                    if (go == true && context.mounted) {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    }
                    return;
                  }

                  final noteCtrl = TextEditingController();
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmar pedido'),
                        content: SizedBox(
                          width: 520,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Agrega una nota para tu pedido (obligatoria).',
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: noteCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Notas del cliente',
                                ),
                                maxLines: 4,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () {
                              final v = noteCtrl.text.trim();
                              if (v.isEmpty) return;
                              Navigator.pop(context, true);
                            },
                            child: const Text('Adjuntar comprobante y pedir'),
                          ),
                        ],
                      );
                    },
                  );
                  if (!context.mounted) return;

                  if (confirmed != true) return;
                  final customerNote = noteCtrl.text.trim();
                  if (customerNote.isEmpty) return;

                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    withData: true,
                    type: FileType.custom,
                    allowedExtensions: const [
                      'png',
                      'jpg',
                      'jpeg',
                      'webp',
                      'gif',
                      'pdf',
                    ],
                  );
                  final file = result?.files.firstOrNull;
                  if (file == null) return;
                  if (file.bytes == null) {
                    throw Exception('No se pudo leer el archivo');
                  }

                  final receiptUrl = await ref
                      .read(uploadsRepositoryProvider)
                      .uploadReceipt(bytes: file.bytes!, filename: file.name);
                  if (!context.mounted) return;

                  await ref
                      .read(ordersRepositoryProvider)
                      .createOrder(
                        cart.items,
                        customerNote: customerNote,
                        receiptUrl: receiptUrl,
                      );

                  await ref.read(cartControllerProvider.notifier).clear();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pedido enviado. Revisaremos tu comprobante.',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo enviar el pedido: $e')),
                  );
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Enviar comprobante y realizar pedido'),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => ref.read(cartControllerProvider.notifier).clear(),
            child: const Text('Vaciar carrito'),
          ),
        ],
      ],
    );
  }
}

class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${_formatMoney(item.priceCents)} x ${item.quantity}'),
                ],
              ),
            ),
            IconButton(
              onPressed: () => ref
                  .read(cartControllerProvider.notifier)
                  .setQty(item, item.quantity - 1),
              icon: const Icon(Icons.remove),
            ),
            Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            IconButton(
              onPressed: () => ref
                  .read(cartControllerProvider.notifier)
                  .setQty(item, item.quantity + 1),
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(cartControllerProvider.notifier).remove(item),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(int cents) {
  final value = cents / 100.0;
  return '\$${value.toStringAsFixed(2)}';
}
