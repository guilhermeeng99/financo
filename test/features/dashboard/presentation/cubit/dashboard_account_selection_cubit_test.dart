import 'package:financo/features/dashboard/presentation/cubit/dashboard_account_selection_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const userId = 'user-1';
  const otherUserId = 'user-2';
  String storageKey(String id) => 'dashboard.excluded_accounts:$id';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<DashboardAccountSelectionCubit> buildCubit({
    String userIdValue = userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return DashboardAccountSelectionCubit(prefs: prefs, userId: userIdValue);
  }

  group('DashboardAccountSelectionCubit', () {
    test('starts with no exclusions when storage is empty', () async {
      final cubit = await buildCubit();
      expect(cubit.state.excludedIds, isEmpty);
      addTearDown(cubit.close);
    });

    test('rehydrates excluded ids from storage on construction', () async {
      SharedPreferences.setMockInitialValues({
        storageKey(userId): ['acc-1', 'acc-2'],
      });
      final cubit = await buildCubit();
      expect(cubit.state.excludedIds, {'acc-1', 'acc-2'});
      addTearDown(cubit.close);
    });

    test('toggle adds an id when not present and persists', () async {
      final cubit = await buildCubit();
      await cubit.toggle('acc-1');
      expect(cubit.state.excludedIds, {'acc-1'});

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(storageKey(userId)), ['acc-1']);
      addTearDown(cubit.close);
    });

    test('toggle removes an id when already present and persists', () async {
      SharedPreferences.setMockInitialValues({
        storageKey(userId): ['acc-1'],
      });
      final cubit = await buildCubit();
      await cubit.toggle('acc-1');
      expect(cubit.state.excludedIds, isEmpty);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(storageKey(userId)), isEmpty);
      addTearDown(cubit.close);
    });

    test('isIncluded reflects the current set', () async {
      final cubit = await buildCubit();
      expect(cubit.isIncluded('acc-1'), isTrue);
      await cubit.toggle('acc-1');
      expect(cubit.isIncluded('acc-1'), isFalse);
      addTearDown(cubit.close);
    });

    test('storage is scoped per userId', () async {
      SharedPreferences.setMockInitialValues({
        storageKey(userId): ['acc-1'],
        storageKey(otherUserId): ['acc-9'],
      });
      final cubit = await buildCubit();
      final cubitOther = await buildCubit(userIdValue: otherUserId);
      expect(cubit.state.excludedIds, {'acc-1'});
      expect(cubitOther.state.excludedIds, {'acc-9'});
      addTearDown(cubit.close);
      addTearDown(cubitOther.close);
    });
  });
}
