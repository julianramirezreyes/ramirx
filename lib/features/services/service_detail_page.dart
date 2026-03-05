import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config.dart';
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

          final price = (s.priceCents / 100).toStringAsFixed(2);
          final compareAt = s.compareAtPriceCents != null
              ? (s.compareAtPriceCents! / 100).toStringAsFixed(2)
              : null;

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
                        '\$$compareAt',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      '\$$price',
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
                    Text(
                      s.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (!isDesktop &&
                        (s.description ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(s.description!, style: theme.textTheme.bodyLarge),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if ((compareAt ?? '').trim().isNotEmpty) ...[
                          Text(
                            '\$$compareAt',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          '\$$price',
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
                if (isDesktop &&
                    (s.descriptionHtml ?? '').trim().isNotEmpty) ...[
                  HtmlWidget(s.descriptionHtml!),
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
                SectionsView(sections: sections),
                if ((s.descriptionHtml ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  HtmlWidget(s.descriptionHtml!),
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
                                  children: [
                                    ctaCard(isDesktop: true),
                                    const SizedBox(height: 16),
                                    SectionsView(sections: sections),
                                  ],
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
