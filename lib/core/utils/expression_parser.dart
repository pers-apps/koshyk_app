import 'package:math_expressions/math_expressions.dart';

/// Evaluates simple arithmetic expressions like "300+450", "=761-135", "135/3+100".
/// Returns null if the expression is invalid or evaluates to <= 0.
double? parseAmount(String input) {
  String expr = input.trim();
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
