import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../article_links/article_links_repository.dart'
    as links_repo;
import '../courses/courses_repository.dart' as courses_repo;
import '../products/products_repository.dart' as products_repo;
import '../services/services_repository.dart' as services_repo;

class LinkedArticlesEditorDialog {
  static Future<void> open({
    required BuildContext context,
    required WidgetRef ref,
    required String fromType,
    required String fromId,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return _LinkedArticlesEditorDialog(fromType: fromType, fromId: fromId);
      },
    );
  }
}

class _LinkedArticlesEditorDialog extends ConsumerStatefulWidget {
  const _LinkedArticlesEditorDialog({required this.fromType, required this.fromId});

  final String fromType;
  final String fromId;

  @override
  ConsumerState<_LinkedArticlesEditorDialog> createState() =>
      _LinkedArticlesEditorDialogState();
}

class _LinkedArticlesEditorDialogState
    extends ConsumerState<_LinkedArticlesEditorDialog> {
  bool _loading = true;
  bool _saving = false;
  String _query = '';
  int _tabIndex = 0;

  List<_SelectableItem> _products = const [];
  List<_SelectableItem> _courses = const [];
  List<_SelectableItem> _services = const [];

  final List<_SelectedItem> _selected = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ref.read(products_repo.productsRepositoryProvider).list(),
        ref.read(courses_repo.coursesRepositoryProvider).list(),
        ref.read(services_repo.servicesRepositoryProvider).list(),
        ref
            .read(links_repo.articleLinksRepositoryProvider)
            .list(fromType: widget.fromType, fromId: widget.fromId),
      ]);

      final products = results[0] as List<products_repo.Product>;
      final courses = results[1] as List<courses_repo.Course>;
      final services = results[2] as List<services_repo.Service>;
      final existing = results[3] as List<links_repo.LinkedArticleSummary>;

      setState(() {
        _products = products
            .map((p) => _SelectableItem(
                  type: 'product',
                  id: p.id,
                  title: p.name,
                  coverImageUrl: p.coverImageUrl,
                  priceCents: p.priceCents,
                ))
            .toList(growable: false);
        _courses = courses
            .map((c) => _SelectableItem(
                  type: 'course',
                  id: c.id,
                  title: c.title,
                  coverImageUrl: c.coverImageUrl,
                  priceCents: c.priceCents,
                ))
            .toList(growable: false);
        _services = services
            .map((s) => _SelectableItem(
                  type: 'service',
                  id: s.id,
                  title: s.name,
                  coverImageUrl: s.coverImageUrl,
                  priceCents: s.priceCents,
                ))
            .toList(growable: false);

        _selected
          ..clear()
          ..addAll(
            existing.map(
              (x) => _SelectedItem(
                type: x.type,
                id: x.id,
                title: x.title,
                coverImageUrl: x.coverImageUrl,
                priceCents: x.priceCents,
                compareAtPriceCents: x.compareAtPriceCents,
              ),
            ),
          );
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isSelected(String type, String id) {
    return _selected.any((s) => s.type == type && s.id == id);
  }

  void _add(_SelectableItem it) {
    if (_isSelected(it.type, it.id)) return;
    setState(() {
      _selected.add(
        _SelectedItem(
          type: it.type,
          id: it.id,
          title: it.title,
          coverImageUrl: it.coverImageUrl,
          priceCents: it.priceCents,
          compareAtPriceCents: null,
        ),
      );
    });
  }

  void _remove(_SelectedItem it) {
    setState(() {
      _selected.removeWhere((x) => x.type == it.type && x.id == it.id);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(links_repo.articleLinksRepositoryProvider).setLinks(
            fromType: widget.fromType,
            fromId: widget.fromId,
            linked: _selected
                .map(
                  (x) => links_repo.LinkedArticleSummary(
                    type: x.type,
                    id: x.id,
                    title: x.title,
                    coverImageUrl: x.coverImageUrl,
                    priceCents: x.priceCents,
                    compareAtPriceCents: x.compareAtPriceCents,
                  ),
                )
                .toList(growable: false),
          );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando vínculos: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<_SelectableItem> _activeList() {
    if (_tabIndex == 0) return _products;
    if (_tabIndex == 1) return _courses;
    return _services;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final list = _activeList();
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? list
        : list
            .where((x) => x.title.toLowerCase().contains(q))
            .toList(growable: false);

    return AlertDialog(
      title: const Text('Artículos vinculados'),
      content: SizedBox(
        width: 820,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Buscar',
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 12),
                    DefaultTabController(
                      length: 3,
                      initialIndex: _tabIndex,
                      child: Column(
                        children: [
                          TabBar(
                            onTap: (i) => setState(() => _tabIndex = i),
                            tabs: const [
                              Tab(text: 'Productos'),
                              Tab(text: 'Cursos'),
                              Tab(text: 'Servicios'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 0,
                              color: theme.colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.35),
                              child: ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final it = filtered[i];
                                  final selected = _isSelected(it.type, it.id);
                                  return ListTile(
                                    leading: (it.coverImageUrl ?? '')
                                            .trim()
                                            .isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              it.coverImageUrl!,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const SizedBox(
                                                width: 40,
                                                height: 40,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(
                                            width: 40,
                                            height: 40,
                                          ),
                                    title: Text(
                                      it.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: selected
                                        ? IconButton(
                                            tooltip: 'Quitar',
                                            onPressed: () {
                                              final sel = _selected.firstWhere(
                                                (x) =>
                                                    x.type == it.type &&
                                                    x.id == it.id,
                                              );
                                              _remove(sel);
                                            },
                                            icon: const Icon(Icons.close),
                                          )
                                        : FilledButton.tonalIcon(
                                            onPressed: () => _add(it),
                                            icon: const Icon(Icons.add),
                                            label: const Text('Agregar'),
                                          ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              elevation: 0,
                              color: theme.colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.35),
                              child: ReorderableListView.builder(
                                itemCount: _selected.length,
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (oldIndex < newIndex) newIndex -= 1;
                                    final it = _selected.removeAt(oldIndex);
                                    _selected.insert(newIndex, it);
                                  });
                                },
                                itemBuilder: (context, i) {
                                  final it = _selected[i];
                                  return ListTile(
                                    key: ValueKey('${it.type}:${it.id}'),
                                    leading: ReorderableDragStartListener(
                                      index: i,
                                      child: const Icon(Icons.drag_handle),
                                    ),
                                    title: Text(
                                      it.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(it.type),
                                    trailing: IconButton(
                                      tooltip: 'Quitar',
                                      onPressed: () => _remove(it),
                                      icon: const Icon(Icons.close),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Guardando…' : 'Guardar'),
        ),
      ],
    );
  }
}

class _SelectableItem {
  const _SelectableItem({
    required this.type,
    required this.id,
    required this.title,
    required this.coverImageUrl,
    required this.priceCents,
  });

  final String type;
  final String id;
  final String title;
  final String? coverImageUrl;
  final int priceCents;
}

class _SelectedItem {
  const _SelectedItem({
    required this.type,
    required this.id,
    required this.title,
    required this.coverImageUrl,
    required this.priceCents,
    required this.compareAtPriceCents,
  });

  final String type;
  final String id;
  final String title;
  final String? coverImageUrl;
  final int priceCents;
  final int? compareAtPriceCents;
}
