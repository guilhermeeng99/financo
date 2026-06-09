import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/budgets/presentation/pages/budgets_page.dart';
import 'package:financo/features/dashboard/presentation/pages/fifty_thirty_twenty_page.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// Shell tab container for planning tools.
///
/// Payables and receivables are now top-level sidebar entries backed by
/// scheduled transactions, so Planning only hosts strategic planning views.
class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key, this.initialTab = 0});

  /// Deep links: `/fifty-thirty-twenty` -> 0, `/budgets` -> 1.
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
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          FiftyThirtyTwentyPage(embedded: true),
          BudgetsPage(embedded: true),
        ],
      ),
    );
  }
}
