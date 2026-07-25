import 'package:equatable/equatable.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

/// A checking-side transfer leg that becomes a single-entry investment cash
/// flow (aporte/resgate) tagged to [institutionId] once its investment-account
/// counterpart is retired (F8.5).
class ConvertedCashFlow extends Equatable {
  const ConvertedCashFlow({
    required this.transactionId,
    required this.institutionId,
  });

  /// The checking-side leg to re-tag (`institutionId` set, its
  /// `linkedTransactionId` cleared).
  final String transactionId;

  /// The institution the retired account merges into.
  final String institutionId;

  @override
  List<Object?> get props => [transactionId, institutionId];
}

/// One investment account folded into a matching institution (F8.5): its aporte
/// history is re-tagged to the institution, its account-side transfer legs are
/// deleted, and the account itself is removed.
class InvestmentAccountMerge extends Equatable {
  const InvestmentAccountMerge({
    required this.account,
    required this.institution,
    required this.aportes,
    required this.deletedLegIds,
    required this.orphanTransactionCount,
  });

  final AccountEntity account;
  final Institution institution;

  /// Checking-side legs re-tagged as institution cash flows.
  final List<ConvertedCashFlow> aportes;

  /// Account-side transfer legs to delete (their counterpart carries the flow).
  final List<String> deletedLegIds;

  /// Non-transfer transactions still pointing at the account — surfaced as a
  /// warning; the migration does not silently discard them.
  final int orphanTransactionCount;

  @override
  List<Object?> get props => [
    account.id,
    institution.id,
    aportes,
    deletedLegIds,
    orphanTransactionCount,
  ];
}

/// One Wise-style institution converted into a foreign-currency checking
/// account (F9.6). Only institutions with no holdings can convert cleanly.
class WiseInstitutionConversion extends Equatable {
  const WiseInstitutionConversion({
    required this.institution,
    required this.currency,
  });

  final Institution institution;
  final Currency currency;

  @override
  List<Object?> get props => [institution.id, currency];
}

/// The full, reviewable migration plan. Pure data — no writes happen until an
/// executor applies it, and only after the user confirms this preview.
class AccountMigrationPlan extends Equatable {
  const AccountMigrationPlan({
    required this.merges,
    required this.conversions,
    required this.warnings,
  });

  final List<InvestmentAccountMerge> merges;
  final List<WiseInstitutionConversion> conversions;
  final List<String> warnings;

  bool get isEmpty => merges.isEmpty && conversions.isEmpty;

  @override
  List<Object?> get props => [merges, conversions, warnings];
}

/// Computes the guided account/investing migration (F8.5 + F9.6) from the
/// current data and the user-confirmed mappings — without touching anything.
/// See `docs/specs/investing_account_unification.md` §6 and
/// `docs/specs/multi_currency_accounts.md` §6.
class AccountMigrationPlanner {
  const AccountMigrationPlanner();

  /// [accountToInstitutionId] maps an investment account id to the institution
  /// it folds into (F8.5). [institutionIdsToConvert] are the institutions that
  /// become foreign checking accounts (F9.6), each in [conversionCurrency].
  /// [institutionAssetCounts] lets the planner refuse to convert an institution
  /// that still holds assets.
  AccountMigrationPlan plan({
    required List<AccountEntity> accounts,
    required List<Institution> institutions,
    required List<TransactionEntity> transactions,
    required Map<String, String> accountToInstitutionId,
    required Set<String> institutionIdsToConvert,
    Map<String, int> institutionAssetCounts = const {},
    Currency conversionCurrency = Currency.eur,
  }) {
    final warnings = <String>[];
    final institutionById = {for (final i in institutions) i.id: i};
    final txById = {for (final t in transactions) t.id: t};

    final merges = <InvestmentAccountMerge>[];
    for (final account in accounts) {
      if (account.type != AccountType.investment) continue;
      final institutionId = accountToInstitutionId[account.id];
      if (institutionId == null) {
        warnings.add('No institution chosen for account "${account.name}".');
        continue;
      }
      final institution = institutionById[institutionId];
      if (institution == null) {
        warnings.add('Institution for "${account.name}" no longer exists.');
        continue;
      }
      merges.add(
        _mergeFor(account, institution, transactions, txById, warnings),
      );
    }

    final conversions = <WiseInstitutionConversion>[];
    for (final id in institutionIdsToConvert) {
      final institution = institutionById[id];
      if (institution == null) continue;
      final assetCount = institutionAssetCounts[id] ?? 0;
      if (assetCount > 0) {
        warnings.add(
          'Institution "${institution.name}" holds $assetCount asset(s) and '
          'cannot convert to a cash account until they are moved.',
        );
        continue;
      }
      conversions.add(
        WiseInstitutionConversion(
          institution: institution,
          currency: conversionCurrency,
        ),
      );
    }

    return AccountMigrationPlan(
      merges: merges,
      conversions: conversions,
      warnings: warnings,
    );
  }

  InvestmentAccountMerge _mergeFor(
    AccountEntity account,
    Institution institution,
    List<TransactionEntity> transactions,
    Map<String, TransactionEntity> txById,
    List<String> warnings,
  ) {
    final aportes = <ConvertedCashFlow>[];
    final deletedLegIds = <String>[];
    var orphanCount = 0;

    for (final t in transactions) {
      if (t.accountId != account.id) continue;
      if (!t.isTransfer) {
        orphanCount++;
        continue;
      }
      // This leg sits on the account being retired → delete it; its checking
      // counterpart becomes the institution cash flow.
      final counterpart = txById[t.linkedTransactionId];
      deletedLegIds.add(t.id);
      if (counterpart == null) continue; // half-pair; nothing to re-tag
      aportes.add(
        ConvertedCashFlow(
          transactionId: counterpart.id,
          institutionId: institution.id,
        ),
      );
    }

    if (orphanCount > 0) {
      warnings.add(
        '"${account.name}" has $orphanCount non-transfer transaction(s) that '
        'will be left pointing at the retired account — review them first.',
      );
    }

    return InvestmentAccountMerge(
      account: account,
      institution: institution,
      aportes: aportes,
      deletedLegIds: deletedLegIds,
      orphanTransactionCount: orphanCount,
    );
  }
}
