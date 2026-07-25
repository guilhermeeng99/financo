import 'package:equatable/equatable.dart';
import 'package:financo/core/money/currency.dart';

/// The nature of an institution; informational only (does not affect pricing).
enum InstitutionKind { bank, broker, internationalBroker, crypto, other }

/// Where assets are custodied (e.g. Nubank, Avenue). See
/// `docs/specs/institutions.md`.
class Institution extends Equatable {
  /// Creates an institution.
  const Institution({
    required this.id,
    required this.userId,
    required this.name,
    required this.kind,
    required this.currency,
    required this.createdAt,
    this.bank,
    this.color,
  });

  /// Stable unique id.
  final String id;

  /// Owner user id (Financo scopes every collection by `userId`).
  final String userId;

  /// Display name, unique per user (case-insensitive).
  final String name;

  /// Institution nature.
  final InstitutionKind kind;

  /// Default currency for assets held here (BRL for Nubank, USD for Avenue).
  final Currency currency;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Optional display hint: the `BankType.name` (from the accounts feature)
  /// used to render a brand logo/avatar on the Dashboard once investment
  /// accounts are unified into institutions (F8 — see
  /// `docs/specs/investing_account_unification.md`). Null → initials avatar.
  final String? bank;

  /// Optional display colour (ARGB int). Falls back to a colour derived from
  /// [kind] when null.
  final int? color;

  /// Returns a copy with the given fields replaced.
  Institution copyWith({
    String? name,
    InstitutionKind? kind,
    Currency? currency,
    String? bank,
    int? color,
  }) {
    return Institution(
      id: id,
      userId: userId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currency: currency ?? this.currency,
      createdAt: createdAt,
      bank: bank ?? this.bank,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    kind,
    currency,
    createdAt,
    bank,
    color,
  ];
}
