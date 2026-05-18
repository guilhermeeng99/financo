import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/category_colors.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFormCubit extends Cubit<CategoryFormState> {
  CategoryFormCubit({
    required CreateCategoryUseCase createCategory,
    required UpdateCategoryUseCase updateCategory,
    required String userId,
    CategoryEntity? existingCategory,
    int existingCategoryCount = 0,
  }) : _createCategory = createCategory,
       _updateCategory = updateCategory,
       super(
         CategoryFormState.initial(
           userId: userId,
           existing: existingCategory,
           existingCategoryCount: existingCategoryCount,
         ),
       );

  final CreateCategoryUseCase _createCategory;
  final UpdateCategoryUseCase _updateCategory;

  void updateName(String value) => emit(state.copyWith(name: value));

  void updateType(CategoryType type) {
    // Switching type clears anything that doesn't apply to the new
    // type. The bucket is income-meaningless (see specs/categories.md
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
    // inherits the parent's 50/30/20 bucket (see specs/categories.md
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
  /// specs/categories.md rule 22). Input is silently ignored on
  /// expense or sub-income categories.
  void updateCountsIn50_30_20({required bool value}) {
    if (state.type != CategoryType.income) return;
    if (state.parentId != null) return;
    emit(state.copyWith(countsIn50_30_20: value));
  }

  /// Page calls this after async-fetching children + budget existence
  /// for the category being edited. Cubit needs both to enforce
  /// demote guardrails (root → sub) before persisting.
  void setMetadata({required bool hasChildren, required bool hasBudget}) {
    emit(state.copyWith(hasChildren: hasChildren, hasBudget: hasBudget));
  }

  Future<void> submit() async {
    if (!state.isValid) return;

    // Demote guardrails: root → sub conversion is blocked when the
    // root either owns subcategories (rule 14: only 1 level allowed)
    // or has a budget attached (budgets only bind to root expense
    // categories, see specs/budgets.md). Emitting `failure` keeps the
    // form state and surfaces the message via the page listener.
    if (state.isDemoting) {
      if (state.hasChildren) {
        emit(
          state.copyWith(
            status: FormStatus.failure,
            failure: const ValidationFailure(
              'Esta categoria tem subcategorias. Promova ou remova as '
              'subcategorias antes de transformá-la em subcategoria.',
            ),
          ),
        );
        return;
      }
      if (state.hasBudget) {
        emit(
          state.copyWith(
            status: FormStatus.failure,
            failure: const ValidationFailure(
              'Esta categoria tem um orçamento. Exclua o orçamento '
              'antes de transformá-la em subcategoria.',
            ),
          ),
        );
        return;
      }
    }

    emit(state.copyWith(status: FormStatus.submitting));

    // bucket is meaningful only for root expense categories. Income
    // categories don't have one; subcategories inherit from the parent
    // (see specs/categories.md rule 20).
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
    this.existingId,
    this.parentId,
    this.originalParentId,
    this.bucket,
    this.failure,
  });

  factory CategoryFormState.initial({
    required String userId,
    CategoryEntity? existing,
    int existingCategoryCount = 0,
  }) {
    return CategoryFormState(
      userId: userId,
      name: existing?.name ?? '',
      type: existing?.type ?? CategoryType.expense,
      icon: existing?.icon ?? 58332,
      color: existing?.color ?? CategoryColors.forIndex(existingCategoryCount),
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
    Failure? failure,
  }) {
    return CategoryFormState(
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      status: status ?? this.status,
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
