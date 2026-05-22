import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/entities/bill_match_candidate.dart';
import 'package:financo/features/bills/presentation/widgets/bill_status_dot.dart';
import 'package:financo/features/bills/presentation/widgets/bills_type_pills.dart';

/// Pure presentation logic behind the bills list: month scoping, type
/// filtering, settleability, status grouping and match-candidate filtering.
/// Extracted from `bills_page` widgets so the rules (which mirror
/// docs/specs/bills.md) are unit-testable and the widgets only render.

/// First day of the month *after* the current real-calendar month. Bills due
/// strictly before this are settleable; bills at/after it are future. [now]
/// is injectable for tests.
DateTime firstOfNextRealMonth([DateTime? now]) {
  final ref = now ?? DateTime.now();
  return DateTime(ref.year, ref.month + 1);
}

/// Keeps a bill iff its dueDate is in the selected month, or it's a real
/// pending bill due before the selected month (overdue carry-over). Virtuals
/// never carry over — a projected occurrence shown in a later month would just
/// echo the overdue real bill that anchors the same chain.
List<BillEntity> filterBillsForMonth(
  List<BillEntity> all, {
  required int year,
  required int month,
}) {
  final firstOfMonth = DateTime(year, month);
  return all.where((b) {
    final inMonth = b.dueDate.year == year && b.dueDate.month == month;
    final isCarryOver =
        b.isPending && !b.isVirtual && b.dueDate.isBefore(firstOfMonth);
    return inMonth || isCarryOver;
  }).toList();
}

List<BillEntity> filterBillsByType(
  List<BillEntity> all,
  BillsTypeFilter filter,
) {
  return switch (filter) {
    BillsTypeFilter.all => all,
    BillsTypeFilter.payable =>
      all.where((b) => b.type == BillType.payable).toList(),
    BillsTypeFilter.receivable =>
      all.where((b) => b.type == BillType.receivable).toList(),
  };
}

/// A bill is settleable if it's a real (non-virtual) pending bill due in the
/// current real-calendar month or earlier. The navigated month never relaxes
/// this — paying a future bill makes no sense. [now] is injectable for tests.
bool isBillPayable(BillEntity bill, {DateTime? now}) {
  if (bill.isVirtual) return false;
  if (!bill.isPending) return false;
  return bill.dueDate.isBefore(firstOfNextRealMonth(now));
}

/// Mirrors the type filter onto match suggestions and drops candidates whose
/// bill is outside the visible month set.
List<BillMatchCandidate> filterMatchCandidates(
  List<BillMatchCandidate> all,
  BillsTypeFilter filter,
  Set<String> visibleBillIds,
) {
  final byMonth = all
      .where((c) => visibleBillIds.contains(c.bill.id))
      .toList();
  return switch (filter) {
    BillsTypeFilter.all => byMonth,
    BillsTypeFilter.payable =>
      byMonth.where((c) => c.bill.type == BillType.payable).toList(),
    BillsTypeFilter.receivable =>
      byMonth.where((c) => c.bill.type == BillType.receivable).toList(),
  };
}

/// Bills split into the four display sections, with paid sorted most-recently
/// settled first.
class BillGroups {
  const BillGroups({
    required this.overdue,
    required this.today,
    required this.upcoming,
    required this.paid,
  });

  factory BillGroups.fromBills(List<BillEntity> bills) {
    final overdue = <BillEntity>[];
    final today = <BillEntity>[];
    final upcoming = <BillEntity>[];
    final paid = <BillEntity>[];

    for (final b in bills) {
      switch (b.statusKind) {
        case BillStatusKind.overdue:
          overdue.add(b);
        case BillStatusKind.today:
          today.add(b);
        case BillStatusKind.upcoming:
          upcoming.add(b);
        case BillStatusKind.paid:
          paid.add(b);
      }
    }

    paid.sort(
      (a, b) => (b.paidAt ?? b.updatedAt).compareTo(a.paidAt ?? a.updatedAt),
    );

    return BillGroups(
      overdue: overdue,
      today: today,
      upcoming: upcoming,
      paid: paid,
    );
  }

  final List<BillEntity> overdue;
  final List<BillEntity> today;
  final List<BillEntity> upcoming;
  final List<BillEntity> paid;

  bool get isFullyEmpty =>
      overdue.isEmpty && today.isEmpty && upcoming.isEmpty && paid.isEmpty;
}
