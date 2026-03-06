import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cart/cart_controller.dart';
import '../shared/item_card.dart';
import 'courses_repository.dart';
import '../../core/formatters/money.dart';

final coursesListProvider = FutureProvider<List<Course>>((ref) async {
  return ref.read(coursesRepositoryProvider).list();
});

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCourses = ref.watch(coursesListProvider);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1100
        ? 4
        : (width >= 820 ? 3 : (width >= 520 ? 2 : 1));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Text(
          'Formación técnica',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        asyncCourses.when(
          data: (items) {
            if (items.isEmpty) {
              return const Text('No hay capacitaciones disponibles por ahora.');
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
                final c = items[index];
                return _CourseTile(course: c);
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error cargando capacitaciones: $e'),
        ),
      ],
    );
  }
}

class _CourseTile extends ConsumerWidget {
  const _CourseTile({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = formatCopFromCents(course.priceCents);
    final compareAtPrice = course.compareAtPriceCents != null
        ? formatCopFromCents(course.compareAtPriceCents!)
        : null;

    final imageUrl = course.imagesUrls.isNotEmpty
        ? course.imagesUrls.first
        : (course.coverImageUrl ?? '');

    return ItemCard(
      title: course.title,
      subtitle: (course.description ?? '').trim().isNotEmpty
          ? course.description
          : null,
      imageUrl: imageUrl,
      placeholderIcon: Icons.school_outlined,
      priceLabel: price,
      compareAtPriceLabel: compareAtPrice,
      badge: _LevelBadge(level: course.level),
      onTap: () => context.go('/capacitaciones/${course.id}'),
      primaryActionLabel: 'Agregar',
      primaryAction: () async {
        await ref
            .read(cartControllerProvider.notifier)
            .add(
              type: CartItemType.course,
              id: course.id,
              title: course.title,
              priceCents: course.priceCents,
            );
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Agregado al carrito')));
      },
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (level) {
      'beginner' => 'Inicial',
      'intermediate' => 'Intermedio',
      'advanced' => 'Avanzado',
      _ => level,
    };

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
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
