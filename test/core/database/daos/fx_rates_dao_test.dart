import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/fx_rates_dao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late FxRatesDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.fxRatesDao;
  });

  tearDown(() => db.close());

  group('saveRate + getRate', () {
    test('round-trips a rate for a pair', () async {
      await dao.saveRate('USD->BRL', 5.4321, DateTime(2024, 3, 5));

      expect(await dao.getRate('USD->BRL'), 5.4321);
    });

    test('keeps full double precision', () async {
      // The rate multiplies every foreign holding into the base currency, so a
      // truncated value shifts the whole consolidated total.
      await dao.saveRate('EUR->BRL', 6.123456789, DateTime(2024, 3, 5));

      expect(await dao.getRate('EUR->BRL'), 6.123456789);
    });

    test('replaces the stored rate for the same pair', () async {
      await dao.saveRate('USD->BRL', 5, DateTime(2024, 3, 5));
      await dao.saveRate('USD->BRL', 5.5, DateTime(2024, 3, 6));

      expect(await dao.getRate('USD->BRL'), 5.5);
    });

    test('keeps distinct pairs independent', () async {
      // Each foreign currency is priced on its own — one pair overwriting
      // another would consolidate EUR holdings at the USD rate.
      await dao.saveRate('USD->BRL', 5.4, DateTime(2024, 3, 5));
      await dao.saveRate('EUR->BRL', 6.1, DateTime(2024, 3, 5));

      expect(await dao.getRate('USD->BRL'), 5.4);
      expect(await dao.getRate('EUR->BRL'), 6.1);
    });

    test('returns null for a pair that was never cached', () async {
      expect(await dao.getRate('GBP->BRL'), isNull);
    });
  });

  test('deleteAllFxRates clears the cache', () async {
    await dao.saveRate('USD->BRL', 5.4, DateTime(2024, 3, 5));
    await dao.saveRate('EUR->BRL', 6.1, DateTime(2024, 3, 5));

    await dao.deleteAllFxRates();

    expect(await dao.getRate('USD->BRL'), isNull);
    expect(await dao.getRate('EUR->BRL'), isNull);
  });
}
