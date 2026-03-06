import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';

import '../cart/cart_controller.dart';
import '../shared/image_gallery.dart';
import '../shared/sections_view.dart';
import 'products_repository.dart';
import '../../core/formatters/money.dart';

final productDetailProvider = FutureProvider.family<Product, String>((
  ref,
  id,
) async {
  return ref.read(productsRepositoryProvider).getById(id);
});

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _qty = 1;

  List<String> _resolveImages(Product p) {
    if (p.imagesUrls.isNotEmpty) return p.imagesUrls;
    final cover = (p.coverImageUrl ?? '').trim();
    return cover.isNotEmpty ? [cover] : const [];
  }

  @override
  Widget build(BuildContext context) {
    final asyncProduct = ref.watch(productDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Producto')),
      body: asyncProduct.when(
        data: (p) {
          final theme = Theme.of(context);
          final sections = SectionModel.fromDynamic(p.sectionsJson);
          final images = _resolveImages(p);
          final price = formatCopFromCents(p.priceCents);
          final compareAt = p.compareAtPriceCents != null
              ? formatCopFromCents(p.compareAtPriceCents!)
              : null;

          Widget linkedArticlesSection() {
            if (p.linkedArticles.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Artículos vinculados',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                for (final a in p.linkedArticles)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: (a.coverImageUrl ?? '').trim().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              a.coverImageUrl!,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const SizedBox(width: 54, height: 54),
                    title: Text(
                      a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(formatCopFromCents(a.priceCents)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (a.type == 'product') {
                        context.push('/products/${a.id}');
                      } else if (a.type == 'course') {
                        context.push('/courses/${a.id}');
                      } else if (a.type == 'service') {
                        context.push('/services/${a.id}');
                      }
                    },
                  ),
              ],
            );
          }

          Widget mobileHeader() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if ((compareAt ?? '').trim().isNotEmpty) ...[
                      Text(
                        compareAt!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      price,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          Widget qtyRow() {
            return Row(
              children: [
                IconButton(
                  onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$_qty',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                IconButton(
                  onPressed: () => setState(() => _qty++),
                  icon: const Icon(Icons.add),
                ),
              ],
            );
          }

          Future<void> addToCart() async {
            for (int i = 0; i < _qty; i++) {
              await ref
                  .read(cartControllerProvider.notifier)
                  .add(
                    type: CartItemType.product,
                    id: p.id,
                    title: p.name,
                    priceCents: p.priceCents,
                  );
            }
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Agregado al carrito')),
            );
          }

          Widget ctaCard({required bool isDesktop}) {
            return Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop)
                      Text(
                        p.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    if (isDesktop) const SizedBox(height: 8),
                    Row(
                      children: [
                        if ((compareAt ?? '').trim().isNotEmpty) ...[
                          Text(
                            compareAt!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          price,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${p.stockQty}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    qtyRow(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: addToCart,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Agregar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          Widget detailsColumn({required bool isDesktop}) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (images.isNotEmpty) ...[
                  ImageGallery(imageUrls: images),
                  const SizedBox(height: 16),
                ],
                if (!isDesktop && (p.description ?? '').trim().isNotEmpty) ...[
                  Text(p.description!, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                ],
                if (!isDesktop) ...[
                  SectionsView(sections: sections),
                  const SizedBox(height: 16),
                ],
                if (isDesktop && (p.description ?? '').trim().isNotEmpty) ...[
                  Text(p.description!, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                ],
                if (isDesktop) ...[
                  SectionsView(sections: sections),
                  const SizedBox(height: 16),
                ],
                if (isDesktop &&
                    (p.descriptionHtml ?? '').trim().isNotEmpty) ...[
                  HtmlWidget(p.descriptionHtml!),
                  const SizedBox(height: 16),
                ],

                linkedArticlesSection(),
              ],
            );
          }

          Widget belowCtaMobile() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if ((p.descriptionHtml ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  HtmlWidget(p.descriptionHtml!),
                ],

                linkedArticlesSection(),
              ],
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: detailsColumn(isDesktop: true),
                              ),
                              const SizedBox(width: 24),
                              SizedBox(
                                width: 360,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [ctaCard(isDesktop: true)],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              mobileHeader(),
                              const SizedBox(height: 14),
                              detailsColumn(isDesktop: false),
                              const SizedBox(height: 16),
                              ctaCard(isDesktop: false),
                              belowCtaMobile(),
                            ],
                          ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error cargando producto: $e')),
      ),
    );
  }
}
