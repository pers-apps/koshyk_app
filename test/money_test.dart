import 'package:flutter_test/flutter_test.dart';
import 'package:koshyk_app/core/utils/money.dart';

void main() {
  group('formatMoney', () {
    group('standard UAH symbol', () {
      test('0 kopiykas formats as "0.00 ₴"', () {
        expect(formatMoney(0), equals('0.00 ₴'));
      });

      test('100 kopiykas formats as "1.00 ₴"', () {
        expect(formatMoney(100), equals('1.00 ₴'));
      });

      test('999 kopiykas formats as "9.99 ₴"', () {
        expect(formatMoney(999), equals('9.99 ₴'));
      });

      test('10000 kopiykas formats as "100.00 ₴"', () {
        expect(formatMoney(10000), equals('100.00 ₴'));
      });

      test('1 kopiykas formats as "0.01 ₴"', () {
        expect(formatMoney(1), equals('0.01 ₴'));
      });

      test('100000 kopiykas formats as "1000.00 ₴"', () {
        expect(formatMoney(100000), equals('1000.00 ₴'));
      });
    });

    group('custom symbol', () {
      test('500 kopiykas with dollar symbol formats as "5.00 \$"', () {
        expect(formatMoney(500, symbol: '\$'), equals('5.00 \$'));
      });
    });

    group('negative values', () {
      test('-100 kopiykas formats as "-1.00 ₴"', () {
        expect(formatMoney(-100), equals('-1.00 ₴'));
      });
    });
  });

  group('toKopiykas', () {
    test('1.0 UAH → 100 kopiykas', () {
      expect(toKopiykas(1.0), equals(100));
    });

    test('9.99 UAH → 999 kopiykas', () {
      expect(toKopiykas(9.99), equals(999));
    });

    test('100.0 UAH → 10000 kopiykas', () {
      expect(toKopiykas(100.0), equals(10000));
    });

    test('0.01 UAH → 1 kopiykas', () {
      expect(toKopiykas(0.01), equals(1));
    });

    test('0.005 UAH → 1 kopiykas (rounds half-up)', () {
      expect(toKopiykas(0.005), equals(1));
    });

    test('0.004 UAH → 0 kopiykas (rounds down)', () {
      expect(toKopiykas(0.004), equals(0));
    });

    test('0.0 UAH → 0 kopiykas', () {
      expect(toKopiykas(0.0), equals(0));
    });
  });

  group('fromKopiykas', () {
    test('100 kopiykas → 1.0 UAH', () {
      expect(fromKopiykas(100), closeTo(1.0, 0.001));
    });

    test('999 kopiykas → 9.99 UAH', () {
      expect(fromKopiykas(999), closeTo(9.99, 0.001));
    });

    test('1 kopiykas → 0.01 UAH', () {
      expect(fromKopiykas(1), closeTo(0.01, 0.001));
    });

    test('10000 kopiykas → 100.0 UAH', () {
      expect(fromKopiykas(10000), closeTo(100.0, 0.001));
    });

    test('0 kopiykas → 0.0 UAH', () {
      expect(fromKopiykas(0), closeTo(0.0, 0.001));
    });
  });
}
