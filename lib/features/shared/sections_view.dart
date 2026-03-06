import 'package:flutter/material.dart';

class SectionModel {
  SectionModel({required this.title, required this.bullets});

  final String title;
  final List<String> bullets;

  static List<SectionModel> fromDynamic(dynamic raw) {
    if (raw is! List) return const [];

    final sections = <SectionModel>[];
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

      sections.add(SectionModel(title: title.trim(), bullets: bullets));
    }

    return sections;
  }
}

class SectionsView extends StatelessWidget {
  const SectionsView({super.key, required this.sections});

  final List<SectionModel> sections;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;

    return isDesktop
        ? _SectionsTabs(sections: sections)
        : _SectionsAccordion(sections: sections);
  }
}

class _SectionsTabs extends StatelessWidget {
  const _SectionsTabs({required this.sections});

  final List<SectionModel> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: sections.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.8),
              ),
            ),
            child: TabBar(
              isScrollable: true,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              labelColor: theme.colorScheme.onPrimary,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.85,
              ),
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                color: const Color(0xFF1C2833),
                borderRadius: BorderRadius.circular(10),
              ),
              tabs: [
                for (final s in sections)
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(s.title),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: TabBarView(
              children: [
                for (final s in sections)
                  _BulletsList(bullets: s.bullets, scrollable: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionsAccordion extends StatefulWidget {
  const _SectionsAccordion({required this.sections});

  final List<SectionModel> sections;

  @override
  State<_SectionsAccordion> createState() => _SectionsAccordionState();
}

class _SectionsAccordionState extends State<_SectionsAccordion> {
  late final List<bool> _open;

  @override
  void initState() {
    super.initState();
    _open = List<bool>.generate(widget.sections.length, (i) => i == 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionPanelList(
      expandedHeaderPadding: EdgeInsets.zero,
      elevation: 0,
      dividerColor: Colors.transparent,
      expansionCallback: (index, isExpanded) {
        setState(() {
          _open[index] = !isExpanded;
        });
      },
      children: [
        for (int i = 0; i < widget.sections.length; i++)
          ExpansionPanel(
            isExpanded: _open[i],
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.20,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.8),
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 4,
                    ),
                    title: Text(
                      widget.sections[i].title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    trailing: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.8),
                  ),
                ),
                child: _BulletsList(
                  bullets: widget.sections[i].bullets,
                  scrollable: false,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BulletsList extends StatelessWidget {
  const _BulletsList({required this.bullets, required this.scrollable});

  final List<String> bullets;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (bullets.isEmpty) {
      return Text(
        'Sin contenido por ahora.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    final theme = Theme.of(context);

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: !scrollable,
      physics: scrollable
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: bullets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = bullets[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.check_circle,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(b, style: theme.textTheme.bodyLarge)),
          ],
        );
      },
    );
  }
}
