/// Parses an enum value from its `name`, without throwing.
///
/// Enums cross two persistence boundaries in this app — Firestore documents
/// and Drift rows — and both store `enum.name` as a bare string. The stdlib
/// `Values.byName(s)` throws an `ArgumentError` on anything it does not
/// recognise, which turns one renamed or hand-edited value into a crashed
/// screen rather than one odd-looking row. Every read path should degrade
/// instead.
///
/// Returns `null` when [name] is absent, not a `String`, or matches nothing —
/// callers pick the fallback that makes sense for their field, which keeps the
/// decision visible at the call site instead of buried in a default.
///
/// Takes an `Object?` rather than a `String` because the raw value usually
/// arrives straight out of a `Map<String, dynamic>`, where a missing key and a
/// wrong type are equally possible.
///
/// Example:
/// ```dart
/// final kind = enumByNameOrNull(AssetKind.values, data['kind']) ??
///     AssetKind.stockBr;
/// ```
T? enumByNameOrNull<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

/// Parses an enum value from its `name`, falling back to [orElse].
///
/// Sugar over [enumByNameOrNull] for the common case where the fallback is a
/// constant. Prefer this at persistence boundaries so a bad stored value can
/// never crash a read.
///
/// Example:
/// ```dart
/// currency: enumByName(Currency.values, data['currency'], Currency.brl),
/// ```
T enumByName<T extends Enum>(List<T> values, Object? name, T orElse) =>
    enumByNameOrNull(values, name) ?? orElse;
