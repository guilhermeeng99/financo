import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/data/datasources/guarded_fetch.dart';
import 'package:financo/features/investing/domain/datasources/index_data_source.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';
import 'package:http/http.dart' as http;

/// Fetches economic index series from the Banco Central SGS public API. Each
/// index maps to an SGS series code; values are period rates in percent.
/// Keyless. See `docs/specs/quotes.md`.
class BcbSgsIndexDataSource implements IndexDataSource {
  /// Creates the adapter over an HTTP client.
  const BcbSgsIndexDataSource(this._client);

  final http.Client _client;

  /// SGS series codes: CDI daily, Selic daily, IPCA monthly.
  static const Map<EconomicIndex, int> seriesCode = {
    EconomicIndex.cdi: 12,
    EconomicIndex.selic: 11,
    EconomicIndex.ipca: 433,
  };

  @override
  Future<Either<Failure, List<IndexPoint>>> series(
    EconomicIndex index,
    DateTime from,
  ) async {
    final code = seriesCode[index]!;
    return guardedFetch(() async {
      final uri =
          Uri.parse(
            'https://api.bcb.gov.br/dados/serie/bcdata.sgs.$code/dados',
          ).replace(
            queryParameters: {
              'formato': 'json',
              'dataInicial': _formatDate(from),
            },
          );
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        return const Left(ServerFailure('Index request failed.'));
      }
      final rows = jsonDecode(response.body) as List<dynamic>;
      final points = <IndexPoint>[];
      for (final raw in rows) {
        final map = raw as Map<String, dynamic>;
        final date = _parseDate(map['data'] as String?);
        final rate = _parseRate(map['valor'] as String?);
        if (date == null || rate == null) continue;
        points.add(IndexPoint(date: date, rate: rate));
      }
      return Right(points);
    });
  }

  /// BCB expects and returns `dd/MM/yyyy`.
  String _formatDate(DateTime date) =>
      '${_two(date.day)}/${_two(date.month)}/${date.year}';

  DateTime? _parseDate(String? value) {
    final parts = value?.split('/');
    if (parts == null || parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  /// BCB sends decimals with a dot, but tolerate a comma just in case.
  double? _parseRate(String? value) =>
      value == null ? null : double.tryParse(value.replaceAll(',', '.'));

  String _two(int n) => n.toString().padLeft(2, '0');
}
