import '../../../database/database_manager.dart';
import 'category_crud_operations.dart';
import 'category_query_operations.dart';
import 'i_category_repository.dart';

class CategoryRepositoryImpl extends ICategoryRepository
    with CategoryQueryOperations, CategoryCrudOperations {
  CategoryRepositoryImpl(this._database);

  final DatabaseManager _database;

  @override
  DatabaseManager get database => _database;
}
