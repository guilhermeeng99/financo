# Categories Feature Spec

> **Status**: Active
> **Last updated**: 2026-06-10
> **Coverage**: Entity, Business Rules, Repository, State Machines, Edge Cases

## 1. Entity Contract

### CategoryEntity

| Field    | Type             | Nullable | Constraints                                                                                          |
|----------|------------------|----------|------------------------------------------------------------------------------------------------------|
| id       | String           | No       | Firestore document ID; empty on create                                                               |
| userId   | String?          | Yes      | Owner user ID                                                                                        |
| name     | String           | No       | Non-empty                                                                                            |
| icon     | int              | No       | Material icon code point                                                                             |
| color    | int              | No       | ARGB color value                                                                                     |
| type     | CategoryType     | No       | `income` or `expense`                                                                                |
| parentId | String?          | Yes      | References another category's ID; `null` = root category                                             |
| bucket   | CategoryBucket?  | Yes      | Only meaningful when `type == expense`. Drives the 50/30/20 overview. `null` = unclassified.         |

### CategoryType (enum)
- `income`
- `expense`

### CategoryBucket (enum)
- `needs` — essentials (rent, groceries, utilities, transport-to-work).
- `wants` — discretionary (dining out, streaming, hobbies).

The bucket is consumed exclusively by the 50/30/20 dashboard card — see
[fifty_thirty_twenty.md](fifty_thirty_twenty.md) for the full feature
spec. Income categories ignore the field. Savings is tracked at the
account level (transfers `checking → investment`), not as a bucket on
the category.

### Computed Properties
- `canBeParent` → `parentId == null` (only root categories can be parents)
- `isSubcategory` → `parentId != null`

## 2. Business Rules

1. **Editable fields**: root categories can edit name, icon, color, bucket/50-30-20 flag when applicable, and parent assignment. Subcategories can edit name and parent assignment; icon and color are inherited from the parent in app surfaces.
2. **All categories are deletable**.
3. **Type is immutable after creation**: a category's type (income/expense) cannot be changed once created. The type selector is disabled in edit mode.
4. **Name must not be empty**: form validation rejects empty names.
5. **Duplicate names are allowed**: the system does not enforce unique names.
6. **Every category belongs to a user**: no concept of "system" or "default" categories. Each user has their own categories.
7. **Deleting a category requires transaction reassignment**: when deleting, user must choose another category to receive the deleted category's transactions.
8. **Cannot delete last category**: if only one category remains, deletion is blocked.
9. **Default icon**: code point 58332 (shopping_cart).
10. **Default color**: 4280391411 (blue). The auto-assignment cycles through `CategoryColors.palette` modulo its length, so adding swatches to the palette never breaks existing categories.
11. **Default type for new categories**: `expense`.
12. **List ordered alphabetically by name**.
13. **Subcategories**: A category may optionally have a `parentId` referencing another category (its parent). A category with no `parentId` is a "root" category.
14. **Only one level of nesting**: A child category (`parentId != null`) cannot itself be a parent. When selecting a parent, only root categories are shown.
15. **Same-type constraint**: A child category must have the same `type` (income/expense) as its parent.
16. **Cannot delete parent with children**: A category that has subcategories cannot be deleted. The user must first remove or reassign all children.
17. **`parentId` is mutable after creation**, with three flows the form supports:
    - **Re-parent (sub → other sub-of-same-type)**: change the parent picker to another root with matching `type`. No data migration — transactions hold `categoryId` only, so the new parent's bucket / `countsIn50_30_20` flag apply on the next refresh.
    - **Promote (sub → root)**: clear the parent (pick "Nenhuma"). The bucket / 50/30/20-income flag fields become editable on the form because the category is now a root.
    - **Demote (root → sub)**: pick a parent. Blocked at submit time when (a) the category owns subcategories (rule 14: only one nesting level), or (b) the category has a budget attached (budgets only bind to root expense categories — see `docs/specs/budgets.md`). User must clear the blocker first. On a successful demote, the persisted `bucket` and `countsIn50_30_20` revert to neutral defaults (`null` / `true`); the compute pipelines resolve via the new parent.
    - The parent picker filters by `type` (rule 15) and excludes self.
18. **Dashboard aggregation**: Subcategory transaction amounts roll up into their parent category totals in reports and charts.
19. **`bucket` is editable at any time** (unlike `type` and `parentId`). Changing a category's bucket re-bins live 50/30/20 spend on the next dashboard refresh — there is no historical "bucket-at-time-of-transaction" record. Justification: users will classify retroactively, and rewriting historical bucket attribution would surprise them.
20. **`bucket` is set only on root categories — subcategories inherit from the parent**. The user classifies once, at the root. Storing a separate bucket on each child would force re-classification on every subcategory and create silent drift (a "Mercado" parent flagged as `needs` while a forgotten "Delivery" child stayed as `null`). At write time, subcategory rows have `bucket == null`; the 50/30/20 calculation walks up to the parent to resolve the effective bucket. If the parent itself is missing (orphan parent), the transaction counts as unclassified.
21. **`bucket` is only meaningful when `type == expense` AND `parentId == null`**. The form hides the bucket selector for income categories and for subcategories. Toggling type to income clears any previously chosen bucket; picking a parent also clears it.
22. **`countsIn50_30_20` (bool, default `true`)** — only meaningful on **root income categories**. Drives whether transactions on this category feed the 50/30/20 base income (see [fifty_thirty_twenty.md](fifty_thirty_twenty.md)). The form exposes a toggle when `type == income` AND `parentId == null`; set to `false` to exclude one-off receipts (reimbursements, gifts, sold goods) that would otherwise distort the monthly breakdown. Sub-income categories **inherit the flag from the parent** — same rationale as rule 20 (single classification point at the root, no per-child drift). Expense categories ignore the field entirely. Legacy data without the field falls back to `true` so prior behaviour is preserved.
23. **Subcategory appearance**: Subcategories render with the parent's icon and color everywhere categories are shown (category list, transaction pickers, and selected category fields). This is a display-level inheritance rule; stored child icon/color values are used only as a fallback when the parent cannot be resolved.

## 3. Repository Contract

### CategoryRepository (abstract)

```dart
Future<Either<Failure, List<CategoryEntity>>> getCategories({
  required String userId,
  bool forceRefresh = false,
});

Future<Either<Failure, CategoryEntity>> createCategory(CategoryEntity category);
Future<Either<Failure, CategoryEntity>> updateCategory(CategoryEntity category);
Future<Either<Failure, void>> deleteCategory(String id);
```

### Behavior

- **getCategories**: Returns local cache by default. With `forceRefresh = true`, fetches from remote, replaces local cache, then returns local data. Results sorted alphabetically by name.
- **createCategory**: Writes to remote first, then upserts locally. Returns the created entity (with server-assigned ID).
- **updateCategory**: Writes to remote first, then upserts locally. Returns the updated entity.
- **deleteCategory**: Checks for children first — if the category has subcategories, returns `Left(ValidationFailure)`. Otherwise deletes from remote first, then deletes locally.
- **All methods**: Catch `ServerException` and return `Left(ServerFailure)`.

### Data Source Contract

```dart
abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({required String userId});
  Future<CategoryModel> createCategory(CategoryModel model);
  Future<CategoryModel> updateCategory(CategoryModel model);
  Future<void> deleteCategory(String id);
}
```

- `getCategories` queries Firestore where `userId == userId`, ordered by `name` ASC.

### Local Cache (CategoriesDao)

- `getCategories(userId)` — returns categories where `userId` matches, ordered by `name` ASC.
- `upsertCategory(entity)` — insert or update on conflict.
- `insertAllCategories(list)` — batch insert/update.
- `deleteCategory(id)` — delete by ID.
- `deleteAllCategories()` — clear all local categories.
- `getChildCategories(parentId)` — returns categories where `parentId` matches, ordered by `name` ASC.

## 4. State Machines

### CategoriesCubit (list management)

```
States:
  CategoriesInitial
  CategoriesLoading
  CategoriesLoaded(categories: List<CategoryEntity>)
  CategoriesError(failure: Failure)

Transitions:
  loadCategories(forceRefresh: false):
    Initial → Loading → Loaded | Error
    Loaded + !forceRefresh → Loaded (no-op, returns early)
    Loaded + forceRefresh → Loading → Loaded | Error
```

### CategoryFormCubit (form management)

```
FormStatus enum: initial | submitting | success | failure

State fields:
  userId, name, type, icon, color, status, existingId?, failure?, parentId?, bucket?

Computed:
  isEditing = existingId != null
  isValid = name.isNotEmpty

Actions:
  updateName(String)  → emits state with new name
  updateType(CategoryType) → emits state with new type
                              (sets bucket to null when type becomes income)
  updateIcon(int)     → emits state with new icon
  updateColor(int)    → emits state with new color
  updateParentId(String?, parent?) → emits state with new parentId
                            (sets bucket to null when a parent is chosen —
                             subcategories inherit per rule 20; when parent is
                             provided, copies parent icon/color per rule 23)
  updateBucket(CategoryBucket?) → emits state with new bucket
                                   (input is silently ignored when type == income
                                    OR parentId != null — see rule 21)

  submit():
    if !isValid → no-op
    emits status: submitting
    bucket is only written when type == expense AND parentId == null
    isEditing ? updateCategory : createCategory
    success → emits status: success
    failure → emits status: failure + failure object

Initial state (create mode):
  name: '', type: expense, icon: 58332, color: 4280391411,
  status: initial, parentId: null, bucket: null

Initial state (edit mode):
  name: existing.name, type: existing.type, icon: existing.icon,
  color: existing.color, existingId: existing.id, parentId: existing.parentId,
  bucket: existing.bucket
  Type selector is DISABLED (type immutable after creation)
  Parent selector is HIDDEN (parentId immutable after creation)
  Bucket selector is shown when type == expense AND parentId == null (rule 21)
```

## 5. Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Empty category list | UI shows EmptyState widget |
| Server failure on load | UI shows ErrorView with retry |
| Server failure on create | Form stays open, shows error snackbar |
| Server failure on update | Form stays open, shows error snackbar |
| Server failure on delete | Operation fails silently (current) |
| Submit with empty name | Form validation blocks submission |
| forceRefresh with empty remote | Local cache is cleared, returns empty list |
| loadCategories called when already loaded | Returns cached data (no network call) |
| Edit existing category | Type selector disabled, parent selector hidden, all other fields editable |
| Delete category with children | Deletion blocked, show message to remove subcategories first |
| Select parent category | Only root categories of same type shown; selecting parent locks type |
| Change type when parent selected | Parent is reset to null, dropdown re-filtered |
| Subcategory in dashboard | Transaction amounts rolled up into parent category totals |
| Orphaned subcategory (parent deleted externally) | Treated as root category gracefully |

## 6. CSV Import Preview Editing

The CSV import flow has two stages: **parse + preview** and **confirm**. The preview is rendered on a dedicated page (not a dialog) so the user can review and adjust each item before committing.

### CSV format

Header row is required and skipped (column labels are free-form). Columns, in order: `Categoria`, `Subcategoria` (may be empty for root rows), `Tipo`. The type column is matched case-insensitively against:

- **Income**: `income` (EN) or `receita` (PT-BR)
- **Expense**: `expense` (EN) or `despesa` (PT-BR)

Empty or unrecognized type values cause the whole import to be rejected with a `ValidationFailure` whose message points to the offending CSV row (1-based, header counted as row 1) and lists the accepted values. The dialog surfaces this as an `AlertDialog` so the user can read the full error.

### Preview item

```
CategoryImportPreviewItem {
  name:        String           (required)
  type:        CategoryType     (required, derived from CSV row)
  icon:        int              (required, defaults to 58332)
  color:       int              (required, auto-assigned via CategoryColors.forIndex)
  parentName:  String?          (set for subcategory rows)
}
```

### Page-level rules

19. **Tabs split by type**: the page presents Expense and Income tabs (counts in labels). Items from the other tab are hidden but kept in state.
20. **Per-item edit**: tapping an item opens a sheet with name, icon and color editors. Type and parent relationship are not editable in the sheet.
21. **Renaming a root cascades to children**: when the user changes a root's `name`, every child whose `parentName` matched the old name is updated to the new name so the parent lookup at import time still resolves.
22. **Deleting a root drops its children**: the user is asked to confirm the cascade when the root has subcategories. Deleting a leaf or a childless root removes only that item.
23. **Duplicates are read-only**: items the preview marked as duplicates are listed in a muted "Will be skipped" section per tab and cannot be edited or removed.
24. **Submit guard**: the submit bar is disabled when the editable list is empty (everything was removed); duplicates alone are not enough to submit.
25. **Confirm calls `importItems`**: the cubit's `confirmImport(items, duplicateCount)` delegates to `ImportCategoriesCsvUseCase.importItems`, which uses each item's icon/color verbatim and creates roots before children. Children whose parent name no longer resolves are silently skipped (they were edited away by the user).

### Cubit contract addition

```
confirmImport({
  required List<CategoryImportPreviewItem> items,
  int duplicateCount = 0,
}) → CategoriesImporting(processed: 0, total: items.length)
   → CategoriesImporting(processed: i, total: items.length)  // for each i
   → CategoriesImported(categories, importedCount, duplicateCount)
   | CategoriesError(failure)
```

### Progress reporting

26. **`importItems` accepts an optional `onProgress(processed, total)` callback** invoked after every processed item (created or skipped). `total` equals the input `items.length`; orphan children that are skipped still tick the counter so the bar reaches 100%.
27. **The cubit translates progress into `CategoriesImporting` states** so the import-categories page renders a determinate `LinearProgressIndicator` overlay (with a `processed of total` counter and percentage) until the import resolves. The list page treats `CategoriesImporting` as a loading state.

## 7. Icon & color picker UX

The form's "Appearance" section is composed of three controls:

28. **Color picker** is a wrapping grid (`Wrap`) over `CategoryColors.palette`. Every swatch is visible without horizontal scrolling.
29. **Icon picker is a bottom sheet**, not an inline grid. The form shows a launcher tile (current icon + "Choose icon" label) that opens `showCategoryIconPicker`. The picker takes up to 95% of the viewport, has a sticky search field, and dismisses on selection returning the chosen `int` code point.
30. **Icon catalog is curated** in `category_icon_catalog.dart`. Each entry tags an `IconData` with a flat, space-separated keyword string covering both English and Portuguese (without diacritics) — e.g. `'car carro vehicle veiculo auto'`.
31. **Search is bilingual and accent-insensitive.** `searchCategoryIcons(query, options)`:
    - normalises the query (lowercase + strips Latin diacritics),
    - splits on whitespace into AND-tokens,
    - matches when every token is a prefix of any of the entry's keywords.
    Empty/whitespace queries return the full catalog so the grid always shows something.
32. **No-results state** renders a centred "No icons match your search." message when the filter empties the list.

## 8. Model Serialization

### CategoryModel

```
toJson() → Map<String, dynamic>:
  { userId, name, icon, color, type: type.name, parentId (if not null) }
  Note: 'id' is NOT included (Firestore doc ID is separate)

fromFirestore(DocumentSnapshot) → CategoryModel:
  Reads doc.id as id, all other fields from doc.data()
  type: parsed from string via enum name matching, defaults to expense
  parentId: read as String?, null if absent

fromEntity(CategoryEntity) → CategoryModel:
  Direct field mapping (including parentId)
```
