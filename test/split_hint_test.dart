import 'package:flutter_test/flutter_test.dart';
import 'package:koshyk_app/core/db/database.dart';
import 'package:koshyk_app/features/expenses/domain/split_hint.dart';

Participant p(int id, {bool active = true}) =>
    Participant(id: id, groupId: 1, name: 'P$id', isActive: active);

void main() {
  final members = [p(1), p(2), p(3), p(4), p(5), p(6)];

  group('splitHintFor (REMARKS #149)', () {
    test('no explicit rows = everyone → no hint', () {
      expect(splitHintFor(null, members), isNull);
      expect(splitHintFor(const [], members), isNull);
    });

    test('explicit set covering every active participant → no hint', () {
      expect(splitHintFor([6, 5, 4, 3, 2, 1], members), isNull);
    });

    test('inactive participant missing from the set still counts as everyone',
        () {
      final g = [p(1), p(2), p(3, active: false)];
      expect(splitHintFor([1, 2], g), isNull);
    });

    test('partial split lists receivers in participant order', () {
      final hint = splitHintFor([5, 2], members)!;
      expect(hint.receiverIds, [2, 5]);
      expect(hint.groupSize, 6);
      expect(hint.showNames, isTrue);
    });

    test('names up to 3, count from 4', () {
      expect(splitHintFor([1, 2, 3], members)!.showNames, isTrue);
      final four = splitHintFor([1, 2, 3, 4], members)!;
      expect(four.showNames, isFalse);
      expect(four.receiverIds.length, 4);
      expect(four.groupSize, 6);
    });

    test('participant added after the expense makes it partial', () {
      // Saved as "everyone" when the group had 1..3, then 4 joined.
      final hint = splitHintFor([1, 2, 3], [p(1), p(2), p(3), p(4)])!;
      expect(hint.receiverIds, [1, 2, 3]);
      expect(hint.groupSize, 4);
    });

    test('deactivated receiver is counted in group size', () {
      final g = [p(1), p(2), p(3), p(4, active: false)];
      final hint = splitHintFor([1, 4], g)!;
      expect(hint.receiverIds, [1, 4]);
      expect(hint.groupSize, 4);
    });
  });

  test('splitHintsFor keeps only partial splits', () {
    final hints = splitHintsFor({
      10: [1, 2, 3, 4, 5, 6],
      11: [1, 2],
    }, members);
    expect(hints.keys, [11]);
  });
}

