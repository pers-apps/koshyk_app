import 'package:math_expressions/math_expressions.dart';

/// Evaluates simple arithmetic expressions like "300+450", "=761-135", "135/3+100".
/// Standard operator precedence applies: × and ÷ before + and −, left to right;
/// parentheses first. Returns null if the expression is invalid or evaluates to <= 0.
///
/// Accepts typographic operators inserted by `AmountOperatorBar` (× ÷ −) and a
/// comma as decimal separator (Samsung Keyboard with Ukrainian locale) — see
/// REMARKS #143.
double? parseAmount(String input) {
  String expr = normalizeExpression(input);
  if (expr.startsWith('=')) expr = expr.substring(1);
  if (expr.isEmpty) return null;
  try {
    final parser = GrammarParser();
    final exp = parser.parse(expr);
    final result = exp.evaluate(EvaluationType.REAL, ContextModel());
    final value = (result as num).toDouble();
    if (value <= 0 || value.isNaN || value.isInfinite) return null;
    return value;
  } catch (_) {
    return null;
  }
}

/// Converts user-facing input into the ASCII syntax `math_expressions` parses:
/// × → *, ÷ → /, − (U+2212) and – (en dash) → -, decimal comma → point,
/// whitespace removed.
String normalizeExpression(String input) {
  return input
      .replaceAll(RegExp(r'\s'), '')
      .replaceAll('×', '*')
      .replaceAll('÷', '/')
      .replaceAll('−', '-')
      .replaceAll('–', '-')
      .replaceAll(',', '.');
}
