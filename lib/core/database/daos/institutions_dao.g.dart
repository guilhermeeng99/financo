// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'institutions_dao.dart';

// ignore_for_file: type=lint
mixin _$InstitutionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalInstitutionsTable get localInstitutions =>
      attachedDatabase.localInstitutions;
  InstitutionsDaoManager get managers => InstitutionsDaoManager(this);
}

class InstitutionsDaoManager {
  final _$InstitutionsDaoMixin _db;
  InstitutionsDaoManager(this._db);
  $$LocalInstitutionsTableTableManager get localInstitutions =>
      $$LocalInstitutionsTableTableManager(
        _db.attachedDatabase,
        _db.localInstitutions,
      );
}
