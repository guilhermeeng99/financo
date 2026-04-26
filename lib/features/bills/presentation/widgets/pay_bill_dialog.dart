import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showPayBillDialog({
  required BuildContext context,
  required BillEntity bill,
}) async {
  final accountsState = context.read<AccountsCubit>().state;
  final categoriesState = context.read<CategoriesCubit>().state;

  final accounts = accountsState is AccountsLoaded
      ? accountsState.accounts
            .where((a) => a.type == AccountType.checking)
            .toList()
      : <AccountEntity>[];
  final categories = categoriesState is CategoriesLoaded
      ? categoriesState.categories
            .where((c) => c.type == CategoryType.expense)
            .toList()
      : <CategoryEntity>[];

  if (accounts.isEmpty || categories.isEmpty) {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.bills.payDialogTitle),
        content: Text(
          accounts.isEmpty
              ? t.accounts.empty
              : t.categories.empty,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.general.ok),
          ),
        ],
      ),
    );
    return;
  }

  var accountId = accounts.first.id;
  var categoryId =
      bill.categoryId != null && categories.any((c) => c.id == bill.categoryId)
          ? bill.categoryId!
          : categories.first.id;

  final billsBloc = context.read<BillsBloc>();

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(t.bills.payDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bill.description} — ${formatCurrency(bill.amount)}',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: accountId,
                  decoration: InputDecoration(
                    labelText: t.bills.selectAccount,
                    border: const OutlineInputBorder(),
                  ),
                  items: accounts
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => accountId = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: categoryId,
                  decoration: InputDecoration(
                    labelText: t.bills.selectCategory,
                    border: const OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => categoryId = v);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(t.general.cancel),
              ),
              FilledButton(
                onPressed: () {
                  billsBloc.add(
                    BillPaymentRequested(
                      billId: bill.id,
                      accountId: accountId,
                      categoryId: categoryId,
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: Text(t.bills.markAsPaid),
              ),
            ],
          );
        },
      );
    },
  );
}
