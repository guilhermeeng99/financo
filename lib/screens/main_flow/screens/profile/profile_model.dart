import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';

ProfileModel get profileModel => Modular.get<ProfileModel>();

class ProfileModel {
  DatabaseManager get _databaseManager => Modular.get<DatabaseManager>();

  Future<void> deleteAllData() async {
    await _databaseManager.deleteAllData();
  }
}
