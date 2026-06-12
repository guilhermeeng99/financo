# Design System Spec

The shared visual language of Financo: tokens, typography, layout rules,
and the reusable `Financo*` widget library. This is the contract every new
screen must follow so the app reads as one product, not a pile of pages.

**Read this before building any new screen or widget.** When a screen needs
something not covered here, prefer extending a token or a shared widget over
inventing a one-off — then update this spec.

> Scope: visual/interaction system only. Feature behavior lives in the
> per-feature specs (`dashboard.md`, `accounts.md`, …). UI copy lives in
> slang (`lib/gen/i18n/`). Code conventions live in `CLAUDE.md`.

---

## 1. Where things live

```
lib/app/theme/
├── app_colors.dart        # AppColorsData (semantic color tokens) + AppColors (active light/dark)
├── app_typography.dart    # AppTypography.textTheme (the type scale) + amount() helper
├── app_theme.dart         # AppTheme.light()/dark() — Material 3 ThemeData wiring
├── light_palettes.dart    # catalog of selectable light palettes
├── dark_palettes.dart     # catalog of selectable dark palettes
├── light_palette_cubit.dart / dark_palette_cubit.dart  # runtime palette switch
└── theme_cubit.dart       # light/dark mode switch

lib/core/extensions/context_extensions.dart  # context.appColors / textTheme / screenSize / isDarkMode

lib/app/widgets/           # the shared component library (Financo* + system widgets)
```

**Access rule:** never read raw theme objects ad hoc. Always go through the
`BuildContext` extensions:

```dart
final colors = context.appColors;        // AppColorsData — semantic colors
final text   = context.textTheme;         // the type scale
context.isDarkMode;                        // bool
context.screenSize;                        // Size
```

---

## 2. Color tokens

Colors are **semantic**, never literal. The full token set
(`AppColorsData`, `lib/app/theme/app_colors.dart`):

| Token | Role |
|-------|------|
| `primary` / `primaryLight` / `primaryDark` | Brand accent — CTAs, active nav, selection, focus ring |
| `secondary` | Secondary accent (currently green, == income) |
| `background` | App/scaffold backdrop (darkest layer) |
| `surface` | Card / sheet / app-bar fill (one layer above background) |
| `surfaceVariant` | Input fill, dividers, subtle chips, hover/track (between bg and surface) |
| `onBackground` | Primary text/icon on background or surface |
| `onBackgroundLight` | Muted text — labels, captions, placeholders, section headers, inactive nav |
| `income` | Positive money (credits, gains) — green |
| `expense` | Negative money (debits, overspend) — red |
| `warning` | Caution / "under target" / credit-card section accent — amber |
| `success` | Confirmation — green |
| `error` | Validation/destructive — red |

### Money color rule
- Positive/zero → `income`. Negative → `expense` with a `-` prefix.
- This is automated by **`AmountText`** and `FinancoCurrencyField` — use them;
  don't hand-color money.

### Palette system (runtime-switchable)
`AppColors.light` / `AppColors.dark` are **mutable** statics. The user can pick
a palette from `light_palettes.dart` / `dark_palettes.dart` at runtime
(`LightPaletteCubit` / `DarkPaletteCubit` reassign them; `ThemeCubit` switches
light↔dark). `context.appColors` returns the active one for the current
brightness. **Implication:** any new palette must define the entire
`AppColorsData` field set, and every screen automatically inherits palette
changes for free *as long as it uses the tokens*.

### Hard rule
Never write a `Color(0x…)` literal or a `Colors.<name>` in feature/UI code.
The only sanctioned literal outside `lib/app/theme/` today is
`core/notifications/notification_constants.dart` (an OS-notification accent,
not an in-app surface). New literals in UI code are a design-system bug.

---

## 3. Typography

Two families, wired in `app_typography.dart`, exposed as the Material
`TextTheme` (`context.textTheme`). **Poppins** = display/branding & numbers
(geometric, characterful). **Inter** = everything textual (legible at small
sizes).

| Style | Font / Size / Weight | Typical use |
|-------|----------------------|-------------|
| `displayLarge` | Poppins 32 bold | Hero numbers, big balances |
| `displayMedium` | Poppins 28 bold | — |
| `displaySmall` | Poppins 24 / 600 | — |
| `headlineLarge` | Poppins 22 / 600 | Large app-bar title |
| `headlineMedium` | Poppins 20 / 600 | Page/section titles |
| `headlineSmall` | Poppins 18 / 600 | — |
| `titleLarge` | Poppins 16 / 600 | Card titles |
| `titleMedium` | Inter 16 / 500 | App-bar title, emphasis rows, button text |
| `titleSmall` | Inter 14 / 500 | List-row titles |
| `bodyLarge` | Inter 16 / 400 (h1.5) | Long-form body |
| `bodyMedium` | Inter 14 / 400 (h1.5) | Default body |
| `bodySmall` | Inter 12 / 400 (h1.5) | Captions, hints |
| `labelLarge` | Inter 14 / 500 | — |
| `labelMedium` | Inter 12 / 500 | Chips, secondary labels |
| `labelSmall` | Inter 11 / 500 | Section headers (uppercased), pills, metadata |

- **Money** uses `AppTypography.amount(color, fontSize: 18)` (Poppins 600), not
  the text scale — wrapped by `AmountText`.
- **Section headers** are `labelSmall` + `FontWeight.w600` +
  `letterSpacing: 0.8` + `.toUpperCase()` + `onBackgroundLight`. (Encapsulated
  by the section widgets — see §6.)
- Color is applied by the theme (`bodyColor`/`displayColor = onBackground`); use
  `.copyWith(color: …)` only to deviate (muted text, money, accents).

---

## 4. Spacing & radius scale

> ⚠️ **These are conventions, not yet constants.** Values are written inline
> across the codebase. The de-facto scale below is what's actually used —
> follow it, and see §8 (backlog) for the proposal to promote it to
> `AppSpacing` / `AppRadius` tokens.

**Spacing (gaps / `SizedBox` / padding):** base unit **4**, scale
**4 · 8 · 12 · 16 · 20 · 24**. 16 is the standard page gutter; 20 is the gap
between form sections; 24 is a large block separation.

- Page horizontal gutter: `16`.
- Gap between stacked `FinancoFormSection`s: `20`.
- Inside a card: `16` (forms) or `8` (dense list cards — see `DashboardSection`).

**Corner radius** (de-facto, by frequency):

| Radius | Use |
|--------|-----|
| `20` | Section/content cards, sheets, pill chips (toggle, month filter) |
| `16` | `cardTheme` default, medium containers, icon tiles |
| `12` | Inputs, buttons, small tiles, picker rows (the **most common** radius) |
| `14` | Icon "disc"/avatar containers |
| `10` / `8` | Small chips, count pills, advice boxes |
| `6` / `4` / `2` | Inner markers, hairlines, progress-bar fills |

Avoid one-off radii (the codebase has stray `15 / 18 / 28 / 32 / 36` — don't
add more). Pick the nearest scale value.

**Hairlines / dividers:** `0.5`–`1px`, color `surfaceVariant` (or the theme
`Divider`).

---

## 5. Material theme defaults

`AppTheme._buildTheme` (Material 3) sets these so you rarely style raw Material
widgets by hand:

- **Inputs** (`InputDecorationTheme`): filled with `surfaceVariant`, radius
  `12`, no resting border, focused border = `primary` width `2`, error border =
  `error`, content padding `16×14`.
- **ElevatedButton / OutlinedButton**: full-width (`minimumSize ∞ × 52`),
  radius `12`, `primary` fill / outline, `titleMedium` 600 label.
- **Card**: `surface`, elevation `1`, radius `16`.
- **Chip**: `surfaceVariant` bg, `primary` when selected, radius `20`.
- **AppBar**: `surface` bg, flat (elevation 0), centered title. (Most pages use
  the custom `FinancoLargeAppBar` instead — see §6.)
- **BottomNavigationBar**: `surface`, `primary` selected / `onBackgroundLight`
  unselected. (The shell actually uses the custom floating `FinancoBottomBar`.)
- **Divider**: `surfaceVariant`, thickness 1.

---

## 6. Component library (`lib/app/widgets/`)

Prefer these over raw Material widgets. Each is documented with a `///` intent
comment in its source.

### Forms & inputs
| Widget | Purpose / contract |
|--------|--------------------|
| `FinancoFormSection` | Card cluster of fields with an uppercase label above. The standard way to group a form. `label`, `children`. |
| `FinancoTextField` | App text field (wraps the input theme). `controller`, `label`, `hintText`, `onChanged`, `maxLines`, `subdued`. |
| `FinancoCurrencyField` | BRL "cents-grow-from-the-right" money input, `R$` prefix, value as `2.000,00`. `controller`, `onChanged`, `autofocus`. |
| `FinancoDateField` | Read-only date tile (`InputDecorator` look) that opens a picker on tap. `label`, `value`, `onTap`. |
| `FinancoPickerField` | Tap-to-open "row selector" tile: leading icon, label, value/placeholder, chevron. Backs Account/Category pickers. |
| `FinancoPickerSheet` | Design-system chrome for modal picker bottom sheets: rounded surface, drag handle, left-aligned title. Draggable variant takes a `bodyBuilder(scrollController)` (+ optional `header` widgets, e.g. a search field); `FinancoPickerSheet.fixed` is a shrink-wrapped column for short content (day grid, short lists). |
| `FinancoPickerSheetEmpty` | Centered muted placeholder for picker bodies with nothing to list (no data or no search hits). `message`. |
| `FinancoPillToggle<T>` | Segmented control (e.g. Expense/Income/Transfer). `options`, `selected`, `onChanged`, `disabled`. |
| `FinancoSearchField` | App-wide search input used by every search-as-you-type sheet. |
| `FinancoSubmitBar` | Sticky bottom bar with the primary submit action (+ optional secondary "save & add another"). `label`, `isLoading`, `isEnabled`, `onSubmit`, `onSecondarySubmit`. |

### Structure & navigation
| Widget | Purpose |
|--------|---------|
| `FinancoLargeAppBar` | iOS-style large left-aligned title app bar (default page header). |
| `FinancoSidebar` | Web/tablet navigation rail (≥600px): brand, nav, month stepper, profile. |
| `FinancoBottomBar` | Floating pill bottom nav for mobile (<600px); active item expands to a label. |
| `FinancoMonthFilterPill` | Compact month stepper bound to `DateFilterCubit`. |
| `LiftedFab` | Wraps a FAB so it floats above the mobile bottom bar (see §7). |
| `SubPageScope` | Marks a pushed sub-page so the shell hides its bottom bar / month pill (see §7). |
| `FinancoAppBarIconButton` | Circular tinted icon button for app-bar actions. |

### Display & feedback
| Widget | Purpose |
|--------|---------|
| `AmountText` | Money with automatic income/expense coloring + sign. **Always use for money.** |
| `TransactionTile` | Standard transaction row (icon disc, title, category label, `AmountText`). |
| `FinancoCategoryAvatar` | Category icon on its tinted disc. |
| `BankAvatar` | Bank brand disc (color + abbreviation from `BankBrand`). |
| `FinancoDialog` | App dialog: icon badge, title, message, weighted action buttons (`FinancoDialogAction`). Use `showFinancoConfirmDialog` for confirms. |
| `showTypeEmailToConfirmDialog` | Type-to-confirm dialog for destructive, irreversible actions: the user must type the given `email` exactly (case-insensitive, trimmed) before the error-tinted CTA enables. Resolves `true` only on confirm. |
| `FeatureEmptyState` | Shared first-impression empty state: tinted icon disc (or custom `leading`), headline, message, optional muted `example` chip, primary CTA (`actionLabel`/`onAction`) and `footer`. |
| `LoadingShimmer` | Standard loading placeholder. Show while a bloc/cubit is in its loading state. |
| `ErrorView` | Full-screen error + retry from a domain `Failure`. Standard error state. |
| `import_widgets.dart` | Shared CSV import-preview chrome (progress overlay, empty tab, picker row). |
| `runCsvImportFlow` + `CsvImportFlowConfig<T>` | One entry point for every feature's CSV import (accounts, categories, transactions, budgets): intro dialog (select file / download example) → file pick → the feature's `parseCsv` step (usually a cubit `previewCsv`) → shared error dialog on `Left`, or the feature's `onParsed` follow-up (push preview route / snackbar) on `Right`. (`csv_import_flow.dart`) |
| `ImportPreviewScaffold<B, S>` | Shared chrome for CSV import-preview pages: large app bar, type pill toggle, optional notice banners, the row list, importing progress overlay, bottom submit bar. Pages supply state handling (`onStateChanged`) and the toggle/notices/list; the scaffold owns layout and bloc wiring. |
| `context.showSnack(message)` | Extension on `BuildContext` (`lib/core/extensions/context_extensions.dart`) — the project's default feedback channel for plain-text snackbars. Snackbars needing actions, custom content, or durations still call `ScaffoldMessenger` directly. |

**Feature-level shared widget:** `DashboardSection`
(`lib/features/dashboard/.../widgets/dashboard_section.dart`) — section header
**with** a trailing slot and a surface card, used across dashboard cards.

---

## 7. Layout & responsive rules

### Breakpoints (`ResponsiveLayout`)
- **Mobile** `< 600` · **Tablet** `600–900` · **Desktop** `≥ 900`.
- `ResponsiveLayout.isMobile/isTablet/isDesktop(context)`.
- `maxContentWidth = 600`: content is centered and width-capped on large screens.

### Shell chrome
- **≥ 600px:** left `FinancoSidebar` (hosts nav + month stepper + profile). No
  bottom bar; pages must **not** render their own month pill (the sidebar owns
  it).
- **< 600px:** floating `FinancoBottomBar` + the page surfaces its own
  `FinancoMonthFilterPill` (centered) since there's no sidebar.
- **Sub-pages** (account detail, add/edit, accounts/categories lists, …) wrap in
  `SubPageScope`, which hides the bottom bar and month pill for their depth.

### FAB & bottom clearance
- The floating mobile bar = `16 + 64 + 16 = 96px`. `LiftedFab` lifts the FAB by
  `80` **only** on mobile **and** only when not in a sub-page (depth 0).
- Because the FAB floats over scrolling content, **every scroll view that has a
  FAB must pad its bottom** so the last row clears it. Observed values:

  | Context | Bottom padding |
  |---------|----------------|
  | Shell **tab** with bottom bar + lifted FAB (dashboard, payables, budgets) | `160` (96 bar + ~56 FAB + spacing) |
  | **Sub-page** (no bar, FAB not lifted: accounts, categories, account statement) | `96` |
  | Single-column tab lists (investments, 50/30/20) | `120` |

  > This is an inline magic number per page — see §8 to fold it into a helper.

---

## 8. Recurring patterns

### Section header (3 variants — know which to use)
All three share the visual: a `6×6` accent dot + uppercased `labelSmall`
(`w600`, `letterSpacing 0.8`, `onBackgroundLight`) + optional count pill (accent
@ 12% alpha, radius 8).

| Widget | Wraps a card? | Trailing slot? | Use for |
|--------|---------------|----------------|---------|
| `FinancoFormSection` | ✅ surface card (r20, pad 16) | ❌ (no dot) | Form field clusters |
| `FinancoSectionHeader` | ❌ header only | ❌ | Headers over a list of separate cards |
| `DashboardSection` | ✅ surface card (r20, pad 8) | ✅ | Dashboard data cards w/ a trailing badge/pill |

> These overlap heavily and have drifted (different label paddings: `4,0,4,8` /
> `4,24,4,12` / `4,0,4,10`). See §9 — candidate for unification.

### Forms
Compose `FinancoFormSection`s separated by `SizedBox(height: 20)`, fields inside
separated by `SizedBox(height: 12)`. Primary action goes in a
`FinancoSubmitBar` as the Scaffold `bottomNavigationBar`. Gate the submit on a
cubit `isValid`; show `isLoading` during submit.

### State screens
- Loading → `LoadingShimmer`. Error → `ErrorView(failure, onRetry)`.
- Empty → `FeatureEmptyState` (icon disc, headline, message, optional example
  chip + CTA). Inside picker sheets use `FinancoPickerSheetEmpty`.
- Drive all three from the bloc/cubit state in a single `BlocBuilder`.

### Pickers
Selection of an account/category/etc. opens a **bottom sheet** built on
`FinancoPickerSheet` (drag handle + title chrome; search-as-you-type via a
`FinancoSearchField` in the `header` slot); the trigger on the form is a
`FinancoPickerField`. Empty/no-hits bodies render `FinancoPickerSheetEmpty`.

---

## 9. Conventions (do / don't)

**Do**
- Use tokens (`context.appColors`) and the type scale (`context.textTheme`).
- Use the `Financo*` widget for the job; extend it if it's close.
- Format money with `formatCurrency()` / `AmountText` — never show a raw double.
- Route every user-facing string through slang (`t.section.key`).
- Apply `const`, keep widgets small, follow the spacing/radius scale (§4).

**Don't**
- Hardcode `Color(0x…)`, `Colors.<name>`, or hex in UI code.
- Hand-color money or hand-build a section header / submit bar.
- Invent a new radius/spacing value outside the scale.
- Render a month pill on a page when the sidebar is showing (≥600px).
- Let a FAB crop the last list item (§7).

---

## 10. Known inconsistencies / backlog

Honest state of the system — none block shipping, but documenting them keeps
new code from copying the drift. Address only on explicit request.

1. **No spacing/radius tokens.** Values are inline everywhere. *Proposal:* add
   `AppSpacing` (4/8/12/16/20/24) and `AppRadius` (8/10/12/14/16/20) constants
   and migrate gradually; lint against stray values.
2. **Three overlapping section headers** (`FinancoFormSection`,
   `FinancoSectionHeader`, `DashboardSection`). *Proposal:* one
   `FinancoSection` with optional `dot`, `count`, `trailing`, and `card` flags;
   keep thin aliases.
3. **Radius drift:** stray `15/18/28/32/36` exist. Snap to the scale.
4. **FAB bottom-clearance is a per-page magic number** (96/120/160).
   *Proposal:* a `bottomSafeForFab(context, {isSubPage})` helper or a
   `FabSafeArea` wrapper that computes it from `LiftedFab` + bar geometry.
5. **`secondary` == `income`** (both green). If a true secondary accent is ever
   needed, they'll need to diverge.

---

## 11. Checklist for a new screen

- [ ] Colors via `context.appColors`; text via `context.textTheme`. Zero literals.
- [ ] Reused `Financo*` widgets (form section, fields, submit bar, app bar, tiles).
- [ ] Money via `AmountText` / `formatCurrency`.
- [ ] Strings via slang.
- [ ] Spacing & radius on-scale (§4); page gutter 16, section gap 20.
- [ ] Loading / error / empty states handled (`LoadingShimmer` / `ErrorView` / muted text).
- [ ] Responsive: works <600 (bottom bar, own month pill) and ≥600 (sidebar, no pill); sub-pages wrap in `SubPageScope`.
- [ ] If it has a FAB and a scroll view, the list clears the FAB (§7).
- [ ] Looks right in **both** light and dark, and survives a palette switch.
