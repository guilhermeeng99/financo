import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/csv_parsing.dart';
import 'package:financo/core/utils/string_normalize.dart';
import 'package:financo/features/accounts/domain/bank_brand.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class AccountImportPreviewItem extends Equatable {
  const AccountImportPreviewItem({
    required this.name,
    required this.type,
    required this.bank,
    required this.initialBalance,
    this.creditLimit,
    this.closingDay,
    this.dueDay,
    this.linkedAccountName,
  });

  final String name;
  final AccountType type;
  final BankType bank;
  final double initialBalance;
  final double? creditLimit;
  final int? closingDay;
  final int? dueDay;
  final String? linkedAccountName;

  bool get isCreditCard => type == AccountType.creditCard;

  AccountImportPreviewItem copyWith({
    String? name,
    AccountType? type,
    BankType? bank,
    double? initialBalance,
    double? creditLimit,
    bool clearCreditLimit = false,
    int? closingDay,
    bool clearClosingDay = false,
    int? dueDay,
    bool clearDueDay = false,
    String? linkedAccountName,
    bool clearLinkedAccountName = false,
  }) {
    return AccountImportPreviewItem(
      name: name ?? this.name,
      type: type ?? this.type,
      bank: bank ?? this.bank,
      initialBalance: initialBalance ?? this.initialBalance,
      creditLimit: clearCreditLimit ? null : (creditLimit ?? this.creditLimit),
      closingDay: clearClosingDay ? null : (closingDay ?? this.closingDay),
      dueDay: clearDueDay ? null : (dueDay ?? this.dueDay),
      linkedAccountName: clearLinkedAccountName
          ? null
          : (linkedAccountName ?? this.linkedAccountName),
    );
  }

  @override
  List<Object?> get props => [
    name,
    type,
    bank,
    initialBalance,
    creditLimit,
    closingDay,
    dueDay,
    linkedAccountName,
  ];
}

class AccountImportPreview extends Equatable {
  const AccountImportPreview({
    required this.toCreate,
    required this.duplicates,
  });

  final List<AccountImportPreviewItem> toCreate;
  final List<AccountImportPreviewItem> duplicates;

  @override
  List<Object?> get props => [toCreate, duplicates];
}

class AccountImportResult extends Equatable {
  const AccountImportResult({
    required this.importedCount,
    required this.duplicateCount,
  });

  final int importedCount;
  final int duplicateCount;

  @override
  List<Object?> get props => [importedCount, duplicateCount];
}

/// Accounts header synonyms for [mapCsvHeaderColumns] — tolerates extra
/// columns (e.g. `Data Saldo Inicial` from Mobills exports), a reordered
/// layout, or English headers.
const _accountHeaderSynonyms = <String, List<String>>{
  'name': ['nome', 'name', 'account name', 'apelido'],
  'balance': [
    'saldo inicial',
    'saldo',
    'initial balance',
    'balance',
    'opening balance',
  ],
  'type': ['tipo', 'type', 'kind'],
  'bank': ['banco', 'bank'],
  'limit': ['limite', 'credit limit', 'limit'],
  'due': [
    'proximo vencimento',
    'vencimento',
    'due date',
    'due day',
    'next due',
  ],
  'closing': ['fechamento', 'closing day', 'closing', 'closing date'],
};

class ImportAccountsCsvUseCase {
  const ImportAccountsCsvUseCase(this._repository);

  final AccountRepository _repository;

  Future<Either<Failure, AccountImportPreview>> preview({
    required String csvContent,
    required String userId,
  }) async {
    try {
      final parsedItems = _parseCsv(csvContent);
      final existingResult = await _repository.getAccounts(userId: userId);

      return existingResult.fold(
        Left.new,
        (existing) => Right(_buildPreview(parsedItems, existing)),
      );
    } on FormatException catch (e) {
      return Left(ValidationFailure(e.message));
    } on Exception {
      return const Left(ServerFailure('Failed to import accounts.'));
    }
  }

  Future<Either<Failure, AccountImportResult>> call({
    required String csvContent,
    required String userId,
  }) async {
    final previewResult = await preview(csvContent: csvContent, userId: userId);

    Failure? previewFailure;
    AccountImportPreview? previewValue;
    previewResult.fold<void>(
      (failure) => previewFailure = failure,
      (value) => previewValue = value,
    );

    if (previewFailure != null) return Left(previewFailure!);

    return importItems(
      items: previewValue!.toCreate,
      userId: userId,
      duplicateCount: previewValue!.duplicates.length,
    );
  }

  /// Creates the (possibly user-edited) [items] under [userId] in two
  /// phases: checking accounts first (so credit cards can reference them
  /// by name), then credit cards. `linkedAccountName` is resolved against
  /// the latest existing accounts plus the just-created checking IDs.
  ///
  /// Credit cards whose `linkedAccountName` cannot be resolved are
  /// silently skipped — the import-preview page is expected to surface
  /// these as validation errors before invoking this method.
  ///
  /// [onProgress] is called after each item is processed (created or
  /// skipped) with `(processedCount, total)` so the caller can render a
  /// determinate progress UI. The callback is invoked synchronously
  /// between awaits, so emitting cubit state from inside it is safe.
  Future<Either<Failure, AccountImportResult>> importItems({
    required List<AccountImportPreviewItem> items,
    required String userId,
    int duplicateCount = 0,
    void Function(int processed, int total)? onProgress,
  }) async {
    final existingResult = await _repository.getAccounts(userId: userId);

    Failure? existingFailure;
    List<AccountEntity>? existing;
    existingResult.fold(
      (failure) => existingFailure = failure,
      (list) => existing = list,
    );

    if (existingFailure != null) return Left(existingFailure!);

    final checkingIds = <String, String>{};
    for (final account in existing!.where(
      (a) => a.type == AccountType.checking,
    )) {
      checkingIds[account.name.toLowerCase()] = account.id;
    }

    final now = DateTime.now();
    final total = items.length;
    var processed = 0;
    var importedCount = 0;

    final checkingItems = items.where((it) => !it.isCreditCard);
    final creditItems = items.where((it) => it.isCreditCard);

    for (final item in checkingItems) {
      final account = AccountEntity(
        id: '',
        userId: userId,
        name: item.name,
        type: AccountType.checking,
        bank: item.bank,
        initialBalance: item.initialBalance,
        createdAt: now,
      );

      final result = await _repository.createAccount(account);
      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return Left(failure);

      result.fold((_) {}, (created) {
        checkingIds[item.name.toLowerCase()] = created.id;
        importedCount++;
      });
      processed++;
      onProgress?.call(processed, total);
    }

    for (final item in creditItems) {
      final linkedKey = item.linkedAccountName?.toLowerCase();
      final linkedId = linkedKey == null ? null : checkingIds[linkedKey];
      if (linkedId == null) {
        processed++;
        onProgress?.call(processed, total);
        continue;
      }

      final account = AccountEntity(
        id: '',
        userId: userId,
        name: item.name,
        type: AccountType.creditCard,
        bank: item.bank,
        initialBalance: item.initialBalance,
        creditLimit: item.creditLimit,
        closingDay: item.closingDay,
        dueDay: item.dueDay,
        linkedAccountId: linkedId,
        createdAt: now,
      );

      final result = await _repository.createAccount(account);
      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return Left(failure);

      result.fold((_) {}, (_) => importedCount++);
      processed++;
      onProgress?.call(processed, total);
    }

    return Right(
      AccountImportResult(
        importedCount: importedCount,
        duplicateCount: duplicateCount,
      ),
    );
  }

  List<AccountImportPreviewItem> _parseCsv(String csvContent) {
    final rows = Csv().decode(csvContent.trim());
    if (rows.length < 2) {
      throw FormatException(t.csvImport.errors.emptyFile);
    }

    final colIndex = mapCsvHeaderColumns(
      rows.first,
      synonyms: _accountHeaderSynonyms,
    );
    for (final required in const ['name', 'balance', 'type', 'bank']) {
      if (!colIndex.containsKey(required)) {
        throw FormatException(
          t.csvImport.errors.missingColumn(column: required),
        );
      }
    }

    final items = <AccountImportPreviewItem>[];
    final seenNames = <String>{};
    var rowNumber = 1; // header
    for (final row in rows.skip(1)) {
      rowNumber++;
      final name = readCsvCell(row, colIndex['name']);
      if (name.isEmpty) continue;

      final key = name.toLowerCase();
      if (!seenNames.add(key)) continue;

      final balanceStr = readCsvCell(row, colIndex['balance']);
      final typeStr = readCsvCell(row, colIndex['type']);
      final bankStr = readCsvCell(row, colIndex['bank']);
      final limitStr = readCsvCell(row, colIndex['limit']);
      final dueStr = readCsvCell(row, colIndex['due']);
      final closingStr = readCsvCell(row, colIndex['closing']);

      final type = _parseType(typeStr, rowNumber);
      final bank = _parseBank(bankStr);
      final balance = parseCsvAmount(balanceStr);

      double? creditLimit;
      int? closingDay;
      int? dueDay;
      if (type == AccountType.creditCard) {
        creditLimit = limitStr.isEmpty ? null : parseCsvAmount(limitStr);
        closingDay = _parseDay(closingStr);
        dueDay = _parseDueDay(dueStr);
      }

      items.add(
        AccountImportPreviewItem(
          name: name,
          type: type,
          bank: bank,
          initialBalance: balance,
          creditLimit: creditLimit,
          closingDay: closingDay,
          dueDay: dueDay,
        ),
      );
    }

    if (items.isEmpty) {
      throw FormatException(t.csvImport.errors.noValidAccounts);
    }
    return items;
  }

  AccountImportPreview _buildPreview(
    List<AccountImportPreviewItem> parsed,
    List<AccountEntity> existing,
  ) {
    final existingNames = {
      for (final a in existing) a.name.toLowerCase(),
    };
    final toCreate = <AccountImportPreviewItem>[];
    final duplicates = <AccountImportPreviewItem>[];

    for (final item in parsed) {
      if (existingNames.contains(item.name.toLowerCase())) {
        duplicates.add(item);
      } else {
        toCreate.add(item);
      }
    }

    return AccountImportPreview(toCreate: toCreate, duplicates: duplicates);
  }

  /// Maps the `Tipo` column to an [AccountType]. Accepts PT-BR
  /// ("Conta Corrente", "Cartão de Crédito") and EN ("Checking",
  /// "Credit Card") via accent-insensitive substring match. Empty or
  /// unrecognized values raise a [FormatException] tagged with the
  /// offending [csvRow] so the UI can point the user to the exact row.
  ///
  /// Investment accounts are intentionally **not** importable via CSV in
  /// V1 (see docs/specs/accounts.md rule 13 and docs/specs/fifty_thirty_twenty.md).
  /// They must be created through the add-account form so the user sees
  /// the inline disclaimer about principal-only tracking.
  AccountType _parseType(String raw, int csvRow) {
    final normalized = normalizeForMatch(raw);
    if (normalized.isEmpty) {
      throw FormatException(
        t.csvImport.errors.accountTypeEmpty(row: csvRow),
      );
    }
    if (normalized.contains('corrente') || normalized.contains('checking')) {
      return AccountType.checking;
    }
    if (normalized.contains('credito') ||
        normalized.contains('credit') ||
        normalized.contains('cartao') ||
        normalized.contains('card')) {
      return AccountType.creditCard;
    }
    if (normalized.contains('investimento') ||
        normalized.contains('investment')) {
      throw FormatException(
        t.csvImport.errors.accountTypeInvestment(row: csvRow),
      );
    }
    throw FormatException(
      t.csvImport.errors.accountTypeInvalid(row: csvRow, value: raw),
    );
  }

  BankType _parseBank(String raw) {
    return BankBrand.resolveAlias(raw) ?? BankType.others;
  }

  // Accepts either Brazilian ("421,95" / "1.234,56") or English-style
  // ("421.95" / "1,234.56") number formats. The rightmost separator is
  // assumed to be the decimal point; the other one is treated as a
  // thousands grouper and stripped.

  int? _parseDay(String raw) {
    if (raw.isEmpty) return null;
    final value = int.tryParse(raw);
    if (value == null || value < 1 || value > 31) return null;
    return value;
  }

  int? _parseDueDay(String raw) {
    if (raw.isEmpty) return null;
    final asInt = int.tryParse(raw);
    if (asInt != null) return _parseDay(raw);
    final parts = raw.split('/');
    if (parts.length != 3) return null;
    return _parseDay(parts[0]);
  }
}
