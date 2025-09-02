import '../repository/i_category_repository.dart';
import 'category_crud_usecase_operations.dart';
import 'category_query_usecase_operations.dart';
import 'i_category_usecase.dart';

class CategoryUsecaseImpl extends ICategoryUsecase
    with CategoryCrudUsecaseOperations, CategoryQueryUsecaseOperations {
  CategoryUsecaseImpl(this._categoryRepository);

  final ICategoryRepository _categoryRepository;

  @override
  ICategoryRepository get categoryRepository => _categoryRepository;
}
