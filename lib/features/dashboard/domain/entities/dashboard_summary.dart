import 'package:equatable/equatable.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';

class CategoryAmount extends Equatable {
  const CategoryAmount({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
  });

  final String categoryId;
  final String categoryName;
  final int categoryColor;
  final double amount;

  @override
  List<Object> get props => [categoryId, categoryName, categoryColor, amount];
}

/// A market-valued investment account on the Dashboard, backed by an investing
/// institution. Its value is the live market value of that institution's
/// holdings (BRL, FX-consolidated) rather than a hand-kept principal balance —
/// the core of the F8 account/investing unification (see
/// `docs/specs/investing_account_unification.md`).
class InvestmentAccountRow extends Equatable {
  const InvestmentAccountRow({
    required this.institutionId,
    required this.name,
    required this.marketValue,
    required this.invested,
    this.nativeValue = 0,
    this.bank,
    this.color,
    this.currencyCode,
    this.priceStale = false,
  });

  /// The backing institution id (also the mute/selection key on the Dashboard).
  final String institutionId;

  /// Display name (the institution/broker name).
  final String name;

  /// Live market value of the institution's holdings, in BRL.
  final double marketValue;

  /// Cost basis of the open positions, in BRL.
  final double invested;

  /// Market value in the institution's own currency (major units). Shown as the
  /// primary figure for foreign institutions (e.g. US$ for Avenue), with
  /// [marketValue] rendered below as the `≈ R$` estimate. Equals [marketValue]
  /// for BRL institutions.
  final double nativeValue;

  /// Optional `BankType.name` for a brand avatar; null → initials avatar.
  final String? bank;

  /// Optional ARGB display colour for the fallback avatar.
  final int? color;

  /// The institution's native currency code (e.g. `USD`); shown as a hint when
  /// it is not BRL.
  final String? currencyCode;

  /// True when the valuation fell back to cost because a quote was missing/stale.
  final bool priceStale;

  @override
  List<Object?> get props => [
    institutionId,
    name,
    marketValue,
    invested,
    nativeValue,
    bank,
    color,
    currencyCode,
    priceStale,
  ];
}

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netResult,
    required this.accounts,
    required this.expensesByCategory,
    required this.incomeByCategory,
    required this.fiftyThirtyTwenty,
    this.investmentAccounts = const [],
    this.accountBrlById = const {},
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final double netResult;
  final List<AccountEntity> accounts;

  /// BRL estimate per account id (native balance × current FX). Drives the
  /// consolidated "Total" and each account row's `≈ R$` sub-line. A foreign
  /// account with no available rate is absent (F9 — see
  /// `docs/specs/multi_currency_accounts.md`).
  final Map<String, double> accountBrlById;

  /// Market-valued investment accounts (institutions). Rendered in the
  /// "Account Balances" section alongside checking accounts so the Dashboard
  /// total reflects true net worth (cash + market value). Empty until the
  /// investing module has institutions with holdings.
  final List<InvestmentAccountRow> investmentAccounts;
  final List<CategoryAmount> expensesByCategory;
  final List<CategoryAmount> incomeByCategory;

  /// Per-period 50/30/20 split. Computed by `compute50_30_20Overview`
  /// inside the repository so callers don't need to compose it. See
  /// `docs/specs/fifty_thirty_twenty.md`.
  final FiftyThirtyTwentyOverview fiftyThirtyTwenty;

  @override
  List<Object> get props => [
    totalBalance,
    totalIncome,
    totalExpenses,
    netResult,
    accounts,
    investmentAccounts,
    accountBrlById,
    expensesByCategory,
    incomeByCategory,
    fiftyThirtyTwenty,
  ];
}
