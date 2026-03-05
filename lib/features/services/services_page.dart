import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/item_card.dart';
import 'services_repository.dart';

final servicesListProvider = FutureProvider<List<Service>>((ref) async {
  return ref.read(servicesRepositoryProvider).list();
});

class ServicesPage extends ConsumerWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncServices = ref.watch(servicesListProvider);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1100
        ? 4
        : (width >= 820 ? 3 : (width >= 520 ? 2 : 1));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Text(
          'Servicios',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        asyncServices.when(
          data: (items) {
            if (items.isEmpty) {
              return const Text('No hay servicios disponibles por ahora.');
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final s = items[index];

                final imageUrl = s.imagesUrls.isNotEmpty
                    ? s.imagesUrls.first
                    : (s.coverImageUrl ?? '');

                final price = (s.priceCents / 100).toStringAsFixed(2);
                final compareAt = s.compareAtPriceCents != null
                    ? (s.compareAtPriceCents! / 100).toStringAsFixed(2)
                    : null;

                return ItemCard(
                  title: s.name,
                  subtitle: (s.description ?? '').trim().isNotEmpty
                      ? s.description
                      : null,
                  imageUrl: imageUrl,
                  placeholderIcon: Icons.design_services_outlined,
                  badge: _ServiceBadge(),
                  priceLabel: '\$$price',
                  compareAtPriceLabel: (compareAt ?? '').trim().isNotEmpty
                      ? '\$$compareAt'
                      : null,
                  onTap: () => context.go('/services/${s.id}'),
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error cargando servicios: $e'),
        ),
      ],
    );
  }
}

class _ServiceBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.70,
        ),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Text(
        'Servicio',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
