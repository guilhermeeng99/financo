import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';

class InstitutionModel extends Institution {
  const InstitutionModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.kind,
    required super.currency,
    required super.createdAt,
  });

  factory InstitutionModel.fromFirestore(DocumentSnapshot doc) {
    return InstitutionModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory InstitutionModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final createdAtRaw = data['createdAt'];
    return InstitutionModel(
      id: id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      kind: InstitutionKind.values.byName(data['kind'] as String),
      currency: Currency.values.byName(data['currency'] as String),
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  factory InstitutionModel.fromEntity(Institution e) {
    return InstitutionModel(
      id: e.id,
      userId: e.userId,
      name: e.name,
      kind: e.kind,
      currency: e.currency,
      createdAt: e.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'kind': kind.name,
      'currency': currency.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
