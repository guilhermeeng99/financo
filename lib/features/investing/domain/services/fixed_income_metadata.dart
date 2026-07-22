import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/fixed_income_terms.dart';

/// Reads and writes the fixed-income accrual params an [Asset] carries in its
/// `metadata` map. Centralizes the key names so the form (writer) and the
/// dashboard (reader) never drift apart.
abstract final class FixedIncomeMetadata {
  /// Metadata key for the accrual basis (a [FixedIncomeBasis] name).
  static const basisKey = 'fiBasis';

  /// Metadata key for the contracted rate (see [FixedIncomeBasis] for meaning).
  static const rateKey = 'fiRate';

  /// Parsed `(basis, ratePercent)` from [asset], or null when not configured.
  static (FixedIncomeBasis, double)? read(Asset asset) {
    final basis = _basisByName(asset.metadata[basisKey]);
    final rate = double.tryParse(asset.metadata[rateKey] ?? '');
    if (basis == null || rate == null) return null;
    return (basis, rate);
  }

  /// Metadata entries encoding [basis] and [rate], to be merged by the caller.
  static Map<String, String> write(FixedIncomeBasis basis, double rate) => {
    basisKey: basis.name,
    rateKey: _trimmed(rate),
  };

  static FixedIncomeBasis? _basisByName(String? name) {
    for (final basis in FixedIncomeBasis.values) {
      if (basis.name == name) return basis;
    }
    return null;
  }

  /// Formats a rate without trailing zeros: `110.0 → "110"`, `6.5 → "6.5"`.
  static String _trimmed(double value) {
    final fixed = value.toStringAsFixed(4);
    if (!fixed.contains('.')) return fixed;
    return fixed
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}
