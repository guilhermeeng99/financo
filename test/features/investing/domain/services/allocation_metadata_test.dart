import 'package:financo/features/investing/domain/services/allocation_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  group('AllocationMetadata.classId', () {
    test('returns the linked class id when present', () {
      final asset = AssetFactory.stockUs(
        metadata: const {AllocationMetadata.classIdKey: 'class-1'},
      );

      expect(AllocationMetadata.classId(asset), 'class-1');
    });

    test('returns null when the key is absent', () {
      expect(AllocationMetadata.classId(AssetFactory.stockUs()), isNull);
    });

    test('returns null when the key is an empty string', () {
      final asset = AssetFactory.stockUs(
        metadata: const {AllocationMetadata.classIdKey: ''},
      );

      expect(AllocationMetadata.classId(asset), isNull);
    });
  });

  group('AllocationMetadata.write', () {
    test('sets the class id key', () {
      final result = AllocationMetadata.write(const {}, 'class-1');

      expect(result[AllocationMetadata.classIdKey], 'class-1');
    });

    test('removes the key when the class id is null', () {
      final result = AllocationMetadata.write(
        const {AllocationMetadata.classIdKey: 'class-1'},
        null,
      );

      expect(result.containsKey(AllocationMetadata.classIdKey), isFalse);
    });

    test('removes the key when the class id is empty', () {
      final result = AllocationMetadata.write(
        const {AllocationMetadata.classIdKey: 'class-1'},
        '',
      );

      expect(result.containsKey(AllocationMetadata.classIdKey), isFalse);
    });

    test('returns a new map and never mutates the input', () {
      final original = {'other': 'keep'};

      final result = AllocationMetadata.write(original, 'class-1');

      expect(result, isNot(same(original)));
      expect(result['other'], 'keep');
      expect(result[AllocationMetadata.classIdKey], 'class-1');
      // The caller's map is untouched.
      expect(original.containsKey(AllocationMetadata.classIdKey), isFalse);
    });
  });
}
