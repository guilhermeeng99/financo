# Financo

A personal finance manager desktop application for Windows, built with Flutter. Financo lets you track transactions, manage bank accounts and credit cards, categorize expenses, and visualize financial movements over time — all stored locally on your machine.

---

## Features

- **Dashboard** — overview of your financial health
- **Account Statement** — detailed transaction history per account
- **Credit Card** — manage credit card bills and charges
- **Financial Movements** — visualize past and upcoming releases
- **Transactions** — create, edit, and import transactions (via Excel)
- **Registers** — manage accounts and categories
- **Profile** — user preferences and settings
- **Internationalization** — English and Portuguese (BR) support

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter (Dart) — Windows desktop |
| Routing & DI | flutter_modular |
| State Management | GetX + flutter_hooks |
| Local Database | Drift (SQLite) |
| Charts | fl_chart |
| Excel Export/Import | excel + file_saver |
| Internationalization | slang |
| Monorepo | Melos |
| Linting | very_good_analysis |
| Windows API | win32 |

---

## Project Structure

```
financo/
├── lib/                    # Main app
│   ├── app/                # App setup (module, routes, theme, initializer)
│   └── screens/            # All app screens
├── packages/
│   ├── app_core/           # Core logic, services, shared utilities
│   ├── app_database/       # Drift database (accounts, categories, transactions)
│   └── app_widgets/        # Shared UI widget library
└── bin/                    # Code generation scripts
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.9.0`
- Dart SDK `^3.9.0`
- [Melos](https://melos.invertase.dev/) — `dart pub global activate melos`

### Setup

```bash
# Install dependencies across all packages
melos bootstrap

# Run the app in release mode
melos run run_release
```

---

## Scripts

| Command | Description |
|---|---|
| `melos run generate_routes` | Regenerate route classes |
| `melos run slang` | Regenerate i18n translation files |
| `melos run generate_assets_folders` | Regenerate asset references |
| `melos run build_runner_app_database_by_path` | Run build_runner for the database package |
| `melos run packages_update` | Check for outdated packages |
