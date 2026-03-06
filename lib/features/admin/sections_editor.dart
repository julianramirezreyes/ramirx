import 'package:flutter/material.dart';

class EditableSection {
  EditableSection({required this.title, required this.bullets});

  String title;
  List<String> bullets;

  Map<String, dynamic> toJson() => {'title': title, 'bullets': bullets};

  static List<EditableSection> fromDynamic(dynamic raw) {
    if (raw is! List) return [];

    final out = <EditableSection>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final title = item['title'];
      final bulletsRaw = item['bullets'];
      if (title is! String || title.trim().isEmpty) continue;

      final bullets = <String>[];
      if (bulletsRaw is List) {
        for (final b in bulletsRaw) {
          if (b is String && b.trim().isNotEmpty) bullets.add(b.trim());
        }
      }

      out.add(EditableSection(title: title.trim(), bullets: bullets));
    }

    return out;
  }
}

class SectionsEditor extends StatefulWidget {
  const SectionsEditor({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  final List<EditableSection> initial;
  final ValueChanged<List<EditableSection>> onChanged;

  @override
  State<SectionsEditor> createState() => _SectionsEditorState();
}

class _SectionsEditorState extends State<SectionsEditor> {
  late List<EditableSection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = widget.initial
        .map((s) => EditableSection(title: s.title, bullets: [...s.bullets]))
        .toList();
  }

  void _emit() => widget.onChanged(_sections);

  Future<String?> _promptText({
    required String title,
    required String label,
    String initialValue = '',
    int maxLines = 1,
    String okLabel = 'Guardar',
  }) async {
    final ctrl = TextEditingController(text: initialValue);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctrl,
            decoration: InputDecoration(labelText: label),
            maxLines: maxLines,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(okLabel),
            ),
          ],
        );
      },
    );

    if (ok != true) return null;
    final value = ctrl.text.trim();
    if (value.isEmpty) return null;
    return value;
  }

  Future<void> _addSection() async {
    final title = await _promptText(
      title: 'Nueva pestaña',
      label: 'Título',
      okLabel: 'Crear',
    );
    if (title == null) return;

    setState(() {
      _sections.add(EditableSection(title: title, bullets: []));
    });
    _emit();
  }

  Future<void> _editSectionTitle(int sectionIndex) async {
    final next = await _promptText(
      title: 'Editar título',
      label: 'Título',
      initialValue: _sections[sectionIndex].title,
    );
    if (next == null) return;

    setState(() {
      _sections[sectionIndex].title = next;
    });
    _emit();
  }

  Future<void> _editBullet(int sectionIndex, int bulletIndex) async {
    final next = await _promptText(
      title: 'Editar viñeta',
      label: 'Texto',
      maxLines: 2,
      initialValue: _sections[sectionIndex].bullets[bulletIndex],
    );
    if (next == null) return;

    setState(() {
      _sections[sectionIndex].bullets[bulletIndex] = next;
    });
    _emit();
  }

  Future<void> _addBullet(int sectionIndex) async {
    final text = await _promptText(
      title: 'Nueva viñeta',
      label: 'Texto',
      maxLines: 2,
      okLabel: 'Agregar',
    );
    if (text == null) return;

    setState(() {
      _sections[sectionIndex].bullets.add(text);
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pestañas y viñetas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: _addSection,
              icon: const Icon(Icons.add),
              label: const Text('Agregar pestaña'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_sections.isEmpty)
          Text(
            'No hay pestañas aún.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          Card(
            elevation: 0,
            child: Column(
              children: [
                for (int i = 0; i < _sections.length; i++)
                  ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _sections[i].title,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Editar título',
                          onPressed: () => _editSectionTitle(i),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonalIcon(
                          onPressed: () => _addBullet(i),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar viñeta'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_sections[i].bullets.isEmpty)
                        Text(
                          'Sin viñetas.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        )
                      else
                        for (int b = 0; b < _sections[i].bullets.length; b++)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Text('•'),
                            title: Text(_sections[i].bullets[b]),
                            trailing: IconButton(
                              tooltip: 'Eliminar viñeta',
                              onPressed: () {
                                setState(() {
                                  _sections[i].bullets.removeAt(b);
                                });
                                _emit();
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                            onTap: () => _editBullet(i, b),
                          ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _sections.removeAt(i);
                              });
                              _emit();
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Eliminar pestaña'),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
