import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../uploads/uploads_repository.dart';
import '../courses/courses_repository.dart';
import '../../core/formatters/money.dart';
import 'sections_editor.dart';

final adminCoursesProvider = FutureProvider<List<Course>>((ref) async {
  return ref.read(coursesRepositoryProvider).list();
});

class AdminCoursesPage extends ConsumerWidget {
  const AdminCoursesPage({super.key});

  Future<void> _openUpsertDialog(
    BuildContext context,
    WidgetRef ref, {
    Course? existing,
  }) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final priceCtrl = TextEditingController(
      text: existing == null
          ? ''
          : (existing.priceCents / 100).toStringAsFixed(2),
    );
    final compareAtCtrl = TextEditingController(
      text: (existing?.compareAtPriceCents != null)
          ? (existing!.compareAtPriceCents! / 100).toStringAsFixed(2)
          : '',
    );
    String level = existing?.level ?? 'beginner';
    final descHtmlCtrl = TextEditingController(
      text: existing?.descriptionHtml ?? '',
    );
    var imagesUrls = [...existing?.imagesUrls ?? const <String>[]];
    var coverImageUrl = (imagesUrls.isNotEmpty)
        ? imagesUrls.first
        : existing?.coverImageUrl;
    Uint8List? localImageBytes;
    var sections = EditableSection.fromDynamic(existing?.sectionsJson);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void syncCoverFromGallery() {
              coverImageUrl = imagesUrls.isNotEmpty ? imagesUrls.first : null;
            }

            Future<void> pickAndUploadImages() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: true,
                withData: true,
              );
              final files = result?.files;
              if (files == null || files.isEmpty) return;

              final first = files.first;
              if (first.bytes != null) {
                setState(() {
                  localImageBytes = first.bytes;
                });
              }

              try {
                for (final file in files) {
                  if (file.bytes == null) continue;
                  final url = await ref
                      .read(uploadsRepositoryProvider)
                      .uploadImage(bytes: file.bytes!, filename: file.name);
                  if (!context.mounted) return;
                  setState(() {
                    imagesUrls.add(url);
                    syncCoverFromGallery();
                  });
                }
                if (!context.mounted) return;
                setState(() {
                  localImageBytes = null;
                });
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error subiendo imagen: $e')),
                );
              }
            }

            return AlertDialog(
              title: Text(
                existing == null ? 'Nueva capacitación' : 'Editar capacitación',
              ),
              content: SizedBox(
                width: 520,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.75,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (localImageBytes != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.memory(
                                localImageBytes!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (imagesUrls.isNotEmpty) ...[
                          SizedBox(
                            height: 72,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: imagesUrls.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, i) {
                                final url = imagesUrls[i];
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 92,
                                        height: 72,
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox.shrink(),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: IconButton.filledTonal(
                                        style: IconButton.styleFrom(
                                          minimumSize: const Size(32, 32),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            imagesUrls.removeAt(i);
                                            syncCoverFromGallery();
                                          });
                                        },
                                        icon: const Icon(Icons.close, size: 16),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: pickAndUploadImages,
                              icon: const Icon(Icons.image_outlined),
                              label: const Text('Subir imágenes'),
                            ),
                            const SizedBox(width: 10),
                            if (imagesUrls.isNotEmpty ||
                                localImageBytes != null)
                              TextButton(
                                onPressed: () => setState(() {
                                  coverImageUrl = null;
                                  imagesUrls = [];
                                  localImageBytes = null;
                                }),
                                child: const Text('Quitar'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descHtmlCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Descripción HTML',
                          ),
                          maxLines: 6,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                    type: FileType.image,
                                    allowMultiple: false,
                                    withData: true,
                                  );
                              final file = result?.files.firstOrNull;
                              if (file == null) return;
                              if (file.bytes == null) return;

                              final url = await ref
                                  .read(uploadsRepositoryProvider)
                                  .uploadImage(
                                    bytes: file.bytes!,
                                    filename: file.name,
                                  );

                              final tag =
                                  '<img src="$url" style="max-width: 100%;" />';
                              final v = descHtmlCtrl.value;
                              final start = v.selection.start;
                              final end = v.selection.end;
                              if (start >= 0 && end >= 0) {
                                final nextText = v.text.replaceRange(
                                  start,
                                  end,
                                  tag,
                                );
                                descHtmlCtrl.value = v.copyWith(
                                  text: nextText,
                                  selection: TextSelection.collapsed(
                                    offset: start + tag.length,
                                  ),
                                  composing: TextRange.empty,
                                );
                              } else {
                                descHtmlCtrl.text =
                                    '${descHtmlCtrl.text}\n$tag';
                              }
                            },
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: const Text('Insertar imagen en HTML'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: level,
                          decoration: const InputDecoration(labelText: 'Nivel'),
                          items: const [
                            DropdownMenuItem(
                              value: 'beginner',
                              child: Text('Inicial'),
                            ),
                            DropdownMenuItem(
                              value: 'intermediate',
                              child: Text('Intermedio'),
                            ),
                            DropdownMenuItem(
                              value: 'advanced',
                              child: Text('Avanzado'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => level = v ?? 'beginner'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: priceCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Precio (ej: 12.50)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: compareAtCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Precio antes (tachado) (opcional)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SectionsEditor(
                          initial: sections,
                          onChanged: (next) => sections = next,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;

                    final price = double.tryParse(
                      priceCtrl.text.trim().replaceAll(',', '.'),
                    );
                    if (price == null) return;
                    final priceCents = (price * 100).round();

                    final compareAtRaw = compareAtCtrl.text.trim();
                    final compareAt = compareAtRaw.isEmpty
                        ? null
                        : double.tryParse(compareAtRaw.replaceAll(',', '.'));
                    if (compareAtRaw.isNotEmpty && compareAt == null) return;
                    final compareAtCents = compareAt == null
                        ? null
                        : (compareAt * 100).round();

                    final repo = ref.read(coursesRepositoryProvider);
                    if (existing == null) {
                      await repo.create(
                        title: title,
                        description: descCtrl.text,
                        coverImageUrl: coverImageUrl,
                        imagesUrls: imagesUrls.isEmpty ? null : imagesUrls,
                        descriptionHtml: descHtmlCtrl.text,
                        sectionsJson: sections
                            .map((e) => e.toJson())
                            .toList(growable: false),
                        level: level,
                        priceCents: priceCents,
                        compareAtPriceCents: compareAtCents,
                      );
                    } else {
                      await repo.update(
                        id: existing.id,
                        title: title,
                        description: descCtrl.text,
                        coverImageUrl: coverImageUrl,
                        imagesUrls: imagesUrls.isEmpty ? null : imagesUrls,
                        descriptionHtml: descHtmlCtrl.text,
                        sectionsJson: sections
                            .map((e) => e.toJson())
                            .toList(growable: false),
                        level: level,
                        priceCents: priceCents,
                        compareAtPriceCents: compareAtCents,
                      );
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      ref.invalidate(adminCoursesProvider);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Course item,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar'),
          content: Text(
            '¿Eliminar "${item.title}"? Esta acción es irreversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;
    await ref.read(coursesRepositoryProvider).delete(id: item.id);
    ref.invalidate(adminCoursesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(adminCoursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Capacitaciones')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openUpsertDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: asyncItems.when(
        data: (items) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No hay capacitaciones.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Capacitaciones',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Refrescar',
                      onPressed: () => ref.invalidate(adminCoursesProvider),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: items.length,
                    onReorder: (oldIndex, newIndex) async {
                      try {
                        final current = List<Course>.from(items);
                        if (newIndex > oldIndex) newIndex -= 1;
                        final moved = current.removeAt(oldIndex);
                        current.insert(newIndex, moved);

                        await ref
                            .read(coursesRepositoryProvider)
                            .adminReorder(current);
                        ref.invalidate(adminCoursesProvider);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No se pudo reordenar: $e')),
                        );
                      }
                    },
                    itemBuilder: (context, index) {
                      final c = items[index];
                      return Card(
                        key: ValueKey(c.id),
                        child: ListTile(
                          title: Text(c.title),
                          subtitle: Text(
                            '${formatCopFromCents(c.priceCents)} • nivel ${c.level}',
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle),
                              ),
                              IconButton(
                                tooltip: 'Editar',
                                onPressed: () => _openUpsertDialog(
                                  context,
                                  ref,
                                  existing: c,
                                ),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                tooltip: 'Duplicar',
                                onPressed: () async {
                                  final repo = ref.read(
                                    coursesRepositoryProvider,
                                  );
                                  await repo.create(
                                    title: '${c.title} (copia)',
                                    description: c.description,
                                    coverImageUrl: c.coverImageUrl,
                                    imagesUrls: c.imagesUrls.isEmpty
                                        ? null
                                        : c.imagesUrls,
                                    descriptionHtml: c.descriptionHtml,
                                    sectionsJson: c.sectionsJson,
                                    level: c.level,
                                    priceCents: c.priceCents,
                                    compareAtPriceCents: c.compareAtPriceCents,
                                  );
                                  ref.invalidate(adminCoursesProvider);
                                },
                                icon: const Icon(Icons.copy),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                onPressed: () =>
                                    _confirmDelete(context, ref, c),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Error: $e'),
        ),
      ),
    );
  }
}
