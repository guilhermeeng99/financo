import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Overlays a red count badge on top of a nav icon when the user has
/// pending bills that need action now (overdue or due today). Hides
/// itself when the count is zero or while bills haven't loaded yet —
/// the badge is purely informative, not a loading affordance.
///
/// The count source is `BillsLoaded.actionablePendingCount`, kept in
/// sync with the Cloud Function `notifyBillsDue` query.
class NavBillsBadge extends StatelessWidget {
  const NavBillsBadge({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final count = context.select<BillsBloc, int>((bloc) {
      final state = bloc.state;
      return state is BillsLoaded ? state.actionablePendingCount : 0;
    });

    if (count <= 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -8,
          top: -6,
          child: _CountPill(count: count),
        ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: colors.expense,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.surface, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
