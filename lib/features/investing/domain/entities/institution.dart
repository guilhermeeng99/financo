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

  /// Returns a copy with the given fields replaced.
  Institution copyWith({
    String? name,
    InstitutionKind? kind,
    Currency? currency,
  }) {
    return Institution(
      id: id,
      userId: userId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currency: currency ?? this.currency,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, kind, currency, createdAt];
}
