import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/csv_parsing.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/services/investing_csv_parsers.dart';
import 'package:financo/features/investing/domain/services/transaction_amounts.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/domain/usecases/save_asset_transaction_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';

/// Why a parsed transaction row can't be imported (its references don't
/// resolve). Structural cell errors are thrown during parsing instead.
enum InvestingTransactionImportProblem {
  /// No asset matches the row's ticker (+ market).
  assetNotFound,

  /// The ticker matches more than one asset and no market disambiguates it.
  assetAmbiguous,

  /// The matched asset has no institution, so the transaction can't be linked.
  assetNoInstitution,
}

/// One transaction row parsed from a CSV, with its references resolved.
class InvestingTransactionImportPreviewItem extends Equatable {
  const InvestingTransactionImportPreviewItem({
    required this.ticker,
    required this.kind,
    required this.quantity,
    required this.unitPriceMajor,
    required this.amountMajor,
    required this.feesMajor,
    required this.date,
    this.market,
    this.notes,
    this.asset,
    this.problem,
  });

  final String ticker;
  final String? market;
  final TransactionKind kind;
  final double quantity;
  final double unitPriceMajor;
  final double amountMajor;
  final double feesMajor;
  final DateTime date;
  final String? notes;

  /// The resolved asset, or null when [problem] is set.
  final Asset? asset;
  final InvestingTransactionImportProblem? problem;

  bool get canImport => problem == null && asset != null;

  @override
  List<Object?> get props => [
    ticker,
    market,
    kind,
    quantity,
    unitPriceMajor,
    amountMajor,
    feesMajor,
    date,
    notes,
    asset,
    problem,
  ];
}

class InvestingTransactionImportPreview extends Equatable {
  const InvestingTransactionImportPreview({
    required this.toImport,
    required this.skipped,
  });

  final List<InvestingTransactionImportPreviewItem> toImport;
  final List<InvestingTransactionImportPreviewItem> skipped;

  @override
  List<Object?> get props => [toImport, skipped];
}

class InvestingTransactionImportResult extends Equatable {
  const InvestingTransactionImportResult({
    required this.importedCount,
    required this.skippedCount,
  });

  final int importedCount;
  final int skippedCount;

  @override
  List<Object?> get props => [importedCount, skippedCount];
}

const _txHeaderSynonyms = <String, List<String>>{
  'ticker': ['ticker', 'simbolo', 'symbol', 'codigo', 'code', 'ativo'],
  'market': ['market', 'mercado'],
  'operation': [
    'operation',
    'operacao',
    'transacao',
    'side',
    'movimento',
    'tipo',
  ],
  'quantity': [
    'quantity',
    'quantidade',
    'qtd',
    'qtde',
    'qty',
    'shares',
    'cotas',
  ],
  'price': [
    'price',
    'preco',
    'preco medio',
    'unit price',
    'valor unitario',
    'cotacao',
  ],
  'amount': ['amount', 'valor', 'total', 'valor total'],
  'fees': ['fees', 'taxas', 'custos', 'corretagem'],
  'date': ['date', 'data'],
  'notes': ['notes', 'notas', 'observacao', 'obs'],
};

/// Imports investing transactions from a CSV. Headers are matched by name.
/// Required: `ticker`; `quantity`+`price` for buy/sell, `amount` for dividend.
/// Optional: `operation` (default buy), `fees` (0), `date` (today), `notes`,
/// `market`. The asset must already exist (matched by ticker, disambiguated by
/// market) and carry an institution — unresolved rows are reported as skipped,
/// not fatal. Persisted oldest-first (buy before sell) through
/// [SaveAssetTransactionUseCase] so its oversell guard sees covering buys
/// first. See `docs/specs/investing_csv_import.md`.
class ImportInvestingTransactionsCsvUseCase {
  const ImportInvestingTransactionsCsvUseCase({
    required GetAssetsUseCase getAssets,
    required SaveAssetTransactionUseCase saveTransaction,
  }) : _getAssets = getAssets,
       _saveTransaction = saveTransaction;

  final GetAssetsUseCase _getAssets;
  final SaveAssetTransactionUseCase _saveTransaction;

  Future<Either<Failure, InvestingTransactionImportPreview>> preview({
    required String csvContent,
    required String userId,
  }) async {
    try {
      final parsed = _parseCsv(csvContent);
      final assetsResult = await _getAssets(userId: userId);
      return assetsResult.fold(
        Left.new,
        (assets) => Right(_buildPreview(parsed, assets)),
      );
    } on FormatException catch (e) {
      return Left(ValidationFailure(e.message));
    } on Exception {
      return const Left(ServerFailure('Failed to import transactions.'));
    }
  }

  Future<Either<Failure, InvestingTransactionImportResult>> call({
    required String csvContent,
    required String userId,
  }) async {
    final previewResult = await preview(csvContent: csvContent, userId: userId);
    return previewResult.fold(Left.new, (preview) {
      return importItems(
        items: preview.toImport,
        userId: userId,
        skippedCount: preview.skipped.length,
      );
    });
  }

  /// Persists the importable [items] oldest-first (buy before sell). Stops at
  /// the first save failure (e.g. an oversell in the data). [onProgress] fires
  /// after every item.
  Future<Either<Failure, InvestingTransactionImportResult>> importItems({
    required List<InvestingTransactionImportPreviewItem> items,
    required String userId,
    int skippedCount = 0,
    void Function(int processed, int total)? onProgress,
  }) async {
    final ordered = [...items.where((i) => i.canImport)]
      ..sort(_compareForImport);

    final total = ordered.length;
    var processed = 0;
    var importedCount = 0;

    for (final item in ordered) {
      final tx = _buildTransaction(item: item, userId: userId);
      final saved = await _saveTransaction(tx);
      final failure = saved.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return Left(failure);
      importedCount++;
      processed++;
      onProgress?.call(processed, total);
    }

    return Right(
      InvestingTransactionImportResult(
        importedCount: importedCount,
        skippedCount: skippedCount,
      ),
    );
  }

  AssetTransaction _buildTransaction({
    required InvestingTransactionImportPreviewItem item,
    required String userId,
  }) {
    final asset = item.asset!;
    final currency = asset.currency;
    final resolved = resolveTransactionAmounts(
      kind: item.kind,
      quantity: item.quantity,
      unitPrice: Money.fromMajor(item.unitPriceMajor, currency),
      amount: Money.fromMajor(item.amountMajor, currency),
      currency: currency,
    );
    final now = DateTime.now();
    return AssetTransaction(
      id: '',
      userId: userId,
      institutionId: asset.institutionId!,
      assetId: asset.id,
      kind: item.kind,
      quantity: resolved.quantity,
      unitPrice: resolved.unitPrice,
      fees: Money.fromMajor(item.feesMajor, currency),
      amount: resolved.amount,
      date: item.date,
      notes: item.notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Oldest-first, buy before sell at the same instant — mirrors
  /// `compareTransactionsOldestFirst` on the built entities. Preview items have
  /// no `createdAt`, so date then kind rank is the meaningful order.
  int _compareForImport(
    InvestingTransactionImportPreviewItem a,
    InvestingTransactionImportPreviewItem b,
  ) {
    final byDate = a.date.compareTo(b.date);
    if (byDate != 0) return byDate;
    return transactionKindRank(a.kind).compareTo(transactionKindRank(b.kind));
  }

  List<InvestingTransactionImportPreviewItem> _parseCsv(String csvContent) {
    final rows = Csv().decode(csvContent.trim());
    if (rows.length < 2) {
      throw FormatException(t.csvImport.errors.emptyFile);
    }
    final colIndex = mapCsvHeaderColumns(
      rows.first,
      synonyms: _txHeaderSynonyms,
    );
    if (!colIndex.containsKey('ticker')) {
      throw FormatException(t.csvImport.errors.missingColumn(column: 'ticker'));
    }

    final items = <InvestingTransactionImportPreviewItem>[];
    var rowNumber = 1;
    for (final row in rows.skip(1)) {
      rowNumber++;
      final ticker = readCsvCell(row, colIndex['ticker']).toUpperCase();
      if (ticker.isEmpty) continue;

      final kind = parseTransactionKind(
        readCsvCell(row, colIndex['operation']),
        rowNumber,
      );
      final quantity = parseCsvAmount(
        readCsvCell(row, colIndex['quantity']),
        absolute: true,
      );
      final priceCell = readCsvCell(row, colIndex['price']);
      final amount = parseCsvAmount(
        readCsvCell(row, colIndex['amount']),
        absolute: true,
      );
      final fees = parseCsvAmount(
        readCsvCell(row, colIndex['fees']),
        absolute: true,
      );

      if (kind == TransactionKind.dividend) {
        if (amount <= 0) {
          throw FormatException(
            t.csvImport.errors.dividendAmountRequired(row: rowNumber),
          );
        }
      } else {
        if (quantity <= 0) {
          throw FormatException(
            t.csvImport.errors.quantityRequired(row: rowNumber),
          );
        }
        if (priceCell.isEmpty) {
          throw FormatException(
            t.csvImport.errors.priceRequired(row: rowNumber),
          );
        }
      }

      final date = _parseDate(readCsvCell(row, colIndex['date']), rowNumber);
      // Normalize the optional market through the same parser the asset import
      // uses, so friendly spellings ("Brasil", "USA") resolve to the enum name
      // and match `Asset.market.name` in `_resolve` (not a raw cell string).
      final market = parseMarket(
        readCsvCell(row, colIndex['market']),
        rowNumber,
      );
      final notesCell = readCsvCell(row, colIndex['notes']);

      items.add(
        InvestingTransactionImportPreviewItem(
          ticker: ticker,
          market: market?.name,
          kind: kind,
          quantity: quantity,
          unitPriceMajor: parseCsvAmount(priceCell, absolute: true),
          amountMajor: amount,
          feesMajor: fees,
          date: date,
          notes: notesCell.isEmpty ? null : notesCell,
        ),
      );
    }

    if (items.isEmpty) {
      throw FormatException(t.csvImport.errors.noValidTransactions);
    }
    return items;
  }

  DateTime _parseDate(String raw, int row) {
    if (raw.isEmpty) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    final parsed = parseDmyDate(raw) ?? DateTime.tryParse(raw);
    if (parsed == null) {
      throw FormatException(
        t.csvImport.errors.invalidDate(row: row, value: raw),
      );
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  InvestingTransactionImportPreview _buildPreview(
    List<InvestingTransactionImportPreviewItem> parsed,
    List<Asset> assets,
  ) {
    final toImport = <InvestingTransactionImportPreviewItem>[];
    final skipped = <InvestingTransactionImportPreviewItem>[];
    for (final item in parsed) {
      final resolved = _resolve(item, assets);
      if (resolved.canImport) {
        toImport.add(resolved);
      } else {
        skipped.add(resolved);
      }
    }
    return InvestingTransactionImportPreview(
      toImport: toImport,
      skipped: skipped,
    );
  }

  InvestingTransactionImportPreviewItem _resolve(
    InvestingTransactionImportPreviewItem item,
    List<Asset> assets,
  ) {
    final matches = assets.where((a) {
      if (a.ticker.toUpperCase() != item.ticker) return false;
      if (item.market == null) return true;
      return a.market.name == item.market;
    }).toList();

    if (matches.isEmpty) {
      return _withProblem(
        item,
        InvestingTransactionImportProblem.assetNotFound,
      );
    }
    if (matches.length > 1) {
      return _withProblem(
        item,
        InvestingTransactionImportProblem.assetAmbiguous,
      );
    }
    final asset = matches.single;
    if (asset.institutionId == null || asset.institutionId!.isEmpty) {
      return _withProblem(
        item,
        InvestingTransactionImportProblem.assetNoInstitution,
      );
    }
    return _withAsset(item, asset);
  }

  InvestingTransactionImportPreviewItem _withProblem(
    InvestingTransactionImportPreviewItem item,
    InvestingTransactionImportProblem problem,
  ) {
    return InvestingTransactionImportPreviewItem(
      ticker: item.ticker,
      market: item.market,
      kind: item.kind,
      quantity: item.quantity,
      unitPriceMajor: item.unitPriceMajor,
      amountMajor: item.amountMajor,
      feesMajor: item.feesMajor,
      date: item.date,
      notes: item.notes,
      problem: problem,
    );
  }

  InvestingTransactionImportPreviewItem _withAsset(
    InvestingTransactionImportPreviewItem item,
    Asset asset,
  ) {
    return InvestingTransactionImportPreviewItem(
      ticker: item.ticker,
      market: item.market,
      kind: item.kind,
      quantity: item.quantity,
      unitPriceMajor: item.unitPriceMajor,
      amountMajor: item.amountMajor,
      feesMajor: item.feesMajor,
      date: item.date,
      notes: item.notes,
      asset: asset,
    );
  }
}
