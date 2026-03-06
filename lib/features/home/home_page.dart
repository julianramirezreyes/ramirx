import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width < 900;
    final primary = Theme.of(context).colorScheme.primary;

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
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
                    Text(
                      'Si su negocio depende de Excel o de un sistema que no se adapta, está perdiendo control.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Muchos comercios operan con Excel saturado, procesos manuales y sistemas genéricos que no reflejan su operación real. Su negocio es único. Su sistema también debería serlo.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),

                    _CardGrid(
                      children: const [
                        _InfoCard(
                          title: 'Problemas típicos',
                          text:
                              'Excel propenso a errores, procesos manuales y dependencia de terceros para cualquier cambio.',
                        ),
                        _InfoCard(
                          title: 'La propuesta RAMIRX',
                          text:
                              'Desarrollo a la medida + infraestructura cloud gestionada + soporte correctivo/evolutivo.',
                        ),
                        _InfoCard(
                          title: 'Sin costos ocultos',
                          text:
                              'Modelo anual. Sin licencias genéricas. Sin servidores que administrar. Sin sorpresas técnicas.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),
                    Text(
                      'Desarrollamos infraestructura digital personalizada para su negocio.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No vendemos licencias mensuales genéricas. Diseñamos su sistema y lo operamos por usted.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _CardGrid(
                      children: const [
                        _InfoCard(
                          title: 'Incluye',
                          text:
                              'Desarrollo a la medida, infraestructura cloud gestionada (BD + backups), soporte correctivo y evolutivo.',
                        ),
                        _InfoCard(
                          title: 'Integraciones',
                          text:
                              'Integración con facturación electrónica DIAN y automatizaciones.',
                        ),
                        _InfoCard(
                          title: 'Capacitación',
                          text:
                              'Capacitación incluida para que su equipo opere sin fricción.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _Banner(
                      title: '¿Cómo funciona?',
                      text:
                          '1) Diagnóstico estratégico. 2) Propuesta técnica. 3) Desarrollo por módulos. 4) Operación y soporte.',
                      primaryLabel: 'Agendar ahora',
                      secondaryLabel: 'WhatsApp',
                      onPrimary: () => _openExternal(
                        context,
                        Uri.parse(AppConfig.bookingUrl),
                      ),
                      onSecondary: () => _openExternal(
                        context,
                        Uri.parse(AppConfig.whatsappUrl),
                      ),
                    ),

                    const SizedBox(height: 18),
                    Text(
                      'Casos de aplicación',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 14),
                    _CardGrid(
                      children: const [
                        _InfoCard(
                          title: 'Comercio minorista',
                          text:
                              'Inventario en tiempo real, control de ventas, reportes automáticos.',
                        ),
                        _InfoCard(
                          title: 'Empresa de servicios',
                          text:
                              'Gestión de clientes, contratos, facturación automática e indicadores.',
                        ),
                        _InfoCard(
                          title: 'Negocio en crecimiento',
                          text:
                              'Multiusuario, acceso remoto y escalabilidad preparada.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    Text(
                      '¿Por qué RAMIRX?',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No somos software genérico. No somos un freelance que desaparece. No somos una licencia sin soporte. Somos un estudio especializado en ingeniería de software: precisión técnica, arquitectura escalable, transparencia contractual y relación a largo plazo.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 18),
                    Text(
                      'Modelo de inversión',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Planes anuales desde \$1.800.000 COP – \$2.400.000 COP. Incluye desarrollo inicial, infraestructura, soporte, mantenimiento y actualizaciones. Sin pagos mensuales variables.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 18),
                    _Banner(
                      title:
                          'Agende una evaluación gratuita y reciba un diagnóstico técnico sin compromiso.',
                      text:
                          'Si su software actual le genera más problemas que soluciones, es momento de cambiar.',
                      primaryLabel: 'Agendar ahora',
                      secondaryLabel: 'Contactar por WhatsApp',
                      onPrimary: () => _openExternal(
                        context,
                        Uri.parse(AppConfig.bookingUrl),
                      ),
                      onSecondary: () => _openExternal(
                        context,
                        Uri.parse(AppConfig.whatsappUrl),
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
                            onPressed: () => context.go('/products'),
                            child: const Text('Productos'),
                          ),
                          TextButton(
                            onPressed: () => context.go('/courses'),
                            child: const Text('Capacitaciones'),
                          ),
                          TextButton(
                            onPressed: () => context.go('/cart'),
                            child: const Text('Carrito'),
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

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
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
          'Software a la medida para comercios que quieren crecer sin depender de sistemas genéricos.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Diseñamos e implementamos soluciones digitales personalizadas con infraestructura incluida, soporte continuo e integración con facturación electrónica. Usted se enfoca en vender. Nosotros nos encargamos del sistema.',
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
              onPressed: () => launchUrl(
                Uri.parse(AppConfig.bookingUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Agendar diagnóstico gratuito'),
            ),
            OutlinedButton(
              onPressed: () => launchUrl(
                Uri.parse(AppConfig.whatsappUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Hablar por WhatsApp'),
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
