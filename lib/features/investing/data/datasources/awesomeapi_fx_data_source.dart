import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/data/datasources/guarded_fetch.dart';
import 'package:financo/features/investing/domain/datasources/quote_data_source.dart';
import 'package:http/http.dart' as http;

/// FX rates via AwesomeAPI (e.g. USD→BRL). Keyless. See `docs/specs/quotes.md`.
class AwesomeApiFxDataSource implements FxDataSource {
  /// Creates the adapter over an HTTP client.
  const AwesomeApiFxDataSource(this._client);

  final http.Client _client;

  @override
  Future<Either<Failure, double>> rate(Currency from, Currency to) async {
    if (from == to) return const Right(1);

    final pair = '${from.code}-${to.code}';
    final key = '${from.code}${to.code}';
    return guardedFetch(() async {
      final response = await _client.get(
        Uri.parse('https://economia.awesomeapi.com.br/json/last/$pair'),
      );
      if (response.statusCode != 200) {
        return const Left(ServerFailure('FX request failed.'));
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final node = data[key] as Map<String, dynamic>?;
      final bid = double.tryParse(node?['bid'] as String? ?? '');
      if (bid == null) return const Left(ServerFailure('FX parse failed.'));
      return Right(bid);
    });
  }
}
