import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _openExternal(BuildContext context, Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace')));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width < 900;
    final primary = Theme.of(context).colorScheme.primary;
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primary.withValues(alpha: 0.08), Colors.transparent],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 28 + topInset, 20, 28),
                  child: isSmall ? _HeroStacked() : const _HeroWide(),
                ),
              ),
            ),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title:
                          'Muchos negocios trabajan con herramientas que no fueron diseñadas para ellos.',
                      body:
                          'Es común encontrar empresas que gestionan sus operaciones mediante hojas de cálculo improvisadas o sistemas genéricos que no se adaptan a sus procesos reales. Esto genera errores, retrabajo, pérdida de información y dependencia constante de soluciones externas que no responden a las necesidades del negocio.',
                      child: const _CardGrid(
                        children: [
                          _InfoCard(
                            title: 'Procesos gestionados en Excel',
                            text:
                                'Operación frágil, propensa a errores y difícil de auditar.',
                          ),
                          _InfoCard(
                            title: 'Sistemas genéricos con limitaciones',
                            text:
                                'La herramienta manda, el negocio se adapta y pierde eficiencia.',
                          ),
                          _InfoCard(
                            title: 'Falta de soporte técnico real',
                            text:
                                'Cambios lentos, dependencia de terceros y decisiones a ciegas.',
                          ),
                          _InfoCard(
                            title: 'Procesos manuales repetitivos',
                            text:
                                'Retrabajo constante y costos ocultos por tiempo operativo.',
                          ),
                          _InfoCard(
                            title: 'Información dispersa',
                            text:
                                'Datos fragmentados que impiden reportes confiables y oportunos.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title:
                          'Diseñamos sistemas que se adaptan a su negocio, no al revés.',
                      body:
                          'En RAMIRX desarrollamos soluciones tecnológicas precisas que se ajustan a la forma en que opera cada organización. Nuestro enfoque combina ingeniería de software, infraestructura tecnológica y soporte continuo para ofrecer sistemas confiables y escalables.',
                      child: const _CardGrid(
                        children: [
                          _InfoCard(
                            title: 'Desarrollo personalizado',
                            text:
                                'Cada sistema se diseña según los procesos específicos del cliente.',
                          ),
                          _InfoCard(
                            title: 'Arquitectura técnica sólida',
                            text:
                                'Software estable, mantenible y escalable para operar sin fricción.',
                          ),
                          _InfoCard(
                            title: 'Infraestructura incluida',
                            text:
                                'Sin preocuparse por servidores, bases de datos o mantenimiento técnico.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Tres formas de trabajar con RAMIRX',
                      child: _CardGrid(
                        children: [
                          _LineCard(
                            title: 'Servicios',
                            text:
                                'Desarrollo de software personalizado para empresas y negocios que necesitan soluciones digitales adaptadas a sus procesos.',
                            bullets: const [
                              'Sistemas empresariales',
                              'Automatización de procesos',
                              'Aplicaciones web',
                              'Infraestructura incluida',
                            ],
                            ctaLabel: 'Explorar servicios',
                            onPressed: () => context.go('/servicios'),
                          ),
                          _LineCard(
                            title: 'Productos',
                            text:
                                'Software y herramientas digitales diseñadas para resolver necesidades específicas de gestión, productividad o automatización.',
                            bullets: const [
                              'Aplicaciones listas para usar',
                              'Herramientas especializadas',
                              'Utilidades empresariales',
                            ],
                            ctaLabel: 'Ver productos',
                            onPressed: () => context.go('/productos'),
                          ),
                          _LineCard(
                            title: 'Capacitaciones',
                            text:
                                'Formación técnica enfocada en desarrollo de software, arquitectura de sistemas y habilidades tecnológicas aplicadas.',
                            bullets: const [
                              'Cursos técnicos',
                              'Formación en programación',
                              'Ingeniería de software',
                            ],
                            ctaLabel: 'Ver capacitaciones',
                            onPressed: () => context.go('/capacitaciones'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Cómo trabajamos',
                      child: _CardGrid(
                        children: const [
                          _StepCard(
                            n: 1,
                            title: 'Diagnóstico',
                            text:
                                'Analizamos el funcionamiento del negocio y los procesos a mejorar.',
                          ),
                          _StepCard(
                            n: 2,
                            title: 'Diseño de solución',
                            text:
                                'Se define una arquitectura técnica adecuada para el problema.',
                          ),
                          _StepCard(
                            n: 3,
                            title: 'Desarrollo',
                            text:
                                'Construcción del sistema mediante módulos iterativos.',
                          ),
                          _StepCard(
                            n: 4,
                            title: 'Implementación',
                            text:
                                'Despliegue del sistema y capacitación del cliente.',
                          ),
                          _StepCard(
                            n: 5,
                            title: 'Soporte',
                            text:
                                'Mantenimiento técnico y evolución del sistema.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Precisión en cada sistema',
                      body:
                          'El software que gestiona un negocio no debe ser improvisado. En RAMIRX creemos que las soluciones tecnológicas deben diseñarse con rigor técnico, claridad arquitectónica y un profundo entendimiento del problema que buscan resolver.',
                      child: const Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _Pill('Precisión'),
                          _Pill('Responsabilidad'),
                          _Pill('Transparencia'),
                          _Pill('Innovación'),
                          _Pill('Ética profesional'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Banner(
                      title:
                          'Si su negocio necesita un sistema diseñado para su realidad, podemos construirlo.',
                      text:
                          'Contáctenos para analizar su caso y evaluar la mejor solución tecnológica para su organización.',
                      primaryLabel: 'Contactar por WhatsApp',
                      secondaryLabel: 'Enviar correo',
                      onPrimary: () => _openExternal(
                        context,
                        Uri.parse(AppConfig.whatsappUrl),
                      ),
                      onSecondary: () => _openExternal(
                        context,
                        Uri.parse('mailto:ramirexdev@gmail.com'),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 22,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RAMIRX',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Precisión en cada sistema.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 10,
                        children: [
                          TextButton(
                            onPressed: () => context.go('/productos'),
                            child: const Text('Productos'),
                          ),
                          TextButton(
                            onPressed: () => context.go('/capacitaciones'),
                            child: const Text('Capacitaciones'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.body, this.child});

  final String title;
  final String? body;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        if ((body ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            body!,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (child != null) ...[const SizedBox(height: 14), child!],
      ],
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.title,
    required this.text,
    required this.bullets,
    required this.ctaLabel,
    required this.onPressed,
  });

  final String title;
  final String text;
  final List<String> bullets;
  final String ctaLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = theme.colorScheme.outlineVariant;
    final surface = theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.35,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          for (final b in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(
                    child: Text(
                      b,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.3,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onPressed,
              child: Text(ctaLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.n, required this.title, required this.text});

  final int n;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = theme.colorScheme.outlineVariant;
    final surface = theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Paso $n',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.35,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroWide extends StatelessWidget {
  const _HeroWide();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: _HeroText()),
        const SizedBox(width: 18),
        const Expanded(flex: 5, child: _MetricCard()),
      ],
    );
  }
}

class _HeroStacked extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_HeroText(), SizedBox(height: 16), _MetricCard()],
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Software diseñado exactamente para la forma en que funciona su negocio.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'RAMIRX es un estudio de ingeniería de software que desarrolla soluciones digitales personalizadas, productos tecnológicos y formación técnica para empresas y profesionales que necesitan herramientas realmente adaptadas a sus procesos.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => context.go('/servicios'),
              child: const Text('Explorar servicios'),
            ),
            OutlinedButton(
              onPressed: () => launchUrl(
                Uri.parse(AppConfig.whatsappUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Contactar'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: const [
            _Pill('Preciso'),
            _Pill('Escalable'),
            _Pill('Mantenible'),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard();

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final border = Theme.of(context).colorScheme.outlineVariant;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'RAMIRX',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _Metric(
            label: 'Modelo',
            value: 'Acompañamiento anual (infraestructura + soporte)',
          ),
          const SizedBox(height: 10),
          const _Metric(
            label: 'Enfoque',
            value: 'Comercios locales (Itagüí y área metropolitana)',
          ),
          const SizedBox(height: 10),
          const _Metric(
            label: 'Diferenciador',
            value: 'Personalización + infraestructura incluida',
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final columns = w >= 1000 ? 3 : (w >= 640 ? 2 : 1);
        final itemWidth = (w - (12 * (columns - 1))) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final c in children) SizedBox(width: itemWidth, child: c),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final border = Theme.of(context).colorScheme.outlineVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.title,
    required this.text,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String title;
  final String text;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final border = Theme.of(context).colorScheme.outlineVariant;
    final surface = Theme.of(context).colorScheme.surface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;

        final textColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );

        final actions = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(backgroundColor: primary),
              child: Text(primaryLabel),
            ),
            OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel)),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [textColumn, const SizedBox(height: 12), actions],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: textColumn),
                    const SizedBox(width: 12),
                    actions,
                  ],
                ),
        );
      },
    );
  }
}
