import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    required this.account,
    this.onTap,
    super.key,
  });

  final AccountEntity account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typeLabel = account.type == AccountType.creditCard
        ? t.accounts.creditCard
        : t.accounts.checking;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              BankAvatar(bank: account.bank),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: context.textTheme.titleSmall,
                    ),
                    Text(
                      '${account.bankLabel} · $typeLabel',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                  ],
                ),
              ),
              AmountText(
                amount: account.initialBalance,
                fontSize: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
