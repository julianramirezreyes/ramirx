import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config.dart';
import '../../core/formatters/money.dart';
import '../shared/image_gallery.dart';
import '../shared/sections_view.dart';
import 'services_repository.dart';

final serviceDetailProvider = FutureProvider.family<Service, String>((
  ref,
  id,
) async {
  return ref.read(servicesRepositoryProvider).getById(id);
});

class ServiceDetailPage extends ConsumerWidget {
  const ServiceDetailPage({super.key, required this.id});

  final String id;

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
    final asyncService = ref.watch(serviceDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Servicio')),
      body: asyncService.when(
        data: (s) {
          final theme = Theme.of(context);
          final sections = SectionModel.fromDynamic(s.sectionsJson);
          final images = s.imagesUrls.isNotEmpty
              ? s.imagesUrls
              : ((s.coverImageUrl ?? '').trim().isNotEmpty
                    ? [s.coverImageUrl!.trim()]
                    : const <String>[]);

          final price = formatCopFromCents(s.priceCents);
          final compareAt = s.compareAtPriceCents != null
              ? formatCopFromCents(s.compareAtPriceCents!)
              : null;

          Widget linkedArticlesSection() {
            if (s.linkedArticles.isEmpty) return const SizedBox.shrink();

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
                for (final a in s.linkedArticles)
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
                  s.name,
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
                      'Desde $price',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
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
                        s.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    if (isDesktop) const SizedBox(height: 12),
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
                          'Desde $price',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openExternal(
                          context,
                          Uri.parse(AppConfig.bookingUrl),
                        ),
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Agendar'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openExternal(
                          context,
                          Uri.parse(AppConfig.whatsappUrl),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('WhatsApp'),
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
                if ((s.description ?? '').trim().isNotEmpty) ...[
                  Text(s.description!, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                ],
                if (isDesktop) ...[
                  SectionsView(sections: sections),
                  const SizedBox(height: 16),
                ],
                if (!isDesktop) ...[
                  SectionsView(sections: sections),
                  const SizedBox(height: 16),
                ],
                if (isDesktop &&
                    (s.descriptionHtml ?? '').trim().isNotEmpty) ...[
                  HtmlWidget(s.descriptionHtml!),
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
                if ((s.descriptionHtml ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  HtmlWidget(s.descriptionHtml!),
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
        error: (e, _) => Center(child: Text('Error cargando servicio: $e')),
      ),
    );
  }
}
