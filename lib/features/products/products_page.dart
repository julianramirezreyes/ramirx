import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cart/cart_controller.dart';
import '../shared/item_card.dart';
import 'products_repository.dart';

final productsListProvider = FutureProvider<List<Product>>((ref) async {
  return ref.read(productsRepositoryProvider).list();
});

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productsListProvider);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1100
        ? 4
        : (width >= 820 ? 3 : (width >= 520 ? 2 : 1));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Text(
          'Productos',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        asyncProducts.when(
          data: (items) {
            if (items.isEmpty) {
              return const Text('No hay productos disponibles por ahora.');
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
                final p = items[index];
                return _ProductTile(product: p);
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error cargando productos: $e'),
        ),
      ],
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = _formatMoney(product.priceCents);
    final compareAtPrice = product.compareAtPriceCents != null
        ? _formatMoney(product.compareAtPriceCents!)
        : null;

    final imageUrl = product.imagesUrls.isNotEmpty
        ? product.imagesUrls.first
        : (product.coverImageUrl ?? '');

    return ItemCard(
      title: product.name,
      subtitle: (product.description ?? '').trim().isNotEmpty
          ? product.description
          : null,
      imageUrl: imageUrl,
      placeholderIcon: Icons.inventory_2_outlined,
      priceLabel: price,
      compareAtPriceLabel: compareAtPrice,
      onTap: () => context.go('/products/${product.id}'),
      primaryActionLabel: 'Agregar',
      primaryAction: () async {
        await ref
            .read(cartControllerProvider.notifier)
            .add(
              type: CartItemType.product,
              id: product.id,
              title: product.name,
              priceCents: product.priceCents,
            );
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Agregado al carrito')));
      },
    );
  }
}

String _formatMoney(int cents) {
  final value = cents / 100.0;
  return '\$${value.toStringAsFixed(2)}';
}
