import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/bills/presentation/pages/bills_page.dart';
import 'package:financo/features/budgets/presentation/pages/budgets_page.dart';
import 'package:financo/features/dashboard/presentation/pages/fifty_thirty_twenty_page.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shell tab container for budgeting tools. Hosts three sub-tabs:
///
/// 1. **50/30/20** — the rule overview + history + targets editor.
/// 2. **Contas** — bills inbox (the former top-level Bills nav slot,
///    moved into Planning when Investments took its spot — see
///    [investments.md](../../../../docs/specs/investments.md) §10).
/// 3. **Orçamentos** — per-category monthly caps.
///
/// 50/30/20 sits first because it is the higher-level lens users open
/// the planning shell to consume; bills follow as the most actionable
/// item; per-category budgets are a drill-down from there.
///
/// Lives in the dashboard feature folder because the 50/30/20 detail
/// page already lives there; the other features are consumed as-is.
class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key, this.initialTab = 0});

  /// Index of the tab to open with. Currently set imperatively by the
  /// shell when the user lands on the Planejamento entry. Deep links:
  /// `/fifty-thirty-twenty` → 0, `/bills` → 1, `/budgets` → 2.
  final int initialTab;

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Sized for the FinancoLargeAppBar (72px) + the rounded TabBar pill
  // (44px tab area + 8px outer padding + 8px breathing room). Tuned by
  // eye — bumping this beyond ~136px starts feeling top-heavy.
  static const double _headerHeight = 132;
  static const double _tabPillHeight = 44;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(_headerHeight),
        child: ColoredBox(
          color: colors.background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FinancoLargeAppBar(title: t.nav.planning),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Material(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: _tabPillHeight,
                    child: TabBar(
                      controller: _controller,
                      indicator: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorPadding: const EdgeInsets.all(4),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: colors.onBackground,
                      unselectedLabelColor: colors.onBackgroundLight,
                      labelStyle: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: [
                        Tab(text: t.fiftyThirtyTwenty.subTabFiftyThirtyTwenty),
                        const Tab(child: _BillsTabLabel()),
                        Tab(text: t.fiftyThirtyTwenty.subTabBudgets),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [
          // Sub-pages render in `embedded: true` so they don't draw
          // their own FinancoLargeAppBar — the parent shell already
          // owns the title row above the TabBar.
          FiftyThirtyTwentyPage(embedded: true),
          BillsPage(embedded: true),
          BudgetsPage(embedded: true),
        ],
      ),
    );
  }
}

class _BillsTabLabel extends StatelessWidget {
  const _BillsTabLabel();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final count = context.select<BillsBloc, int>((bloc) {
      final state = bloc.state;
      return state is BillsLoaded ? state.actionablePendingCount : 0;
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(right: count > 0 ? 10 : 0),
              child: Text(
                t.fiftyThirtyTwenty.subTabBills,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count > 0)
              Positioned(
                right: -8,
                top: -9,
                child: _BillsTabCountBadge(
                  count: count,
                  borderColor: colors.surface,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BillsTabCountBadge extends StatelessWidget {
  const _BillsTabCountBadge({
    required this.count,
    required this.borderColor,
  });

  final int count;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      height: 16,
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.appColors.expense,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}
