import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/gen/assets.gen.dart';
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

  String get _bankIconPath {
    if (account.bank.toLowerCase() == 'nubank') {
      return Assets.lib.app.assets.images.banks.nubank.path;
    }
    return Assets.lib.app.assets.images.banks.bank.path;
  }

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
              ClipOval(
                child: Image.asset(
                  _bankIconPath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    width: 40,
                    height: 40,
                    color: colors.surfaceVariant,
                    child: Icon(
                      Icons.account_balance,
                      size: 20,
                      color: colors.onBackgroundLight,
                    ),
                  ),
                ),
              ),
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
                      account.bank.isNotEmpty
                          ? '${account.bank} · $typeLabel'
                          : typeLabel,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                  ],
                ),
              ),
              AmountText(
                amount: account.balance,
                isIncome: account.balance >= 0,
                fontSize: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
