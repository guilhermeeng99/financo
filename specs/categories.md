# Categories Feature Spec

> **Status**: Active
> **Last updated**: 2026-04-17
> **Coverage**: Entity, Business Rules, Repository, State Machines, Edge Cases

## 1. Entity Contract

### CategoryEntity

| Field  | Type         | Nullable | Constraints                          |
|--------|--------------|----------|--------------------------------------|
| id     | String       | No       | Firestore document ID; empty on create |
| userId | String?      | Yes      | Owner user ID                        |
| name   | String       | No       | Non-empty                            |
| icon   | int          | No       | Material icon code point             |
| color  | int          | No       | ARGB color value                     |
| type   | CategoryType | No       | `income` or `expense`                |

### CategoryType (enum)
- `income`
- `expense`

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
- **deleteCategory**: Deletes from remote first, then deletes locally.
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
  userId, name, type, icon, color, status, existingId?, failure?

Computed:
  isEditing = existingId != null
  isValid = name.isNotEmpty

Actions:
  updateName(String)  → emits state with new name
  updateType(CategoryType) → emits state with new type
  updateIcon(int)     → emits state with new icon
  updateColor(int)    → emits state with new color

  submit():
    if !isValid → no-op
    emits status: submitting
    isEditing ? updateCategory : createCategory
    success → emits status: success
    failure → emits status: failure + failure object

Initial state (create mode):
  name: '', type: expense, icon: 58332, color: 4280391411, status: initial

Initial state (edit mode):
  name: existing.name, type: existing.type, icon: existing.icon,
  color: existing.color, existingId: existing.id
  Type selector is DISABLED (type immutable after creation)
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
| Edit existing category | Type selector disabled, all other fields editable |

## 6. Model Serialization

### CategoryModel

```
toJson() → Map<String, dynamic>:
  { userId, name, icon, color, type: type.name }
  Note: 'id' is NOT included (Firestore doc ID is separate)

fromFirestore(DocumentSnapshot) → CategoryModel:
  Reads doc.id as id, all other fields from doc.data()
  type: parsed from string via enum name matching, defaults to expense

fromEntity(CategoryEntity) → CategoryModel:
  Direct field mapping
```
