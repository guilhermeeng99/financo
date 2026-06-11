part of 'payables_receivables_page.dart';

class _AccountsTotalsCard extends StatelessWidget {
  const _AccountsTotalsCard({
    required this.transactions,
    required this.view,
    required this.selectedAccountIds,
    required this.onAccountToggled,
  });

  final List<TransactionEntity> transactions;
  final PayablesReceivablesView view;
  final Set<String> selectedAccountIds;
  final void Function(String accountId, List<String> availableAccountIds)
  onAccountToggled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accounts = context
        .watch<AccountsCubit>()
        .state
        .accountsOrEmpty
        .where((account) => account.type != AccountType.investment)
        .toList();
    final accountIds = accounts.map((account) => account.id).toList();
    final rows = accounts
        .map(
          (account) => _AccountTotalRowData(
            account: account,
            amount: _sumForAccount(account.id),
            isSelected: _isSelected(account.id),
          ),
        )
        .toList();
    final total = rows
        .where((row) => row.isSelected)
        .fold<double>(0, (sum, row) => sum + row.amount);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.profile.accounts,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _viewTotalLabel(view),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.onBackgroundLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              Text(
                t.general.noResults,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onBackgroundLight,
                ),
              )
            else ...[
              for (final row in rows)
                _AccountTotalRow(
                  row: row,
                  view: view,
                  onTap: () => onAccountToggled(row.account!.id, accountIds),
                ),
              const Divider(height: 20),
              _AccountTotalRow(
                row: _AccountTotalRowData(
                  account: null,
                  amount: total,
                  isSelected: true,
                  fallbackName: t.dashboard.total,
                ),
                view: view,
                isTotal: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _sumForAccount(String accountId) => transactions
      .where((tx) => tx.accountId == accountId)
      .fold<double>(0, (sum, tx) => sum + tx.amount);

  bool _isSelected(String accountId) {
    return selectedAccountIds.isEmpty || selectedAccountIds.contains(accountId);
  }
}

class _AccountTotalRowData {
  const _AccountTotalRowData({
    required this.account,
    required this.amount,
    required this.isSelected,
    this.fallbackName,
  });

  final AccountEntity? account;
  final double amount;
  final bool isSelected;
  final String? fallbackName;

  String get name => account?.name ?? fallbackName ?? '';
}

class _AccountTotalRow extends StatelessWidget {
  const _AccountTotalRow({
    required this.row,
    required this.view,
    this.isTotal = false,
    this.onTap,
  });

  final _AccountTotalRowData row;
  final PayablesReceivablesView view;
  final bool isTotal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = _amountColor(context, view);
    final content = Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 3 : 2),
      child: Row(
        children: [
          if (!isTotal) ...[
            Checkbox(
              value: row.isSelected,
              onChanged: (_) => onTap?.call(),
              activeColor: colors.primary,
              checkColor: Colors.white,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            _BankAvatar(account: row.account),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              row.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: row.isSelected || isTotal
                    ? colors.onBackground
                    : colors.onBackgroundLight,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _signedAmount(row.amount, view),
            style: context.textTheme.bodySmall?.copyWith(
              color: row.isSelected || isTotal
                  ? color
                  : colors.onBackgroundLight.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (isTotal) return content;

    return Material(
      color: row.isSelected
          ? colors.surfaceVariant.withValues(alpha: 0.35)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: content,
      ),
    );
  }
}

class _BankAvatar extends StatelessWidget {
  const _BankAvatar({required this.account});

  final AccountEntity? account;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final account = this.account;
    if (account == null) return const SizedBox.shrink();

    final brand = BankBrand.of(account.bank);
    final background = Color(brand.color);
    final abbreviation = brand.abbreviation.isEmpty
        ? (account.name.isEmpty
              ? '?'
              : account.name.substring(0, 1).toUpperCase())
        : brand.abbreviation;
    return Padding(
      padding: const EdgeInsets.only(right: 1),
      child: Tooltip(
        message: account.bankLabel,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            abbreviation,
            style: context.textTheme.bodySmall?.copyWith(
              color: _readableTextColor(background, colors),
              fontWeight: FontWeight.w700,
              fontSize: abbreviation.length > 2 ? 8 : 9,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

String _viewTotalLabel(PayablesReceivablesView view) => switch (view) {
  PayablesReceivablesView.payables => t.payablesReceivables.typePayable,
  PayablesReceivablesView.receivables => t.payablesReceivables.typeReceivable,
  PayablesReceivablesView.paid => t.payablesReceivables.paidPlural,
  PayablesReceivablesView.received => t.payablesReceivables.receivedPlural,
};

Color _amountColor(BuildContext context, PayablesReceivablesView view) {
  return switch (view) {
    PayablesReceivablesView.payables ||
    PayablesReceivablesView.paid => context.appColors.expense,
    PayablesReceivablesView.receivables ||
    PayablesReceivablesView.received => context.appColors.income,
  };
}

String _signedAmount(double amount, PayablesReceivablesView view) {
  if (amount == 0) return formatCurrency(0);
  final prefix = switch (view) {
    PayablesReceivablesView.payables || PayablesReceivablesView.paid => '-',
    PayablesReceivablesView.receivables ||
    PayablesReceivablesView.received => '+',
  };
  return '$prefix${formatCurrency(amount)}';
}

List<TransactionEntity> _filterByAccounts(
  List<TransactionEntity> transactions,
  Set<String> selectedAccountIds,
) {
  if (selectedAccountIds.isEmpty) return transactions;
  return transactions
      .where(
        (transaction) => selectedAccountIds.contains(transaction.accountId),
      )
      .toList();
}

List<TransactionEntity> _filterByAvailableAccounts(
  List<TransactionEntity> transactions,
  Set<String> availableAccountIds,
) {
  if (availableAccountIds.isEmpty) return transactions;
  return transactions
      .where(
        (transaction) => availableAccountIds.contains(transaction.accountId),
      )
      .toList();
}

Color _readableTextColor(Color background, AppColorsData colors) {
  return background.computeLuminance() > 0.55
      ? colors.background
      : Colors.white;
}
