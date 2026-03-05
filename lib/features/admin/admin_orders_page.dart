import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cart/orders_repository.dart';

final adminOrdersProvider = FutureProvider<List<OrderSummary>>((ref) async {
  return ref.read(ordersRepositoryProvider).adminListOrders();
});

class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  static const _statusOptions = <String, String>{
    'draft': 'Borrador',
    'pending_review': 'Pendiente por revisar',
    'approved': 'Aprobado',
    'pending_delivery': 'Pendiente por entregar',
    'delivered': 'Entregado',
    'rejected': 'Rechazado',
    'cancelled': 'Cancelado',
  };

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  Future<void> _openOrderDetail(
    BuildContext context,
    WidgetRef ref,
    OrderSummary order,
  ) async {
    try {
      final detail = await ref
          .read(ordersRepositoryProvider)
          .adminGetOrder(order.id);
      if (!context.mounted) return;

      String status = detail.order.status;
      final adminNoteCtrl = TextEditingController(
        text: detail.order.adminNote ?? '',
      );

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Pedido ${detail.order.id}'),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _statusOptions.containsKey(status)
                        ? status
                        : 'draft',
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: _statusOptions.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (v) {
                      if (v == null) return;
                      status = v;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: \$${(detail.order.totalAmountCents / 100).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text('Creado: ${detail.order.createdAt.toLocal()}'),
                  const SizedBox(height: 12),
                  if ((detail.order.customerNote ?? '').trim().isNotEmpty) ...[
                    const Text(
                      'Notas del cliente',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(detail.order.customerNote!.trim()),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: adminNoteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nota interna (admin)',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Items',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  for (final it in detail.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '- ${it.type} · ${it.quantity} x \$${(it.priceCents / 100).toStringAsFixed(2)}',
                      ),
                    ),
                  const SizedBox(height: 12),
                  if ((detail.order.receiptUrl ?? '').trim().isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openExternal(
                          context,
                          Uri.parse(detail.order.receiptUrl!),
                        ),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Ver comprobante'),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Eliminar pedido'),
                        content: const Text(
                          'Esta acción elimina el pedido y sus items. ¿Deseas continuar?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      );
                    },
                  );
                  if (ok != true) return;
                  await ref
                      .read(ordersRepositoryProvider)
                      .adminDeleteOrder(detail.order.id);
                  ref.invalidate(adminOrdersProvider);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Eliminar'),
              ),
              FilledButton.tonal(
                onPressed: () async {
                  try {
                    await ref
                        .read(ordersRepositoryProvider)
                        .adminUpdateOrder(
                          detail.order.id,
                          status: status,
                          adminNote: adminNoteCtrl.text.trim(),
                        );
                    ref.invalidate(adminOrdersProvider);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pedido actualizado.')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No se pudo actualizar: $e')),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Pedidos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          asyncItems.when(
            data: (items) {
              if (items.isEmpty) return const Text('No hay pedidos.');
              return Card(
                elevation: 0,
                child: Column(
                  children: [
                    for (final o in items)
                      ListTile(
                        title: Text(
                          'Pedido ${o.id.substring(0, 8)}…',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${o.status} · \$${(o.totalAmountCents / 100).toStringAsFixed(2)}'
                          '${(o.receiptUrl ?? '').trim().isNotEmpty ? ' · con comprobante' : ''}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openOrderDetail(context, ref, o),
                      ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}
