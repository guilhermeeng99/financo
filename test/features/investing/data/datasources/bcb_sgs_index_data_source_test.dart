import 'package:financo/features/investing/data/datasources/bcb_sgs_index_data_source.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(Uri.parse('https://example.com')));

  test('parses dated index points from the SGS payload', () async {
    final client = MockHttpClient();
    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response(
        '[{"data":"02/01/2024","valor":"0.04"},'
        '{"data":"03/01/2024","valor":"0.041"}]',
        200,
      ),
    );
    final ds = BcbSgsIndexDataSource(client);

    final result = await ds.series(EconomicIndex.cdi, DateTime(2024));
    final points = result.getOrElse(() => []);
    expect(points, hasLength(2));
    expect(points.first.date, DateTime(2024, 1, 2));
    expect(points.first.rate, 0.04);
  });
}
