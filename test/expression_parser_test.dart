import 'package:flutter_test/flutter_test.dart';
import 'package:koshyk_app/core/utils/expression_parser.dart';

void main() {
  group('parseAmount', () {
    group('valid inputs — return non-null positive double', () {
      test('"300" → 300.0', () {
        final result = parseAmount('300');
        expect(result, isNotNull);
        expect(result!, closeTo(300.0, 0.001));
      });

      test('"300+450" → 750.0', () {
        final result = parseAmount('300+450');
        expect(result, isNotNull);
        expect(result!, closeTo(750.0, 0.001));
      });

      test('"=761-135" → 626.0 (leading equals sign stripped)', () {
        final result = parseAmount('=761-135');
        expect(result, isNotNull);
        expect(result!, closeTo(626.0, 0.001));
      });

      test('"135/3+100" → 145.0', () {
        final result = parseAmount('135/3+100');
        expect(result, isNotNull);
        expect(result!, closeTo(145.0, 0.001));
      });

      test('"  100  " (surrounding whitespace) → 100.0', () {
        final result = parseAmount('  100  ');
        expect(result, isNotNull);
        expect(result!, closeTo(100.0, 0.001));
      });

      test('"=100" → 100.0 (equals-only prefix)', () {
        final result = parseAmount('=100');
        expect(result, isNotNull);
        expect(result!, closeTo(100.0, 0.001));
      });

      test('"100*3" → 300.0', () {
        final result = parseAmount('100*3');
        expect(result, isNotNull);
        expect(result!, closeTo(300.0, 0.001));
      });

      test('"50*2+10" → 110.0', () {
        final result = parseAmount('50*2+10');
        expect(result, isNotNull);
        expect(result!, closeTo(110.0, 0.001));
      });

      test('"1000-500" → 500.0', () {
        final result = parseAmount('1000-500');
        expect(result, isNotNull);
        expect(result!, closeTo(500.0, 0.001));
      });

      test('"0.5" → 0.5 (decimal fraction)', () {
        final result = parseAmount('0.5');
        expect(result, isNotNull);
        expect(result!, closeTo(0.5, 0.001));
      });

      test('"100.50" → 100.5 (decimal amount)', () {
        final result = parseAmount('100.50');
        expect(result, isNotNull);
        expect(result!, closeTo(100.5, 0.001));
      });

      test('"=(100+200)/3" → 100.0 (parenthesised expression)', () {
        final result = parseAmount('=(100+200)/3');
        expect(result, isNotNull);
        expect(result!, closeTo(100.0, 0.001));
      });
    });

    group('invalid inputs — return null', () {
      test('empty string "" → null', () {
        expect(parseAmount(''), isNull);
      });

      test('whitespace-only "  " → null', () {
        expect(parseAmount('  '), isNull);
      });

      test('"-100" → null (result is negative, ≤ 0)', () {
        expect(parseAmount('-100'), isNull);
      });

      test('"0" → null (result equals 0, which is ≤ 0)', () {
        expect(parseAmount('0'), isNull);
      });

      test('"-50+30" → null (result is -20, ≤ 0)', () {
        expect(parseAmount('-50+30'), isNull);
      });

      test('"abc" → null (non-numeric string)', () {
        expect(parseAmount('abc'), isNull);
      });

      test('"hello world" → null (plain text)', () {
        expect(parseAmount('hello world'), isNull);
      });

      test('"1/0" → null (division by zero yields infinity)', () {
        expect(parseAmount('1/0'), isNull);
      });
    });
  });

  // REMARKS #143 — operator precedence and typographic/locale input.
  group('parseAmount — precedence and normalization (#143)', () {
    final cases = <String, double>{
      '100+50*2': 200,
      '100-60/3': 80,
      '10+20/4*2': 20,
      '(100+50)*2': 300,
      '100×2': 200,
      '100÷4': 25,
      '100−50': 50,
      '100+50×2': 200,
      '12,5+1': 13.5,
      ' 300 + 450 ': 750,
    };
    cases.forEach((input, expected) {
      test('"$input" → $expected', () {
        final result = parseAmount(input);
        expect(result, isNotNull);
        expect(result!, closeTo(expected, 0.001));
      });
    });

    test('normalizeExpression maps × ÷ − and comma to ASCII', () {
      expect(normalizeExpression('1×2÷3−4,5'), '1*2/3-4.5');
    });
  });
}
