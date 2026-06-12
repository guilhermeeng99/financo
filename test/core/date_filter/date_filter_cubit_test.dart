import 'package:bloc_test/bloc_test.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFilterCubit', () {
    test('initial state is the current month', () {
      final cubit = DateFilterCubit();
      addTearDown(cubit.close);
      final now = DateTime.now();
      expect(cubit.state.year, now.year);
      expect(cubit.state.month, now.month);
    });

    blocTest<DateFilterCubit, DateFilterState>(
      'setMonth jumps straight to the requested period',
      build: DateFilterCubit.new,
      act: (cubit) => cubit.setMonth(2026, 3),
      expect: () => const [DateFilterState(year: 2026, month: 3)],
    );

    blocTest<DateFilterCubit, DateFilterState>(
      'nextMonth advances within the same year',
      build: DateFilterCubit.new,
      seed: () => const DateFilterState(year: 2026, month: 5),
      act: (cubit) => cubit.nextMonth(),
      expect: () => const [DateFilterState(year: 2026, month: 6)],
    );

    blocTest<DateFilterCubit, DateFilterState>(
      'nextMonth wraps December into January of the next year',
      build: DateFilterCubit.new,
      seed: () => const DateFilterState(year: 2026, month: 12),
      act: (cubit) => cubit.nextMonth(),
      expect: () => const [DateFilterState(year: 2027, month: 1)],
    );

    blocTest<DateFilterCubit, DateFilterState>(
      'previousMonth steps back within the same year',
      build: DateFilterCubit.new,
      seed: () => const DateFilterState(year: 2026, month: 5),
      act: (cubit) => cubit.previousMonth(),
      expect: () => const [DateFilterState(year: 2026, month: 4)],
    );

    blocTest<DateFilterCubit, DateFilterState>(
      'previousMonth wraps January into December of the prior year',
      build: DateFilterCubit.new,
      seed: () => const DateFilterState(year: 2026, month: 1),
      act: (cubit) => cubit.previousMonth(),
      expect: () => const [DateFilterState(year: 2025, month: 12)],
    );

    blocTest<DateFilterCubit, DateFilterState>(
      'round trip next + previous returns to the seeded month',
      build: DateFilterCubit.new,
      seed: () => const DateFilterState(year: 2026, month: 12),
      act: (cubit) => cubit
        ..nextMonth()
        ..previousMonth(),
      expect: () => const [
        DateFilterState(year: 2027, month: 1),
        DateFilterState(year: 2026, month: 12),
      ],
    );
  });
}
