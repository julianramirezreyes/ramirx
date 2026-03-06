import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../cart/cart_controller.dart';
import '../shared/image_gallery.dart';
import '../shared/sections_view.dart';
import 'courses_repository.dart';
import '../../core/formatters/money.dart';

final courseDetailProvider = FutureProvider.family<Course, String>((
  ref,
  id,
) async {
  return ref.read(coursesRepositoryProvider).getById(id);
});

class CourseDetailPage extends ConsumerStatefulWidget {
  const CourseDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends ConsumerState<CourseDetailPage> {
  int _qty = 1;

  List<String> _resolveImages(Course c) {
    if (c.imagesUrls.isNotEmpty) return c.imagesUrls;
    final cover = (c.coverImageUrl ?? '').trim();
    return cover.isNotEmpty ? [cover] : const [];
  }

  @override
  Widget build(BuildContext context) {
    final asyncCourse = ref.watch(courseDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Capacitación')),
      body: asyncCourse.when(
        data: (c) {
          final theme = Theme.of(context);
          final sections = SectionModel.fromDynamic(c.sectionsJson);
          final images = _resolveImages(c);
          final price = formatCopFromCents(c.priceCents);
          final compareAt = c.compareAtPriceCents != null
              ? formatCopFromCents(c.compareAtPriceCents!)
              : null;

          Widget mobileHeader() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoChip(label: 'Nivel: ${c.level}'),
                    _InfoChip(label: price),
                    if ((compareAt ?? '').trim().isNotEmpty)
                      _InfoChip(label: 'Antes: $compareAt'),
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
                    type: CartItemType.course,
                    id: c.id,
                    title: c.title,
                    priceCents: c.priceCents,
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
                        c.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    if (isDesktop) const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _InfoChip(label: 'Nivel: ${c.level}'),
                        _InfoChip(label: price),
                        if ((compareAt ?? '').trim().isNotEmpty)
                          _InfoChip(label: 'Antes: $compareAt'),
                      ],
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
                if (!isDesktop && (c.description ?? '').trim().isNotEmpty) ...[
                  Text(c.description!, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                ],
                if (!isDesktop) ...[
                  SectionsView(sections: sections),
                  const SizedBox(height: 16),
                ],
                if (isDesktop && (c.description ?? '').trim().isNotEmpty) ...[
                  Text(c.description!, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                ],
                if (isDesktop) ...[
                  SectionsView(sections: sections),
                  const SizedBox(height: 16),
                ],
                if (isDesktop &&
                    (c.descriptionHtml ?? '').trim().isNotEmpty) ...[
                  HtmlWidget(c.descriptionHtml!),
                  const SizedBox(height: 16),
                ],
              ],
            );
          }

          Widget belowCtaMobile() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if ((c.descriptionHtml ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  HtmlWidget(c.descriptionHtml!),
                ],
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
        error: (e, _) => Center(child: Text('Error cargando capacitación: $e')),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
