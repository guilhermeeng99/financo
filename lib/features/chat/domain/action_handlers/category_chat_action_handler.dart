import 'package:financo/features/categories/domain/category_colors.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/chat/domain/action_handlers/chat_action_handler.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class CategoryChatActionHandler implements ChatActionHandler {
  CategoryChatActionHandler({
    required CreateCategoryUseCase createCategory,
    required GetCategoriesUseCase getCategories,
    required DeleteCategoryUseCase deleteCategory,
  }) : _createCategory = createCategory,
       _getCategories = getCategories,
       _deleteCategory = deleteCategory;

  final CreateCategoryUseCase _createCategory;
  final GetCategoriesUseCase _getCategories;
  final DeleteCategoryUseCase _deleteCategory;

  /// Default icon codepoint used when the AI proposes a category without
  /// suggesting an icon. Matches `Icons.category` (Material icon family).
  static const int _defaultIconCodepoint = 58332;

  @override
  Future<String?> preflight({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async => null;

  @override
  Future<String> handle({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final action = meta['action'] as String?;
    if (action == 'create') {
      return _create(userId: userId, meta: meta, locale: locale);
    }
    if (action == 'delete') {
      return _delete(userId: userId, meta: meta, locale: locale);
    }
    return locale.translations.chat.handlers.unknownCategoryAction;
  }

  Future<String> _create({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final typeStr = meta['type'] as String? ?? 'expense';
    final type = switch (typeStr) {
      'income' => CategoryType.income,
      _ => CategoryType.expense,
    };

    final existingResult = await _getCategories(userId: userId);
    final existingCount = existingResult.fold(
      (_) => 0,
      (categories) => categories.length,
    );

    final category = CategoryEntity(
      id: '',
      userId: userId,
      name: meta['name'] as String? ?? 'Category',
      icon: meta['icon'] as int? ?? _defaultIconCodepoint,
      color: CategoryColors.forIndex(existingCount),
      type: type,
    );

    final result = await _createCategory(category);
    return result.fold(
      (f) => strings.chat.handlers.categoryCreateFailed(error: f.message),
      (c) => strings.chat.handlers.categoryCreated(name: c.name),
    );
  }

  Future<String> _delete({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final name = meta['name'] as String? ?? '';
    final listResult = await _getCategories(userId: userId);
    return listResult.fold(
      (f) => strings.chat.handlers.categoryLoadFailed(error: f.message),
      (categories) async {
        final match = categories
            .where((c) => c.name.toLowerCase() == name.toLowerCase())
            .toList();
        if (match.isEmpty) {
          return strings.chat.handlers.categoryNotFound(name: name);
        }
        final delResult = await _deleteCategory(match.first.id);
        return delResult.fold(
          (f) => strings.chat.handlers.categoryDeleteFailed(error: f.message),
          (_) => strings.chat.handlers.categoryDeleted(name: name),
        );
      },
    );
  }
}
