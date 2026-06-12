import 'package:equatable/equatable.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:financo/features/categories/domain/category_colors.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFormCubit extends Cubit<CategoryFormState> {
  CategoryFormCubit({
    required CreateCategoryUseCase createCategory,
    required UpdateCategoryUseCase updateCategory,
    required GetCategoriesUseCase getCategories,
    required GetBudgetsUseCase getBudgets,
    required String userId,
    CategoryEntity? existingCategory,
  }) : _createCategory = createCategory,
       _updateCategory = updateCategory,
       _getCategories = getCategories,
       _getBudgets = getBudgets,
       super(
         CategoryFormState.initial(
           userId: userId,
           existing: existingCategory,
         ),
       );

  final CreateCategoryUseCase _createCategory;
  final UpdateCategoryUseCase _updateCategory;
  final GetCategoriesUseCase _getCategories;
  final GetBudgetsUseCase _getBudgets;

  /// Loads everything the form needs beyond the entity itself: the user's
  /// categories (parent-picker options, delete-reassignment targets, the
  /// palette index for a new category's default color) and — in edit mode —
  /// the demote guardrails (`hasChildren`, `hasBudget`). Run once when the
  /// form opens; the values don't change while it is open since CRUD on
  /// this user's data is single-threaded.
  Future<void> loadFormData() async {
    final result = await _getCategories(userId: state.userId);
    if (isClosed) return;
    final all = result.fold((_) => <CategoryEntity>[], (cats) => cats);
    _applyLoadedCategories(all);
    if (state.isEditing) await _loadEditMetadata(all);
  }

  void _applyLoadedCategories(List<CategoryEntity> all) {
    emit(
      state.copyWith(
        allCategories: all,
        isLoadingCategories: false,
        // New categories cycle through the palette so siblings don't all
        // share one color — same rule the form page applied before the
        // count moved into the cubit.
        color: state.isEditing ? null : CategoryColors.forIndex(all.length),
      ),
    );
    // Re-apply inheritance for subcategories opened in edit mode so
    // legacy rows whose icon/color drifted from the parent snap back
    // into the visual family on save.
    final parentId = state.parentId;
    if (parentId == null) return;
    final parent = state.rootCategories
        .where((c) => c.id == parentId)
        .firstOrNull;
    if (parent != null) updateParentId(parentId, parent: parent);
  }

  /// Demote validation needs `hasChildren` / `hasBudget` for the category
  /// being edited — the cubit enforces both guardrails before persisting.
  Future<void> _loadEditMetadata(List<CategoryEntity> all) async {
    final categoryId = state.existingId!;
    final hasChildren = all.any((c) => c.parentId == categoryId);
    final budgetsResult = await _getBudgets(userId: state.userId);
    if (isClosed) return;
    final hasBudget = budgetsResult.fold<bool>(
      (_) => false,
      (budgets) => budgets.any((b) => b.categoryId == categoryId),
    );
    emit(state.copyWith(hasChildren: hasChildren, hasBudget: hasBudget));
  }

  void updateName(String value) => emit(state.copyWith(name: value));

  void updateType(CategoryType type) {
    // Switching type clears anything that doesn't apply to the new
    // type. The bucket is income-meaningless (see docs/specs/categories.md
    // rule 21) and the parent picker is type-scoped.
    final clearBucket = type == CategoryType.income;
    emit(
      state.copyWith(
        type: type,
        clearParentId: true,
        clearBucket: clearBucket,
      ),
    );
  }

  void updateIcon(int icon) => emit(state.copyWith(icon: icon));

  void updateColor(int color) => emit(state.copyWith(color: color));

  void updateParentId(String? parentId, {CategoryEntity? parent}) {
    // Choosing a parent flips the category into a subcategory, which
    // inherits the parent's 50/30/20 bucket (see docs/specs/categories.md
    // rule 20). Clear any previously-picked bucket so we don't write a
    // dangling value that the overview will ignore anyway.
    //
    // Subcategories also inherit the parent's icon + color so the
    // hierarchy reads as a single visual family in the list. The page
    // resolves the parent entity from its cached root list and passes
    // it in; when absent (e.g. picker only knew the id) the current
    // appearance is left untouched.
    if (parentId == null) {
      emit(state.copyWith(clearParentId: true));
      return;
    }
    emit(
      state.copyWith(
        parentId: parentId,
        clearBucket: true,
        icon: parent?.icon,
        color: parent?.color,
      ),
    );
  }

  /// Sets the 50/30/20 bucket. Pass `null` to clear. No-ops on:
  /// - income categories (bucket is expense-only);
  /// - subcategories (bucket is inherited from the parent).
  /// The guards keep state consistent even if the UI sends a stale tap
  /// during a fast type/parent switch.
  void updateBucket(CategoryBucket? bucket) {
    if (state.type == CategoryType.income) return;
    if (state.parentId != null) return;
    emit(
      bucket == null
          ? state.copyWith(clearBucket: true)
          : state.copyWith(bucket: bucket),
    );
  }

  /// Toggles whether transactions on this category should feed the
  /// 50/30/20 base income (the "100%"). Only meaningful on **root**
  /// income categories — subcategories inherit from the parent (see
  /// docs/specs/categories.md rule 22). Input is silently ignored on
  /// expense or sub-income categories.
  void updateCountsIn50_30_20({required bool value}) {
    if (state.type != CategoryType.income) return;
    if (state.parentId != null) return;
    emit(state.copyWith(countsIn50_30_20: value));
  }

  Future<void> submit() async {
    if (!state.isValid) return;

    // Demote guardrails: root → sub conversion is blocked when the
    // root either owns subcategories (rule 14: only 1 level allowed)
    // or has a budget attached (budgets only bind to root expense
    // categories, see docs/specs/budgets.md). Emitting `failure` keeps the
    // form state and surfaces the message via the page listener.
    if (state.isDemoting) {
      if (state.hasChildren) {
        emit(
          state.copyWith(
            status: FormStatus.failure,
            failure: ValidationFailure(t.categories.demoteBlockedChildren),
          ),
        );
        return;
      }
      if (state.hasBudget) {
        emit(
          state.copyWith(
            status: FormStatus.failure,
            failure: ValidationFailure(t.categories.demoteBlockedBudget),
          ),
        );
        return;
      }
    }

    emit(state.copyWith(status: FormStatus.submitting));

    // bucket is meaningful only for root expense categories. Income
    // categories don't have one; subcategories inherit from the parent
    // (see docs/specs/categories.md rule 20).
    final isRootExpense = state.type == CategoryType.expense &&
        state.parentId == null;
    final category = CategoryEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      name: state.name,
      icon: state.icon,
      color: state.color,
      type: state.type,
      parentId: state.parentId,
      bucket: isRootExpense ? state.bucket : null,
      // Only root income categories carry the flag; expense and
      // sub-income categories persist `true` (the neutral default) so
      // a stale "false" from a type/parent toggle is never written
      // out. The 50/30/20 compute walks up to the parent for
      // subcategories, so the persisted value doesn't matter there.
      countsIn50_30_20: state.type != CategoryType.income ||
          state.parentId != null ||
          state.countsIn50_30_20,
    );

    (state.isEditing
            ? await _updateCategory(category)
            : await _createCategory(category))
        .fold(
          (failure) => emit(
            state.copyWith(
              status: FormStatus.failure,
              failure: failure,
            ),
          ),
          (_) => emit(state.copyWith(status: FormStatus.success)),
        );
  }
}

class CategoryFormState extends Equatable {
  const CategoryFormState({
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.status,
    required this.countsIn50_30_20,
    required this.hasChildren,
    required this.hasBudget,
    this.allCategories = const [],
    this.isLoadingCategories = true,
    this.existingId,
    this.parentId,
    this.originalParentId,
    this.bucket,
    this.failure,
  });

  factory CategoryFormState.initial({
    required String userId,
    CategoryEntity? existing,
  }) {
    return CategoryFormState(
      userId: userId,
      name: existing?.name ?? '',
      type: existing?.type ?? CategoryType.expense,
      icon: existing?.icon ?? 58332,
      // Placeholder for create mode — `loadFormData` re-seeds it from the
      // user's category count before the form renders.
      color: existing?.color ?? CategoryColors.forIndex(0),
      status: FormStatus.initial,
      existingId: existing?.id,
      parentId: existing?.parentId,
      originalParentId: existing?.parentId,
      bucket: existing?.bucket,
      countsIn50_30_20: existing?.countsIn50_30_20 ?? true,
      hasChildren: false,
      hasBudget: false,
    );
  }

  final String userId;
  final String name;
  final CategoryType type;
  final int icon;
  final int color;
  final FormStatus status;

  /// Every category the user owns, fetched once by
  /// [CategoryFormCubit.loadFormData]. Feeds the parent picker (via
  /// [rootCategories]) and the delete-reassignment dialog.
  final List<CategoryEntity> allCategories;

  /// True until [CategoryFormCubit.loadFormData] resolves — the page
  /// shows a spinner instead of the form so the default color and parent
  /// options are correct on first paint.
  final bool isLoadingCategories;
  final String? existingId;
  final String? parentId;

  /// Parent id the category had when the form opened. Drives demote
  /// detection (rule 17): `originalParentId == null && parentId != null`
  /// means the user is converting a root into a subcategory.
  final String? originalParentId;
  final CategoryBucket? bucket;
  final bool countsIn50_30_20;

  /// True when this category owns any subcategories. Populated
  /// asynchronously by the page; demote is blocked while it is true
  /// (rule 14 — only one nesting level allowed).
  final bool hasChildren;

  /// True when this root category has a budget attached. Budgets only
  /// bind to root expense categories, so demoting would orphan them —
  /// block instead.
  final bool hasBudget;
  final Failure? failure;

  bool get isEditing => existingId != null;
  bool get isValid => name.isNotEmpty;

  /// Categories eligible to be a parent (roots of the right shape).
  List<CategoryEntity> get rootCategories =>
      allCategories.where((c) => c.canBeParent).toList();

  /// True when the user is converting a root into a sub on this edit.
  bool get isDemoting =>
      isEditing && originalParentId == null && parentId != null;

  /// True when the user is converting a sub into a root on this edit.
  bool get isPromoting =>
      isEditing && originalParentId != null && parentId == null;

  CategoryFormState copyWith({
    String? name,
    CategoryType? type,
    int? icon,
    int? color,
    FormStatus? status,
    String? parentId,
    bool clearParentId = false,
    CategoryBucket? bucket,
    bool clearBucket = false,
    bool? countsIn50_30_20,
    bool? hasChildren,
    bool? hasBudget,
    List<CategoryEntity>? allCategories,
    bool? isLoadingCategories,
    Failure? failure,
  }) {
    return CategoryFormState(
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      status: status ?? this.status,
      allCategories: allCategories ?? this.allCategories,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      existingId: existingId,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      originalParentId: originalParentId,
      bucket: clearBucket ? null : (bucket ?? this.bucket),
      countsIn50_30_20: countsIn50_30_20 ?? this.countsIn50_30_20,
      hasChildren: hasChildren ?? this.hasChildren,
      hasBudget: hasBudget ?? this.hasBudget,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    type,
    icon,
    color,
    status,
    allCategories,
    isLoadingCategories,
    existingId,
    parentId,
    originalParentId,
    bucket,
    countsIn50_30_20,
    hasChildren,
    hasBudget,
    failure,
  ];
}
