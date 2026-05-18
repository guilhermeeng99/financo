import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FiftyThirtyTwentyTargets', () {
    test('classic split is the canonical 50/30/20', () {
      const c = FiftyThirtyTwentyTargets.classic;
      expect(c.needs, 0.5);
      expect(c.wants, 0.3);
      expect(c.savings, 0.2);
      expect(c.isValid, isTrue);
    });

    test('isValid is true when components sum to 1.0', () {
      const target = FiftyThirtyTwentyTargets(
        needs: 0.6,
        wants: 0.2,
        savings: 0.2,
      );
      expect(target.isValid, isTrue);
    });

    test('isValid tolerates floating-point drift up to 0.001', () {
      const target = FiftyThirtyTwentyTargets(
        needs: 0.5,
        wants: 0.3,
        savings: 0.2005, // 0.0005 over
      );
      expect(target.isValid, isTrue);
    });

    test('isValid fails when components do not sum to 1.0', () {
      const target = FiftyThirtyTwentyTargets(
        needs: 0.4,
        wants: 0.4,
        savings: 0.4,
      );
      expect(target.isValid, isFalse);
    });

    test('isValid fails on negative components', () {
      const target = FiftyThirtyTwentyTargets(
        needs: 0.6,
        wants: 0.5,
        savings: -0.1,
      );
      expect(target.isValid, isFalse);
    });

    test('copyWith replaces only the named field', () {
      const base = FiftyThirtyTwentyTargets.classic;
      final next = base.copyWith(needs: 0.6, savings: 0.1);
      expect(next.needs, 0.6);
      expect(next.wants, 0.3);
      expect(next.savings, 0.1);
    });
  });
}
