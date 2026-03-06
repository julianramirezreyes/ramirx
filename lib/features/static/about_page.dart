import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget sectionTitle(String text) {
      return Text(
        text,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      );
    }

    Widget card({required String title, required String text}) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.35,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.16),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estudio RAMIRX',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ingeniería de software con rigor técnico y soluciones precisas.',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'RAMIRX es un estudio tecnológico enfocado en el diseño y desarrollo de soluciones digitales precisas, escalables y confiables. Creamos software que se adapta a la realidad de cada organización.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _Pill('Precisión'),
                        _Pill('Arquitectura'),
                        _Pill('Escalabilidad'),
                        _Pill('Transparencia'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Qué hacemos'),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, c) {
                      final isWide = c.maxWidth >= 900;
                      final itemWidth = isWide
                          ? (c.maxWidth - 24) / 3
                          : (c.maxWidth >= 520
                                ? (c.maxWidth - 12) / 2
                                : c.maxWidth);
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: card(
                              title: 'Software a la medida',
                              text:
                                  'Sistemas adaptados a procesos reales del negocio: ventas, operaciones, inventario, reportes y automatización.',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: card(
                              title: 'Productos digitales',
                              text:
                                  'Herramientas listas para usar y utilidades enfocadas en productividad, gestión y automatización.',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: card(
                              title: 'Formación técnica',
                              text:
                                  'Capacitaciones aplicadas en desarrollo de software, arquitectura e ingeniería de sistemas.',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  sectionTitle('Misión, visión y valores'),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, c) {
                      final isWide = c.maxWidth >= 900;
                      final itemWidth = isWide
                          ? (c.maxWidth - 12) / 2
                          : c.maxWidth;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: card(
                              title: 'Misión',
                              text:
                                  'Desarrollar soluciones digitales precisas, escalables y confiables para empresas y profesionales.',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: card(
                              title: 'Visión',
                              text:
                                  'Convertirnos en un referente regional en ingeniería de software personalizada para organizaciones que buscan tecnología bien diseñada.',
                            ),
                          ),
                          SizedBox(
                            width: c.maxWidth,
                            child: card(
                              title: 'Valores',
                              text:
                                  'Precisión. Responsabilidad. Transparencia. Innovación. Ética profesional.',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.7)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
