String formatCopFromCents(int cents, {bool withSymbol = true}) {
  final pesos = (cents / 100).round();
  final abs = pesos.abs();
  final raw = abs.toString();
  final sb = StringBuffer();

  for (int i = 0; i < raw.length; i++) {
    final idxFromEnd = raw.length - i;
    sb.write(raw[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
      sb.write('.');
    }
  }

  final formatted = sb.toString();
  final sign = pesos < 0 ? '-' : '';
  final prefix = withSymbol ? r'$' : '';
  return '$sign$prefix$formatted';
}
