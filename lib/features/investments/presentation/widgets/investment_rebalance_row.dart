import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InvestmentRebalanceRow extends StatelessWidget {
  const InvestmentRebalanceRow({required this.action, super.key});

  final RebalanceAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isBuy = action.direction == RebalanceDirection.buy;
    final tint = isBuy ? colors.success : colors.warning;
    final icon = isBuy ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown;
    final verb = isBuy
        ? t.investments.rebalanceBuy(
            amount: formatCurrency(action.amount),
            className: action.className,
          )
        : t.investments.rebalanceSell(
            amount: formatCurrency(action.amount),
            className: action.className,
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(icon, size: 12, color: tint),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              verb,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
