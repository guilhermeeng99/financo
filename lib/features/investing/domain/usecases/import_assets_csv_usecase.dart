import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/utils/csv_parsing.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/services/investing_csv_parsers.dart';
import 'package:financo/features/investing/domain/usecases/create_asset_usecase.dart';
import 'package:financo/features/investing/domain/usecases/create_institution_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_institutions_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';

/// One asset row parsed from a CSV, before persistence.
class AssetImportPreviewItem extends Equatable {
  const AssetImportPreviewItem({
    required this.ticker,
    required this.name,
    required this.kind,
    required this.market,
    required this.currency,
    required this.institutionName,
  });

  final String ticker;
  final String name;
  final AssetKind kind;
  final Market market;
  final Currency currency;
  final String institutionName;

  @override
  List<Object?> get props => [
    ticker,
    name,
    kind,
    market,
    currency,
    institutionName,
  ];
}

class AssetImportPreview extends Equatable {
  const AssetImportPreview({required this.toCreate, required this.duplicates});

  final List<AssetImportPreviewItem> toCreate;
  final List<AssetImportPreviewItem> duplicates;

  @override
  List<Object?> get props => [toCreate, duplicates];
}

class AssetImportResult extends Equatable {
  const AssetImportResult({
    required this.importedCount,
    required this.duplicateCount,
    required this.institutionsCreated,
  });

  final int importedCount;
  final int duplicateCount;
  final int institutionsCreated;

  @override
  List<Object?> get props => [
    importedCount,
    duplicateCount,
    institutionsCreated,
  ];
}

const _assetHeaderSynonyms = <String, List<String>>{
  'ticker': ['ticker', 'simbolo', 'symbol', 'codigo', 'code', 'ativo'],
  'name': ['nome', 'name', 'descricao', 'description'],
  'kind': ['kind', 'tipo', 'type', 'classe', 'class'],
  'market': ['market', 'mercado', 'bolsa', 'exchange'],
  'currency': ['currency', 'moeda'],
  'institution': [
    'institution',
    'instituicao',
    'corretora',
    'broker',
    'custodia',
  ],
};

/// Imports investing assets from a CSV. Headers are matched by name
/// (accent/case-insensitive, reorder-tolerant). Required: `ticker`, `kind`,
/// `institution`; `market`/`currency` default from the kind, `name` defaults
/// to the ticker. Dedup is by `(ticker, market)` — an existing asset is
/// reported as a duplicate and skipped. Institutions are resolved by name and
/// **created on the fly** (kind broker) when missing. See
/// `docs/specs/investing_csv_import.md`.
class ImportAssetsCsvUseCase {
  const ImportAssetsCsvUseCase({
    required GetAssetsUseCase getAssets,
    required GetInstitutionsUseCase getInstitutions,
    required CreateAssetUseCase createAsset,
    required CreateInstitutionUseCase createInstitution,
  }) : _getAssets = getAssets,
       _getInstitutions = getInstitutions,
       _createAsset = createAsset,
       _createInstitution = createInstitution;

  final GetAssetsUseCase _getAssets;
  final GetInstitutionsUseCase _getInstitutions;
  final CreateAssetUseCase _createAsset;
  final CreateInstitutionUseCase _createInstitution;

  Future<Either<Failure, AssetImportPreview>> preview({
    required String csvContent,
    required String userId,
  }) async {
    try {
      final parsed = _parseCsv(csvContent);
      final existingResult = await _getAssets(userId: userId);
      return existingResult.fold(
        Left.new,
        (existing) => Right(_buildPreview(parsed, existing)),
      );
    } on FormatException catch (e) {
      return Left(ValidationFailure(e.message));
    } on Exception {
      return const Left(ServerFailure('Failed to import assets.'));
    }
  }

  Future<Either<Failure, AssetImportResult>> call({
    required String csvContent,
    required String userId,
  }) async {
    final previewResult = await preview(csvContent: csvContent, userId: userId);
    return previewResult.fold(Left.new, (preview) {
      return importItems(
        items: preview.toCreate,
        userId: userId,
        duplicateCount: preview.duplicates.length,
      );
    });
  }

  /// Persists the (possibly user-edited) [items]. Institutions referenced by
  /// name are reused or created (kind broker, the item's currency). Each asset
  /// is created through [CreateAssetUseCase] so its `(ticker, market)`
  /// uniqueness is enforced. Stops at the first failure. [onProgress] fires
  /// after every item (created or skipped).
  Future<Either<Failure, AssetImportResult>> importItems({
    required List<AssetImportPreviewItem> items,
    required String userId,
    int duplicateCount = 0,
    void Function(int processed, int total)? onProgress,
  }) async {
    final institutionsResult = await _getInstitutions(userId: userId);
    final institutionsFailure = institutionsResult.fold<Failure?>(
      (f) => f,
      (_) => null,
    );
    if (institutionsFailure != null) return Left(institutionsFailure);

    final institutionByName = <String, Institution>{
      for (final i in institutionsResult.getOrElse(() => const []))
        i.name.toLowerCase(): i,
    };

    final now = DateTime.now();
    final total = items.length;
    var processed = 0;
    var importedCount = 0;
    var institutionsCreated = 0;

    for (final item in items) {
      final resolved = await _resolveInstitution(
        item: item,
        userId: userId,
        cache: institutionByName,
        now: now,
      );
      final failure = resolved.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return Left(failure);
      final institution = resolved.getOrElse(() => throw StateError('checked'));
      if (institution.$2) institutionsCreated++;

      final asset = Asset(
        id: '',
        userId: userId,
        ticker: item.ticker,
        name: item.name,
        kind: item.kind,
        market: item.market,
        currency: item.currency,
        institutionId: institution.$1.id,
        createdAt: now,
      );
      final created = await _createAsset(asset);
      final createFailure = created.fold<Failure?>((f) => f, (_) => null);
      if (createFailure != null) return Left(createFailure);
      importedCount++;
      processed++;
      onProgress?.call(processed, total);
    }

    return Right(
      AssetImportResult(
        importedCount: importedCount,
        duplicateCount: duplicateCount,
        institutionsCreated: institutionsCreated,
      ),
    );
  }

  /// Returns the institution for [item] (creating it when absent) and whether
  /// it was newly created, updating [cache] so later rows reuse it.
  Future<Either<Failure, (Institution, bool)>> _resolveInstitution({
    required AssetImportPreviewItem item,
    required String userId,
    required Map<String, Institution> cache,
    required DateTime now,
  }) async {
    final existing = cache[item.institutionName.toLowerCase()];
    if (existing != null) return Right((existing, false));

    final created = await _createInstitution(
      Institution(
        id: '',
        userId: userId,
        name: item.institutionName,
        kind: InstitutionKind.broker,
        currency: item.currency,
        createdAt: now,
      ),
    );
    return created.map((institution) {
      cache[institution.name.toLowerCase()] = institution;
      return (institution, true);
    });
  }

  List<AssetImportPreviewItem> _parseCsv(String csvContent) {
    final rows = Csv().decode(csvContent.trim());
    if (rows.length < 2) {
      throw FormatException(t.csvImport.errors.emptyFile);
    }
    final colIndex = mapCsvHeaderColumns(
      rows.first,
      synonyms: _assetHeaderSynonyms,
    );
    for (final required in const ['ticker', 'kind', 'institution']) {
      if (!colIndex.containsKey(required)) {
        throw FormatException(
          t.csvImport.errors.missingColumn(column: required),
        );
      }
    }

    final items = <AssetImportPreviewItem>[];
    final seen = <String>{};
    var rowNumber = 1;
    for (final row in rows.skip(1)) {
      rowNumber++;
      final ticker = readCsvCell(row, colIndex['ticker']).toUpperCase();
      if (ticker.isEmpty) continue;

      final kind = parseAssetKind(
        readCsvCell(row, colIndex['kind']),
        rowNumber,
      );
      final institution = readCsvCell(row, colIndex['institution']);
      if (institution.isEmpty) {
        throw FormatException(
          t.csvImport.errors.institutionEmpty(row: rowNumber),
        );
      }

      final defaults = assetKindDefaults(kind);
      final market =
          parseMarket(readCsvCell(row, colIndex['market']), rowNumber) ??
          defaults.$1;
      final currency =
          parseCurrency(readCsvCell(row, colIndex['currency']), rowNumber) ??
          defaults.$2;
      final nameCell = readCsvCell(row, colIndex['name']);

      final key = '$ticker|${market.name}';
      if (!seen.add(key)) continue;

      items.add(
        AssetImportPreviewItem(
          ticker: ticker,
          name: nameCell.isEmpty ? ticker : nameCell,
          kind: kind,
          market: market,
          currency: currency,
          institutionName: institution,
        ),
      );
    }

    if (items.isEmpty) {
      throw FormatException(t.csvImport.errors.noValidAssets);
    }
    return items;
  }

  AssetImportPreview _buildPreview(
    List<AssetImportPreviewItem> parsed,
    List<Asset> existing,
  ) {
    final existingKeys = {
      for (final a in existing) '${a.ticker.toUpperCase()}|${a.market.name}',
    };
    final toCreate = <AssetImportPreviewItem>[];
    final duplicates = <AssetImportPreviewItem>[];
    for (final item in parsed) {
      final key = '${item.ticker}|${item.market.name}';
      if (existingKeys.contains(key)) {
        duplicates.add(item);
      } else {
        toCreate.add(item);
      }
    }
    return AssetImportPreview(toCreate: toCreate, duplicates: duplicates);
  }
}
