// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotes_dao.dart';

// ignore_for_file: type=lint
mixin _$QuotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalQuotesTable get localQuotes => attachedDatabase.localQuotes;
  QuotesDaoManager get managers => QuotesDaoManager(this);
}

class QuotesDaoManager {
  final _$QuotesDaoMixin _db;
  QuotesDaoManager(this._db);
  $$LocalQuotesTableTableManager get localQuotes =>
      $$LocalQuotesTableTableManager(_db.attachedDatabase, _db.localQuotes);
}
