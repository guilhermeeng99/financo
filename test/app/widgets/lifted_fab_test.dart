import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('floatingActionScrollEndPadding', () {
    test('keeps legacy clearance for a single FAB', () {
      expect(
        floatingActionScrollEndPadding(hasStackedActions: false),
        160,
      );
    });

    test('adds enough clearance for stacked FABs', () {
      expect(
        floatingActionScrollEndPadding(hasStackedActions: true),
        232,
      );
    });
  });
}
