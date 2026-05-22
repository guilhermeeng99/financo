import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/utils/monthly_due_date.dart';

/// Pure (no IO) use case: from the set of real bills already loaded,
/// projects virtual previews of monthly recurrent bills forward up to
/// the navigated month.
///
/// A "monthly chain" is a series of `BillEntity` linked via
/// `parentBillId`, all with `recurrence == monthly`. We start from the
/// most recent real bill in each chain ("anchor") and emit virtual
/// occurrences (with `id = ''`) until the target month is covered, with
/// a hard cap (`maxAheadMonths`) to keep the projection bounded if the
/// user jumps far into the future.
///
/// Anchors are chains' tails: a real monthly bill that has no real
/// child anywhere in the loaded list. If a chain ends because the most
/// recent bill is already in (or past) the target month, no virtuals
/// are needed.
///
/// See `docs/specs/bills.md` → "Future Occurrence Preview".
class ProjectVirtualMonthlyBillsUseCase {
  const ProjectVirtualMonthlyBillsUseCase();

  /// Hard cap on how many months ahead of an anchor we project. 24 is
  /// enough to reach two years out — the user can always navigate back
  /// to settle the anchor and unlock further projection.
  static const int _maxAheadMonths = 24;

  List<BillEntity> call({
    required List<BillEntity> bills,
    required int targetYear,
    required int targetMonth,
  }) {
    final anchors = _findChainAnchors(bills);
    final out = <BillEntity>[];
    final targetCutoff = DateTime(targetYear, targetMonth);

    for (final anchor in anchors) {
      var prev = anchor;
      for (var i = 0; i < _maxAheadMonths; i++) {
        final nextDue = nextMonthlyDueDate(prev.dueDate);
        // Stop projecting once we've gone past the target month — we
        // only need previews up to what the user is currently looking at.
        if (nextDue.isAfter(_endOfMonth(targetCutoff))) break;
        final virtual = _virtualFrom(anchor: anchor, dueDate: nextDue);
        out.add(virtual);
        prev = virtual;
      }
    }

    out.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return out;
  }

  /// Returns the tail of every monthly chain — i.e. real monthly bills
  /// that are not the parent of any other real bill in the list.
  List<BillEntity> _findChainAnchors(List<BillEntity> bills) {
    final monthly = bills
        .where((b) => b.recurrence == BillRecurrence.monthly)
        .toList();
    final hasChild = <String>{
      for (final b in monthly)
        if (b.parentBillId != null) b.parentBillId!,
    };
    return monthly.where((b) => !hasChild.contains(b.id)).toList();
  }

  BillEntity _virtualFrom({
    required BillEntity anchor,
    required DateTime dueDate,
  }) {
    return BillEntity(
      id: '',
      userId: anchor.userId,
      type: anchor.type,
      description: anchor.description,
      amount: anchor.amount,
      dueDate: dueDate,
      status: BillStatus.pending,
      recurrence: BillRecurrence.monthly,
      categoryId: anchor.categoryId,
      notes: anchor.notes,
      // The remaining fields stay at their defaults — virtuals carry no
      // payment metadata and never inherit a rejection list.
      createdAt: anchor.updatedAt,
      updatedAt: anchor.updatedAt,
    );
  }

  /// Inclusive end of the target month (so "in target month" comparisons
  /// pass for any day of that month).
  DateTime _endOfMonth(DateTime monthStart) =>
      DateTime(monthStart.year, monthStart.month + 1, 0, 23, 59, 59);
}
