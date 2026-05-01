# Categories Feature Spec

> **Status**: Active
> **Last updated**: 2026-04-17
> **Coverage**: Entity, Business Rules, Repository, State Machines, Edge Cases

## 1. Entity Contract

### CategoryEntity

| Field    | Type         | Nullable | Constraints                                                    |
|----------|--------------|----------|----------------------------------------------------------------|
| id       | String       | No       | Firestore document ID; empty on create                         |
| userId   | String?      | Yes      | Owner user ID                                                  |
| name     | String       | No       | Non-empty                                                      |
| icon     | int          | No       | Material icon code point                                       |
| color    | int          | No       | ARGB color value                                               |
| type     | CategoryType | No       | `income` or `expense`                                          |
| parentId | String?      | Yes      | References another category's ID; `null` = root category       |

### CategoryType (enum)
- `income`
- `expense`

### Computed Properties
- `canBeParent` → `parentId == null` (only root categories can be parents)
- `isSubcategory` → `parentId != null`

## 2. Business Rules

1. **All categories are fully editable**: name, icon, and color can be changed on any category.
2. **All categories are deletable**.
3. **Type is immutable after creation**: a category's type (income/expense) cannot be changed once created. The type selector is disabled in edit mode.
4. **Name must not be empty**: form validation rejects empty names.
5. **Duplicate names are allowed**: the system does not enforce unique names.
6. **Every category belongs to a user**: no concept of "system" or "default" categories. Each user has their own categories.
7. **Deleting a category requires transaction reassignment**: when deleting, user must choose another category to receive the deleted category's transactions.
8. **Cannot delete last category**: if only one category remains, deletion is blocked.
9. **Default icon**: code point 58332 (shopping_cart).
10. **Default color**: 4280391411 (blue).
11. **Default type for new categories**: `expense`.
12. **List ordered alphabetically by name**.
13. **Subcategories**: A category may optionally have a `parentId` referencing another category (its parent). A category with no `parentId` is a "root" category.
14. **Only one level of nesting**: A child category (`parentId != null`) cannot itself be a parent. When selecting a parent, only root categories are shown.
15. **Same-type constraint**: A child category must have the same `type` (income/expense) as its parent.
16. **Cannot delete parent with children**: A category that has subcategories cannot be deleted. The user must first remove or reassign all children.
17. **`parentId` is immutable after creation** (same as `type`). The parent selector is hidden in edit mode.
18. **Dashboard aggregation**: Subcategory transaction amounts roll up into their parent category totals in reports and charts.

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
  userId, name, type, icon, color, status, existingId?, failure?, parentId?

Computed:
  isEditing = existingId != null
  isValid = name.isNotEmpty

Actions:
  updateName(String)  → emits state with new name
  updateType(CategoryType) → emits state with new type
  updateIcon(int)     → emits state with new icon
  updateColor(int)    → emits state with new color
  updateParentId(String?) → emits state with new parentId (create mode only)

  submit():
    if !isValid → no-op
    emits status: submitting
    isEditing ? updateCategory : createCategory
    success → emits status: success
    failure → emits status: failure + failure object

Initial state (create mode):
  name: '', type: expense, icon: 58332, color: 4280391411, status: initial, parentId: null

Initial state (edit mode):
  name: existing.name, type: existing.type, icon: existing.icon,
  color: existing.color, existingId: existing.id, parentId: existing.parentId
  Type selector is DISABLED (type immutable after creation)
  Parent selector is HIDDEN (parentId immutable after creation)
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
}) → Loading → CategoriesImported(categories, importedCount, duplicateCount)
                                | CategoriesError(failure)
```

## 7. Model Serialization

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
