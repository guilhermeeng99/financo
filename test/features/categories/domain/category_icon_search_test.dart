import 'package:financo/features/categories/domain/category_icon_catalog.dart';
import 'package:financo/features/categories/domain/category_icon_option.dart';
import 'package:financo/features/categories/domain/category_icon_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sample = <CategoryIconOption>[
    CategoryIconOption(
      icon: Icons.directions_car,
      keywords: 'car carro vehicle veiculo',
    ),
    CategoryIconOption(
      icon: Icons.restaurant,
      keywords: 'restaurant restaurante food comida',
    ),
    CategoryIconOption(
      icon: Icons.local_cafe,
      keywords: 'coffee cafe latte',
    ),
  ];

  group('searchCategoryIcons', () {
    test('returns the full catalog when query is empty', () {
      expect(searchCategoryIcons('', sample), sample);
      expect(searchCategoryIcons('   ', sample), sample);
    });

    test('matches English keyword (prefix)', () {
      final result = searchCategoryIcons('car', sample);
      expect(result.map((o) => o.icon), [Icons.directions_car]);
    });

    test('matches Portuguese keyword for the same icon', () {
      final result = searchCategoryIcons('carro', sample);
      expect(result.map((o) => o.icon), [Icons.directions_car]);
    });

    test('is case-insensitive', () {
      expect(
        searchCategoryIcons('CARRO', sample).map((o) => o.icon),
        [Icons.directions_car],
      );
    });

    test('strips diacritics on the query side', () {
      final result = searchCategoryIcons('Café', sample);
      expect(result.map((o) => o.icon), [Icons.local_cafe]);
    });

    test('returns empty when no keyword starts with the token', () {
      expect(searchCategoryIcons('xyz', sample), isEmpty);
    });

    test('all tokens must match (AND semantics)', () {
      final result = searchCategoryIcons('food comida', sample);
      expect(result.map((o) => o.icon), [Icons.restaurant]);

      final mixed = searchCategoryIcons('car food', sample);
      expect(mixed, isEmpty);
    });
  });

  group('catalog integrity', () {
    test('every catalog entry has at least one keyword', () {
      for (final opt in categoryIconCatalog) {
        expect(
          opt.keywords.trim(),
          isNotEmpty,
          reason: 'icon ${opt.icon.codePoint} has no keywords',
        );
      }
    });

    test('catalog has no duplicate code points', () {
      final codes = categoryIconCatalog.map((o) => o.codePoint).toList();
      expect(codes.toSet().length, codes.length);
    });

    test('user example "carro" hits at least one icon', () {
      expect(searchCategoryIcons('carro', categoryIconCatalog), isNotEmpty);
    });
  });
}
