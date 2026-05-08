/// Converts kopiykas (integer minor units) to UAH display string.
/// If [round] is true, shows no decimal places with space thousands separator.
/// e.g. round=true: "1 200 ₴"; round=false: "1 200.50 ₴"
String formatMoney(int kopiykas, {String symbol = '₴', bool round = false}) {
  final hryvnias = kopiykas / 100.0;
  if (round) {
    return '${_formatInt(hryvnias.round())} $symbol';
  } else {
    final intPart = hryvnias.truncate();
    final dec = ((hryvnias - intPart).abs() * 100).round();
    return '${_formatInt(intPart)}.${dec.toString().padLeft(2, '0')} $symbol';
  }
}

String _formatInt(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('\u202f'); // narrow no-break space
    buf.write(s[i]);
  }
  return n < 0 ? '-${buf.toString()}' : buf.toString();
}

/// Converts a double (UAH) to kopiykas INTEGER, rounding half-up.
int toKopiykas(double uah) => (uah * 100).round();

/// Converts kopiykas to double UAH.
double fromKopiykas(int kop) => kop / 100.0;
