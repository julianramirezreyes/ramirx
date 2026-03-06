import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.placeholderIcon,
    this.badge,
    this.priceLabel,
    this.compareAtPriceLabel,
    this.onTap,
    this.primaryAction,
    this.primaryActionLabel,
  });

  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData? placeholderIcon;
  final Widget? badge;
  final String? priceLabel;
  final String? compareAtPriceLabel;
  final VoidCallback? onTap;
  final VoidCallback? primaryAction;
  final String? primaryActionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if ((imageUrl ?? '').trim().isNotEmpty)
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _Placeholder(icon: placeholderIcon),
                  )
                else
                  _Placeholder(icon: placeholderIcon),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badge != null) badge!,
                      if (badge != null && (priceLabel ?? '').trim().isNotEmpty)
                        const SizedBox(width: 8),
                      if ((priceLabel ?? '').trim().isNotEmpty)
                        _PricePill(
                          priceLabel: priceLabel!,
                          compareAtPriceLabel: compareAtPriceLabel,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if ((subtitle ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (primaryAction != null &&
                    (primaryActionLabel ?? '').trim().isNotEmpty)
                  const SizedBox(height: 10),
                if (primaryAction != null &&
                    (primaryActionLabel ?? '').trim().isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: primaryAction,
                      child: Text(primaryActionLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: card,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(icon ?? Icons.image_outlined, size: 44),
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({
    required this.priceLabel,
    required this.compareAtPriceLabel,
  });

  final String priceLabel;
  final String? compareAtPriceLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF1C2833),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((compareAtPriceLabel ?? '').trim().isNotEmpty) ...[
            Text(
              compareAtPriceLabel!,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.75),
                decoration: TextDecoration.lineThrough,
                decorationColor: theme.colorScheme.onPrimary.withValues(
                  alpha: 0.75,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            priceLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
