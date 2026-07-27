import 'package:equatable/equatable.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/accounts/domain/bank_brand.dart';

/// Persisted as `enum.name` in Firestore + Drift. `investment` is
/// **deprecated** post-F8: 50/30/20 savings is now driven by
/// `institutionId`-tagged aporte/resgate cash flows, not by
/// checking→investment transfers (see
/// docs/specs/investing_account_unification.md). The value is retired in data
/// by the F8 migration and kept only so legacy/in-flight docs deserialize
/// until F8.6 removes it; until then it still behaves like `checking` for any
/// remaining widget or calculation.
enum AccountType { checking, creditCard, investment }

/// Supported banks. Persisted as `enum.name` in Firestore + Drift, so
/// any rename here is a breaking change for existing rows. Add new
/// values at the end (and a matching entry in [BankBrand._registry])
/// rather than reordering — `enum.name` is order-independent but keeps
/// readers grepping for the rename hazard front-of-mind.
enum BankType {
  nubank,
  nuInvest,
  itau,
  bradesco,
  bancoDoBrasil,
  santander,
  caixa,
  inter,
  c6,
  btg,
  sicredi,
  sicoob,
  picpay,
  mercadoPago,
  pan,
  original,
  safra,
  xp,
  next,
  will,
  neon,
  avenue,
  wise,
  others,
}

class AccountEntity extends Equatable {
  const AccountEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.bank,
    required this.initialBalance,
    required this.createdAt,
    this.currency = Currency.brl,
    this.creditLimit,
    this.closingDay,
    this.dueDay,
    this.linkedAccountId,
    this.currentBalance,
  });

  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final BankType bank;
  final double initialBalance;

  /// The currency this account is denominated in. Every balance and transaction
  /// amount on it is native to this currency; the app consolidates to BRL at
  /// the current FX rate for combined views (F9 — see
  /// `docs/specs/multi_currency_accounts.md`). Defaults to BRL; existing
  /// accounts are BRL, so BRL-only users see identical numbers.
  final Currency currency;
  final double? creditLimit;
  final int? closingDay;
  final int? dueDay;
  final String? linkedAccountId;
  final DateTime createdAt;

  /// Running balance derived from `initialBalance` plus the live
  /// transactions on this account. Null when nobody has populated it
  /// yet — getters that need a "live" value fall back to
  /// [initialBalance] in that case.
  ///
  /// Sign convention follows the seed: for checking accounts a positive
  /// number means money in the account, for credit cards a positive
  /// number means the amount currently owed (so expenses on the card
  /// raise it and payments lower it).
  final double? currentBalance;

  /// What the user effectively has (checking) or owes (credit card)
  /// right now — `currentBalance` if loaded, otherwise the seed.
  double get effectiveBalance => currentBalance ?? initialBalance;

  /// How much of the credit limit is currently being used. 0 for
  /// non-credit-card accounts. Clamped to `[0, creditLimit]` so an
  /// over-the-limit balance still maxes out at 100% in the UI.
  double get usedCredit {
    if (type != AccountType.creditCard) return 0;
    final limit = creditLimit ?? 0;
    return effectiveBalance.clamp(0.0, limit);
  }

  double get availableCredit {
    if (creditLimit == null) return 0;
    return (creditLimit! - usedCredit).clamp(0.0, creditLimit!);
  }

  String get bankLabel => BankBrand.of(bank).label;

  AccountEntity copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    BankType? bank,
    double? initialBalance,
    Currency? currency,
    double? creditLimit,
    int? closingDay,
    int? dueDay,
    String? linkedAccountId,
    DateTime? createdAt,
    double? currentBalance,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      bank: bank ?? this.bank,
      initialBalance: initialBalance ?? this.initialBalance,
      currency: currency ?? this.currency,
      creditLimit: creditLimit ?? this.creditLimit,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      createdAt: createdAt ?? this.createdAt,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    type,
    bank,
    initialBalance,
    currency,
    creditLimit,
    closingDay,
    dueDay,
    linkedAccountId,
    createdAt,
    currentBalance,
  ];
}
