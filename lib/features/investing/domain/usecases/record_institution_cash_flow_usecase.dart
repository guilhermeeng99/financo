import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';
import 'package:financo/features/investing/domain/usecases/save_asset_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

/// Whether cash is moving into an institution (a deposit/aporte) or back out to
/// a checking account (a withdrawal/resgate).
enum InstitutionCashDirection { deposit, withdraw }

/// Records — as a **single user action** — cash moving between a checking
/// account and an institution, e.g. "deposit R$7000 into Wise, from Nubank
/// Gui" (F8.4 — see `docs/specs/investing_account_unification.md`).
///
/// It writes two linked rows so the money is counted once on each side:
///  1. an investing [AssetTransaction] on a per-currency **cash** holding at
///     the institution (`buy` for a deposit, `sell` for a withdrawal), so the
///     Dashboard shows the balance move at the institution; and
///  2. a paired cash [TransactionEntity] on the checking account (an expense
///     for a deposit, income for a withdrawal), tagged with `institutionId` and
///     the investing transaction id, so the account balance and the 50/30/20
///     aporte flow both see it.
///
/// The cash holding is a `cash` asset — the kind the model already reserves for
/// "a Wise EUR account, a broker cash reserve" (see
/// [AssetKind.selectableKinds]). The first deposit in a given currency
/// auto-creates that cash asset.
///
/// The two writes are not yet a single atomic batch (they target different
/// collections); if the second write fails the first is rolled back
/// best-effort so a deposit never half-lands.
class RecordInstitutionCashFlowUseCase {
  const RecordInstitutionCashFlowUseCase({
    required AssetRepository assetRepository,
    required AssetTransactionRepository assetTransactionRepository,
    required SaveAssetTransactionUseCase saveAssetTransaction,
    required TransactionRepository transactionRepository,
  }) : _assets = assetRepository,
       _assetTransactions = assetTransactionRepository,
       _saveAssetTransaction = saveAssetTransaction,
       _transactions = transactionRepository;

  final AssetRepository _assets;
  final AssetTransactionRepository _assetTransactions;
  final SaveAssetTransactionUseCase _saveAssetTransaction;
  final TransactionRepository _transactions;

  /// [amount] is the amount in the holding's [currency] (BRL by default). For a
  /// foreign-currency deposit funded from a BRL account, pass [cashAmountBrl]
  /// as the reais that actually left the account; it defaults to [amount]
  /// (correct when [currency] is BRL). Returns the checking-side transaction.
  Future<Either<Failure, TransactionEntity>> call({
    required String userId,
    required String institutionId,
    required String checkingAccountId,
    required double amount,
    required InstitutionCashDirection direction,
    Currency currency = Currency.brl,
    double? cashAmountBrl,
    DateTime? date,
    String? description,
  }) async {
    if (amount <= 0) return const Left(NonPositiveQuantityFailure());
    final when = date ?? DateTime.now();
    final label = (description == null || description.trim().isEmpty)
        ? _defaultLabel(direction)
        : description.trim();
    final isDeposit = direction == InstitutionCashDirection.deposit;

    final cashAssetResult = await _resolveCashAsset(
      userId: userId,
      institutionId: institutionId,
      currency: currency,
      createdAt: when,
    );
    final cashAssetFailure = cashAssetResult.fold<Failure?>(
      (f) => f,
      (_) => null,
    );
    if (cashAssetFailure != null) return Left(cashAssetFailure);
    final cashAsset = cashAssetResult.getOrElse(_unreachableAsset);

    // 1) Investing leg: buy on deposit, sell on withdrawal, of the cash
    //    holding.
    final investing = AssetTransaction(
      id: '',
      userId: userId,
      institutionId: institutionId,
      assetId: cashAsset.id,
      kind: isDeposit ? TransactionKind.buy : TransactionKind.sell,
      quantity: amount,
      unitPrice: Money.fromMajor(1, currency),
      fees: Money.zero(currency),
      amount: Money.fromMajor(amount, currency),
      date: when,
      createdAt: when,
      updatedAt: when,
      fundingAccountId: checkingAccountId,
      cashAmount: Money.fromMajor(cashAmountBrl ?? amount, Currency.brl),
      notes: label,
    );
    final savedInvestingResult = await _saveAssetTransaction(investing);
    final investingFailure = savedInvestingResult.fold<Failure?>(
      (f) => f,
      (_) => null,
    );
    if (investingFailure != null) return Left(investingFailure);
    final savedInvesting = savedInvestingResult.getOrElse(_unreachableTx);

    // 2) Checking-side cash leg, tagged to the institution + investing tx.
    final cash = TransactionEntity(
      id: '',
      userId: userId,
      accountId: checkingAccountId,
      categoryId: '',
      type: isDeposit ? TransactionType.expense : TransactionType.income,
      amount: cashAmountBrl ?? amount,
      description: label,
      date: when,
      createdAt: when,
      updatedAt: when,
      institutionId: institutionId,
      linkedInvestmentTransactionId: savedInvesting.id,
    );
    final savedCashResult = await _transactions.createTransaction(cash);
    final cashFailure = savedCashResult.fold<Failure?>((f) => f, (_) => null);
    if (cashFailure != null) {
      // Roll back the investing leg so the deposit never half-lands.
      await _assetTransactions.deleteTransaction(savedInvesting.id);
      return Left(cashFailure);
    }
    return savedCashResult;
  }

  /// Finds the institution's cash holding for [currency], creating it on the
  /// first deposit. Cash assets use a synthetic, per-institution ticker so two
  /// institutions can each hold BRL cash without colliding.
  Future<Either<Failure, Asset>> _resolveCashAsset({
    required String userId,
    required String institutionId,
    required Currency currency,
    required DateTime createdAt,
  }) async {
    final existingResult = await _assets.getAssets(userId: userId);
    final existingFailure = existingResult.fold<Failure?>(
      (f) => f,
      (_) => null,
    );
    if (existingFailure != null) return Left(existingFailure);

    final match = existingResult
        .getOrElse(() => const [])
        .where(
          (a) =>
              a.kind == AssetKind.cash &&
              a.institutionId == institutionId &&
              a.currency == currency,
        );
    if (match.isNotEmpty) return Right(match.first);

    final cashAsset = Asset(
      id: '',
      userId: userId,
      ticker: 'CASH-${currency.code}-$institutionId',
      name: '${currency.code} cash',
      kind: AssetKind.cash,
      market: Market.global,
      currency: currency,
      institutionId: institutionId,
      createdAt: createdAt,
    );
    return _assets.createAsset(cashAsset);
  }

  String _defaultLabel(InstitutionCashDirection direction) =>
      direction == InstitutionCashDirection.deposit ? 'Aporte' : 'Resgate';

  // Guarded by a preceding failure check — the Right branch is always present.
  Never _unreachableAsset() =>
      throw StateError('cash asset unexpectedly absent');
  Never _unreachableTx() =>
      throw StateError('investing transaction unexpectedly absent');
}
