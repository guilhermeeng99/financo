import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which checking-account IDs the user has hidden from the
/// dashboard's "Total" row. Excluded accounts still render in the list
/// (with their checkbox unticked) — they just don't count toward the
/// running sum.
///
/// State is persisted to SharedPreferences scoped by `userId` so two
/// people on the same device don't bleed selections into each other.
class DashboardAccountSelectionCubit
    extends Cubit<DashboardAccountSelectionState> {
  DashboardAccountSelectionCubit({
    required SharedPreferences prefs,
    required String userId,
  }) : _prefs = prefs,
       _userId = userId,
       super(const DashboardAccountSelectionState(excludedIds: {})) {
    _load();
  }

  final SharedPreferences _prefs;
  final String _userId;

  String get _storageKey => 'dashboard.excluded_accounts:$_userId';

  void _load() {
    final stored = _prefs.getStringList(_storageKey) ?? const <String>[];
    emit(DashboardAccountSelectionState(excludedIds: stored.toSet()));
  }

  /// Flips inclusion for [accountId] and persists.
  Future<void> toggle(String accountId) async {
    final next = {...state.excludedIds};
    if (!next.remove(accountId)) {
      next.add(accountId);
    }
    emit(DashboardAccountSelectionState(excludedIds: next));
    await _prefs.setStringList(_storageKey, next.toList());
  }

  /// Returns true when the account contributes to the dashboard total.
  bool isIncluded(String accountId) =>
      !state.excludedIds.contains(accountId);
}

class DashboardAccountSelectionState extends Equatable {
  const DashboardAccountSelectionState({required this.excludedIds});

  final Set<String> excludedIds;

  @override
  List<Object> get props => [excludedIds];
}
