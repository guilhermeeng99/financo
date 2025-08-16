import 'package:app_database/app_database.dart';

class DatabaseService {
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  static final DatabaseService _instance = DatabaseService._internal();

  DatabaseManager? _databaseManager;
  IAccountRepository? _accountRepository;
  AccountUsecase? _accountUsecase;

  Future<void> initialize() async {
    if (_databaseManager != null) return;

    try {
      _databaseManager = DatabaseManager();
      _accountRepository = AccountRepository(_databaseManager!);
      _accountUsecase = AccountUsecase(_accountRepository!);
    } catch (e) {
      _databaseManager = null;
      _accountRepository = null;
      _accountUsecase = null;
      rethrow;
    }
  }

  AccountUsecase get accountUsecase {
    if (_accountUsecase == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _accountUsecase!;
  }

  Future<void> dispose() async {
    await _databaseManager?.close();
    _databaseManager = null;
    _accountRepository = null;
    _accountUsecase = null;
  }
}
