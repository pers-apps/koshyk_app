/// Converts kopiykas (integer minor units) to UAH display string.
String formatMoney(int kopiykas, {String symbol = '₴'}) {
  final hryvnias = kopiykas / 100.0;
  return '${hryvnias.toStringAsFixed(2)} $symbol';
}

/// Converts a double (UAH) to kopiykas INTEGER, rounding half-up.
int toKopiykas(double uah) => (uah * 100).round();

/// Converts kopiykas to double UAH.
double fromKopiykas(int kop) => kop / 100.0;
