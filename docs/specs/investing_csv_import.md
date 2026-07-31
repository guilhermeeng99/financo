# Investing CSV import (V2) — F6

Bulk-import investing **assets** and **transactions** from CSV, reusing
Financo's shared import infrastructure (the `csv` package, `csv_parsing.dart`
header/cell helpers, the `runCsvImportFlow` UI). Two use cases, each with the
standard `preview` / `call` / `importItems` shape.

## Shared conventions

- Headers are matched **by name** (accent/case-insensitive, reorder-tolerant,
  extra columns ignored) via `mapCsvHeaderColumns`. Numbers accept BR
  (`1.234,56`) and EN (`1,234.56`); dates are `DD/MM/YYYY` (or ISO).
- Structural cell errors throw a `FormatException` tagged `Row N:` →
  `ValidationFailure`, surfaced by the shared error dialog. Reference-resolution
  problems (unknown asset, etc.) are **not** fatal — they mark rows as
  skipped/duplicate in the preview.
- Enum cells (kind, market, currency, operation) are parsed by
  `investing_csv_parsers.dart` — the enum `name` plus PT/EN synonyms,
  space-insensitive.

## Assets (`ImportAssetsCsvUseCase`)

Columns: **required** `ticker`, `kind`, `institution`; optional `name`
(defaults to the ticker), `market` and `currency` (default from the kind via
`assetKindDefaults`). Dedup is by **`(ticker, market)`** — a matching existing
asset is reported as a duplicate and skipped; duplicate rows within the file
collapse to one.

`importItems` resolves each institution **by name**, creating a missing one on
the fly (kind `broker`, the item's currency) and caching it for later rows, then
creates the asset through `CreateAssetUseCase` (which enforces the
`(ticker, market)` uniqueness). Fail-fast on the first error. Result carries
`importedCount`, `duplicateCount`, `institutionsCreated`.

## Transactions (`ImportInvestingTransactionsCsvUseCase`)

Named with the `Investing` prefix to avoid colliding with the cash-side
`ImportTransactionsCsvUseCase`. Columns: **required** `ticker`; `quantity`+
`price` for buy/sell, `amount` for dividend. Optional `operation` (default
`buy`), `fees` (0), `date` (today), `notes`, `market`.

The asset must **already exist** (matched by ticker, disambiguated by an optional
market column) and carry an institution. Unresolved rows are reported as
**skipped** with a reason (`assetNotFound`, `assetAmbiguous`,
`assetNoInstitution`) — never fatal. Money is denominated in the **asset's**
currency; amounts come from `resolveTransactionAmounts`.

`importItems` persists the importable rows **oldest-first, buy before sell**
(`transactionKindRank`) through `SaveAssetTransactionUseCase`, so its oversell
guard sees covering buys first. A save failure (e.g. an oversell in the data)
stops the import and returns the failure. **No dedup** — one row → one
transaction, so re-importing the same file duplicates.

**No funding column (F8.4 gap).** The CSV has no way to name the checking
account that paid for a buy, so imported rows always land with
`fundingAccountId == null` — i.e. "cash was already at the broker"
(`investing_transactions.md` rule 8). No paired cash row is written and the
purchases never reach the 50/30/20 savings bucket.
`SyncInvestmentCashFlowUseCase` short-circuits this path before its ledger read
(`wanted == null && transaction.id.isEmpty`), so the import pays nothing for
it. Adding the column means resolving an account by name per row, the same way
the assets importer resolves institutions. Tracked in `TODO.md`.

## Presentation

`AssetsCubit` / `InvestingTransactionsCubit` gain `previewCsv` and
`confirmImport`. `confirmImport` emits an `Importing{processed,total}` progress
state per row, refreshes the list to `Loaded`, and **returns** the report so the
preview page can pop with a summary snackbar (avoids a terminal state that the
shared list builders would choke on). Entry points: a file-import action on the
assets and transactions app bars → `runCsvImportFlow` → a read-only preview page
(`/investing/assets/import`, `/investing/transactions/import`) listing what will
be imported vs skipped/duplicate, with a determinate progress bar on confirm.
Sample CSVs live in `lib/app/assets/samples/investing_{assets,transactions}_example.csv`.

## Tests

`import_assets_csv_usecase_test.dart` (parse + kind defaults, duplicate by
`(ticker, market)`, institution create/reuse, unknown kind, missing column,
in-file dedup) and `import_transactions_csv_usecase_test.dart` (resolve/skip,
dividend-only-amount, no-institution, ambiguous ticker, quantity/amount
validation, oldest-first buy-before-sell ordering, save-failure propagation).
